<?php

namespace App\Services;

use App\Models\Center;
use App\Models\Shift;
use App\Models\ShiftAssignment;
use App\Models\ShiftPlan;
use App\Models\ShiftPlanCompensation;
use App\Models\ShiftPoll;
use App\Models\ShiftPollReservation;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;

class ShiftPlanService
{
    // Allowed status flow
    public const STATUS_FLOW = [
        'draft',
        'polling_leaders',
        'polling_scouts',
        'polling_paramedics',
        'building',
        'published',
        'closed',
    ];

    // Business rule: every assigned shift is worth this many Syrian Pounds.
    public const COMPENSATION_PER_SHIFT = 500;

    public function createMonthlyPlan(int $month, int $year, ?int $createdBy = null): ShiftPlan
    {
        return DB::transaction(function () use ($month, $year, $createdBy) {
            $plan = ShiftPlan::create([
                'month' => $month,
                'year' => $year,
                'status' => 'draft',
                'created_by' => $createdBy,
            ]);

            $this->generateShifts($plan);

            return $plan;
        });
    }

    public function generateShifts(ShiftPlan $plan): Collection
    {
        return DB::transaction(function () use ($plan) {
            // generate all days for the month and all centers
            $daysInMonth = Carbon::create($plan->year, $plan->month, 1)->daysInMonth;
            $centers = Center::all();
            $types = ['morning', 'evening', 'night'];

            $created = new Collection();

            for ($d = 1; $d <= $daysInMonth; $d++) {
                $date = Carbon::create($plan->year, $plan->month, $d)->toDateString();

                foreach ($centers as $center) {
                    foreach ($types as $type) {
                        $shift = Shift::firstOrCreate([
                            'shift_plan_id' => $plan->id,
                            'center_id' => $center->id,
                            'date' => $date,
                            'type' => $type,
                        ], [
                            'team_number' => 2,
                        ]);

                        $created->push($shift);
                    }
                }
            }

            return $created;
        });
    }

    protected function assertStatusTransition(ShiftPlan $plan, string $expectedCurrent)
    {
        if ($plan->status !== $expectedCurrent) {
            throw new \RuntimeException("Invalid plan status: expected {$expectedCurrent}, got {$plan->status}");
        }
    }

    public function startLeaderPoll(ShiftPlan $plan): ShiftPlan
    {
        $this->assertStatusTransition($plan, 'draft');

        DB::transaction(function () use ($plan) {
            $plan->status = 'polling_leaders';
            $plan->save();

            // Every EMS member receives their own poll immediately when the
            // monthly poll opens, rather than waiting for their rank's turn
            // in the status flow. The status flow still gates buildSchedule().
            $this->createPollsForRole($plan, 'leader');
            $this->createPollsForRole($plan, 'scout');
            $this->createPollsForRole($plan, 'paramedic');
        });

        return $plan->fresh();
    }

    public function startScoutPoll(ShiftPlan $plan): ShiftPlan
    {
        $this->assertStatusTransition($plan, 'polling_leaders');

        DB::transaction(function () use ($plan) {
            $plan->status = 'polling_scouts';
            $plan->save();

            $this->createPollsForRole($plan, 'scout');
        });

        return $plan->fresh();
    }

    public function startParamedicPoll(ShiftPlan $plan): ShiftPlan
    {
        $this->assertStatusTransition($plan, 'polling_scouts');

        DB::transaction(function () use ($plan) {
            $plan->status = 'polling_paramedics';
            $plan->save();

            $this->createPollsForRole($plan, 'paramedic');
        });

        return $plan->fresh();
    }

    protected function createPollsForRole(ShiftPlan $plan, string $role): void
    {
        $users = User::where('role', 'paramedic')->where('rank', $role)->get();

        foreach ($users as $user) {
            // firstOrCreate: defaults only apply on insert, so a poll a user
            // already submitted during an earlier phase is never reset when
            // this is called again for their rank's own status transition.
            ShiftPoll::firstOrCreate([
                'shift_plan_id' => $plan->id,
                'user_id' => $user->id,
            ], [
                'role' => $role,
                'preferred_days' => [],
                'unavailable_days' => [],
                'status' => 'pending',
            ]);
        }
    }

