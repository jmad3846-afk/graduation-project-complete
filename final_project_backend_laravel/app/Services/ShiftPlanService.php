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

    public function buildSchedule(ShiftPlan $plan): array
    {
        $this->assertStatusTransition($plan, 'polling_paramedics');

        return DB::transaction(function () use ($plan) {
            // mark building
            $plan->status = 'building';
            $plan->save();

            // load polls
            $polls = ShiftPoll::where('shift_plan_id', $plan->id)->get();

            // candidate pools by role
            $candidates = [
                'leader' => User::where('role', 'paramedic')->where('rank', 'leader')->get(),
                'scout' => User::where('role', 'paramedic')->where('rank', 'scout')->get(),
                'paramedic' => User::where('role', 'paramedic')->where('rank', 'paramedic')->get(),
            ];

            // track assignment counts to distribute fairly
            $assignmentCounts = [];

            foreach (User::all() as $u) {
                $assignmentCounts[$u->id] = 0;
            }

            $unfilled = [];

            // Stage 1: resolve WHO works and WHERE, directly from confirmed
            // reservations. A reservation now identifies an exact
            // (center_id, day, shift_type, rank) slot chosen by the user
            // themself — the scheduler no longer decides center for reserved
            // users, it only converts the reservation into an assignment.
            // Built once, reused by every shift lookup below (stage 2) instead
            // of re-querying reservations per shift.
            $mandatoryUserIdsBySlot = ShiftPollReservation::where('shift_plan_id', $plan->id)
                ->where('status', 'confirmed')
                ->get()
                ->keyBy(fn ($r) => $r->center_id . '|' . $r->day . '|' . $r->shift_type . '|' . $r->rank)
                ->map(fn ($r) => $r->user_id);

            // iterate shifts in date order
            $shifts = Shift::where('shift_plan_id', $plan->id)->orderBy('date')->orderBy('center_id')->orderBy('type')->get();

            // Stage 2: distribute the resolved people (mandatory reservations
            // first, then normal fairness/eligibility) across centers using the
            // existing per-shift iteration — unchanged team/fairness/no-duplicate
            // rules, just center selection instead of reservation-driven pinning.
            foreach ($shifts as $shift) {
                for ($team = 1; $team <= $shift->team_number; $team++) {
                    $assignedIds = [];

                    foreach (['leader', 'scout', 'paramedic'] as $role) {
                        $user = $this->pickCandidateForRole($role, $shift, $candidates[$role], $assignmentCounts, $plan, $mandatoryUserIdsBySlot);

                        if ($user) {
                            $assignment = ShiftAssignment::create([
                                'shift_id' => $shift->id,
                                'user_id' => $user->id,
                                'role' => $role,
                                'team_number' => $team,
                                'vehicle_id' => null,
                                'assigned_at' => now(),
                            ]);

                            $assignmentCounts[$user->id] = ($assignmentCounts[$user->id] ?? 0) + 1;
                            $assignedIds[] = $user->id;
                        } else {
                            $unfilled[] = [
                                'shift_id' => $shift->id,
                                'team' => $team,
                                'role' => $role,
                            ];
                        }
                    }
                }
            }

            return ['assignments' => ShiftAssignment::whereHas('shift', function ($q) use ($plan) {
                $q->where('shift_plan_id', $plan->id);
            })->get(), 'unfilled' => $unfilled];
        });
    }

    protected function pickCandidateForRole(string $role, Shift $shift, Collection $pool, array $assignmentCounts, ShiftPlan $plan, $mandatoryUserIdsBySlot = null): ?User
    {
        $date = Carbon::parse($shift->date);
        $day = (int) $date->day;

        // Confirmed reservations are the primary source of truth for this
        // exact (center_id, day, shift_type, rank) slot — the user chose the
        // center themself when reserving, so the scheduler only converts the
        // reservation into an assignment here; it never picks a different
        // center for a reserved user.
        $reservedUserId = $mandatoryUserIdsBySlot[$shift->center_id . '|' . $day . '|' . $shift->type . '|' . $role] ?? null;

        if ($reservedUserId !== null) {
            $reservedUser = $pool->firstWhere('id', $reservedUserId);

            if ($reservedUser) {
                $hasSameDay = ShiftAssignment::where('user_id', $reservedUser->id)
                    ->whereHas('shift', function ($q) use ($date) {
                        $q->whereDate('date', $date->toDateString());
                    })->exists();

                if (!$hasSameDay) {
                    return $reservedUser;
                }
            }
        }

        $candidates = $pool->filter(function ($user) use ($date, $day, $plan, $shift, $mandatoryUserIdsBySlot) {
            // user cannot work two shifts on same day
            $hasSameDay = ShiftAssignment::where('user_id', $user->id)->whereHas('shift', function ($q) use ($date) {
                $q->whereDate('date', $date->toDateString());
            })->exists();

            if ($hasSameDay) {
                return false;
            }

            // Don't let the legacy fallback consume a user on an earlier shift
            // the same day when that user holds a confirmed reservation for a
            // *different* (center, shift_type) slot later that day — the
            // reservation must win regardless of which shift/center happens to
            // be processed first.
            $reservedElsewhereToday = false;
            if ($mandatoryUserIdsBySlot !== null) {
                foreach ($mandatoryUserIdsBySlot as $slotKey => $mandatoryUserId) {
                    if ($mandatoryUserId !== $user->id) {
                        continue;
                    }
                    [$slotCenterId, $slotDay, $slotType, $slotRank] = explode('|', $slotKey);
                    $isSameShift = (int) $slotCenterId === (int) $shift->center_id && $slotType === $shift->type;
                    if ((int) $slotDay === $day && !$isSameShift) {
                        $reservedElsewhereToday = true;
                        break;
                    }
                }
            }

            if ($reservedElsewhereToday) {
                return false;
            }

            $poll = ShiftPoll::where('shift_plan_id', $plan->id)->where('user_id', $user->id)->first();

            if ($poll) {
                if (!empty($poll->unavailable_days)) {
                    foreach ($poll->unavailable_days as $ud) {
                        if (is_array($ud) && isset($ud['day']) && (isset($ud['shift']) || isset($ud['shift_type']))) {
                            $shiftKey = $ud['shift'] ?? $ud['shift_type'];
                            if ((int)$ud['day'] === $day && $shiftKey === $shift->type) {
                                return false;
                            }
                        } else {
                            if (is_numeric($ud) && (int)$ud === $day) return false;
                            if (is_string($ud) && \Illuminate\Support\Str::startsWith($ud, (string)$date->toDateString())) return false;
                        }
                    }
                }
            }
                // Preferred shift check
                if ($poll && !empty($poll->preferred_days)) {
                    $hasPreferred = false;
                    foreach ($poll->preferred_days as $ps) {
                        if (is_array($ps) && isset($ps['day']) && (isset($ps['shift']) || isset($ps['shift_type']))) {
                            $prefKey = $ps['shift'] ?? $ps['shift_type'];
                            if ((int)$ps['day'] === $day && $prefKey === $shift->type) {
                                $hasPreferred = true;
                                break;
                            }
                        }
                    }
                    if (!$hasPreferred) {
                        return false;
                    }
                }

            return true;
        });

        if ($candidates->isEmpty()) return null;

        // distribute fairly: prefer the candidate with the fewest assignments so far
        $best = null;
        $bestCount = null;

        foreach ($candidates as $candidate) {
            $count = $assignmentCounts[$candidate->id] ?? 0;

            if ($bestCount === null || $count < $bestCount) {
                $best = $candidate;
                $bestCount = $count;
            }
        }

        return $best;
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
     * Center/day/shift/role grid for the admin Schedule Distribution page,
     * built directly from confirmed shift_poll_reservations rather than the
     * scheduler's ShiftAssignment output — one box per (center, day,
     * shift_type), with a role left null if nobody reserved that slot.
     */
    public function scheduleGrid(ShiftPlan $plan): array
    {
        $reservations = ShiftPollReservation::where('shift_plan_id', $plan->id)
            ->where('status', 'confirmed')
            ->with(['center', 'user'])
            ->get();

        $groups = $reservations->groupBy(fn ($r) => $r->center_id . '|' . $r->day . '|' . $r->shift_type);

        $rows = [];

        foreach ($groups as $key => $group) {
            [$centerId, $day, $shiftType] = explode('|', $key);

            $byRole = ['leader' => null, 'scout' => null, 'paramedic' => null];

            foreach ($group as $reservation) {
                if (array_key_exists($reservation->rank, $byRole)) {
                    $byRole[$reservation->rank] = [
                        'user_id' => $reservation->user_id,
                        'name' => $reservation->user->name ?? null,
                    ];
                }
            }

            $date = Carbon::create($plan->year, $plan->month, (int) $day)->toDateString();

            $rows[] = [
                'center' => $group->first()->center->name ?? null,
                'date' => $date,
                'shift_type' => $shiftType,
                'leader' => $byRole['leader'],
                'scout' => $byRole['scout'],
                'paramedic' => $byRole['paramedic'],
            ];
        }

        usort($rows, function ($a, $b) {
            return [$a['date'], $a['center'], $a['shift_type']] <=> [$b['date'], $b['center'], $b['shift_type']];
        });

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