    /**
     * Build the schedule strictly from confirmed reservations: one
     * ShiftAssignment per confirmed shift_poll_reservations row, no
     * fairness/preference backfill. A slot nobody reserved stays unfilled —
     * the published schedule must equal exactly what people reserved.
     */
    public function buildSchedule(ShiftPlan $plan): array
    {
        $this->assertStatusTransition($plan, 'polling_paramedics');

        return DB::transaction(function () use ($plan) {
            $plan->status = 'building';
            $plan->save();

            $shiftsBySlot = Shift::where('shift_plan_id', $plan->id)
                ->get()
                ->keyBy(fn ($s) => $s->center_id . '|' . (int) Carbon::parse($s->date)->day . '|' . $s->type);

            $reservations = ShiftPollReservation::where('shift_plan_id', $plan->id)
                ->where('status', 'confirmed')
                ->get();

            $unfilled = [];

            foreach ($reservations as $reservation) {
                $slotKey = $reservation->center_id . '|' . $reservation->day . '|' . $reservation->shift_type;
                $shift = $shiftsBySlot->get($slotKey);

                if (!$shift) {
                    $unfilled[] = [
                        'center_id' => $reservation->center_id,
                        'day' => $reservation->day,
                        'shift_type' => $reservation->shift_type,
                        'role' => $reservation->rank,
                        'reason' => 'no matching shift for reservation',
                    ];
                    continue;
                }

                ShiftAssignment::updateOrCreate(
                    [
                        'shift_id' => $shift->id,
                        'role' => $reservation->rank,
                        'team_number' => 1,
                    ],
                    [
                        'user_id' => $reservation->user_id,
                        'vehicle_id' => null,
                        'assigned_at' => now(),
                    ]
                );
            }

            return ['assignments' => ShiftAssignment::whereHas('shift', function ($q) use ($plan) {
                $q->where('shift_plan_id', $plan->id);
            })->get(), 'unfilled' => $unfilled];
        });
    }

    /**
     * Freeze the schedule: publishing must succeed even if the plan still has
     * unfilled slots — empty slots are an accepted, permanent outcome, not a
     * blocker. This also computes and stores each user's monthly compensation
     * (assigned shift count x COMPENSATION_PER_SHIFT) for this plan.
     */
    public function publishSchedule(ShiftPlan $plan): ShiftPlan
    {
        $this->assertStatusTransition($plan, 'building');

        return DB::transaction(function () use ($plan) {
            $counts = ShiftAssignment::whereHas('shift', function ($q) use ($plan) {
                $q->where('shift_plan_id', $plan->id);
            })->selectRaw('user_id, count(*) as cnt')->groupBy('user_id')->pluck('cnt', 'user_id');

            foreach ($counts as $userId => $count) {
                ShiftPlanCompensation::updateOrCreate(
                    ['shift_plan_id' => $plan->id, 'user_id' => $userId],
                    [
                        'monthly_shift_count' => $count,
                        'monthly_compensation' => $count * self::COMPENSATION_PER_SHIFT,
                    ]
                );
            }

            $plan->status = 'published';
            $plan->published_at = now();
            $plan->save();

            return $plan->fresh();
        });
    }

    /**
     * Center/day/shift/role grid for the admin Schedule Distribution page.
     * Reads ShiftAssignment (not reservations) so that approved shift swaps
     * — which mutate ShiftAssignment.user_id after publish — stay reflected
     * here. buildSchedule() now creates assignments 1:1 from confirmed
     * reservations with no backfill, so this is faithful to what was
     * actually reserved unless a swap has since changed it.
     */
    public function scheduleGrid(ShiftPlan $plan): array
    {
        $shifts = Shift::where('shift_plan_id', $plan->id)
            ->with(['center', 'assignments.user'])
            ->orderBy('date')
            ->orderBy('center_id')
            ->orderBy('type')
            ->get();

        $rows = [];

        foreach ($shifts as $shift) {
            $byRole = ['leader' => null, 'scout' => null, 'paramedic' => null];

            foreach ($shift->assignments as $assignment) {
                if (array_key_exists($assignment->role, $byRole)) {
                    $byRole[$assignment->role] = [
                        'user_id' => $assignment->user_id,
                        'name' => $assignment->user->name ?? null,
                    ];
                }
            }

            if (!$byRole['leader'] && !$byRole['scout'] && !$byRole['paramedic']) {
                continue;
            }

            $rows[] = [
                'shift_id' => $shift->id,
                'center' => $shift->center->name ?? null,
                'date' => $shift->date,
                'shift_type' => $shift->type,
                'leader' => $byRole['leader'],
                'scout' => $byRole['scout'],
                'paramedic' => $byRole['paramedic'],
            ];
        }

        return $rows;
    }

    public function closePlan(ShiftPlan $plan): ShiftPlan
    {
        $this->assertStatusTransition($plan, 'published');

        $plan->status = 'closed';
        $plan->save();

        return $plan->fresh();
    }
}
