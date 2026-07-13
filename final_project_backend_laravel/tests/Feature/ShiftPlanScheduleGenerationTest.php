<?php

namespace Tests\Feature;

use App\Models\Center;
use App\Models\Shift;
use App\Models\ShiftAssignment;
use App\Models\ShiftPlan;
use App\Models\ShiftPollReservation;
use App\Models\User;
use App\Services\ShiftPlanService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ShiftPlanScheduleGenerationTest extends TestCase
{
    use RefreshDatabase;

    protected function makePlanReadyForBuild(Center $center): ShiftPlan
    {
        $service = app(ShiftPlanService::class);

        $plan = $service->createMonthlyPlan(7, 2026);
        $plan = $service->startLeaderPoll($plan);
        $plan = $service->startScoutPoll($plan);
        $plan = $service->startParamedicPoll($plan);

        return $plan;
    }

    public function test_build_schedule_creates_assignments_only_for_confirmed_reservations(): void
    {
        // Business rule: the published schedule must equal exactly what
        // people reserved and confirmed — no fairness/preference backfill.
        $center = Center::create(['name' => 'Center A', 'status' => 'active']);

        $leaderA = User::factory()->create(['role' => 'paramedic', 'rank' => 'leader']);
        $scoutA = User::factory()->create(['role' => 'paramedic', 'rank' => 'scout']);
        $paramedicA = User::factory()->create(['role' => 'paramedic', 'rank' => 'paramedic']);

        // Extra candidates who never reserved anything — must never be
        // auto-assigned to fill other shifts in the month.
        User::factory()->count(2)->create(['role' => 'paramedic', 'rank' => 'leader']);

        $plan = $this->makePlanReadyForBuild($center);

        foreach ([
            ['user' => $leaderA, 'rank' => 'leader'],
            ['user' => $scoutA, 'rank' => 'scout'],
            ['user' => $paramedicA, 'rank' => 'paramedic'],
        ] as $entry) {
            ShiftPollReservation::create([
                'shift_plan_id' => $plan->id,
                'center_id' => $center->id,
                'user_id' => $entry['user']->id,
                'day' => 5,
                'shift_type' => 'morning',
                'rank' => $entry['rank'],
                'status' => 'confirmed',
                'expires_at' => null,
            ]);
        }

        $service = app(ShiftPlanService::class);
        $service->buildSchedule($plan);

        $day5Morning = Shift::where('shift_plan_id', $plan->id)
            ->where('center_id', $center->id)
            ->whereDate('date', '2026-07-05')
            ->where('type', 'morning')
            ->first();

        $this->assertNotNull($day5Morning);

        $assignedUserIds = ShiftAssignment::where('shift_id', $day5Morning->id)
            ->pluck('user_id')
            ->sort()
            ->values()
            ->all();

        $expected = collect([$leaderA->id, $scoutA->id, $paramedicA->id])->sort()->values()->all();

        $this->assertSame($expected, $assignedUserIds, 'Day 5 Morning must contain exactly the three reserved users.');

        // No reservations anywhere else in the plan, so no other assignment
        // may exist at all — proves there is no backfill.
        $totalAssignments = ShiftAssignment::whereHas('shift', function ($q) use ($plan) {
            $q->where('shift_plan_id', $plan->id);
        })->count();

        $this->assertSame(3, $totalAssignments);
    }

    public function test_build_schedule_leaves_slot_empty_with_no_reservations(): void
    {
        $center = Center::create(['name' => 'Center A', 'status' => 'active']);
        User::factory()->create(['role' => 'paramedic', 'rank' => 'leader']);

        $plan = $this->makePlanReadyForBuild($center);

        $service = app(ShiftPlanService::class);
        $result = $service->buildSchedule($plan);

        $this->assertCount(0, $result['assignments']);
    }

    public function test_confirmed_reservation_pins_exact_center_chosen_by_user(): void
    {
        // A reservation identifies an exact (center, day, shift_type, rank)
        // slot chosen by the user themself. The scheduler must place the
        // reserved user at THAT center only — never a different one — and
        // must never double-assign or omit them.
        $centers = collect(range(1, 4))->map(fn ($i) => Center::create([
            'name' => "Center $i",
            'status' => 'active',
        ]));
        $centerA = $centers->first();

        $leaders = User::factory()->count(3)->create(['role' => 'paramedic', 'rank' => 'leader']);
        $scouts = User::factory()->count(3)->create(['role' => 'paramedic', 'rank' => 'scout']);
        $paramedics = User::factory()->count(6)->create(['role' => 'paramedic', 'rank' => 'paramedic']);

        $leaderA = $leaders[0];
        $scoutB = $scouts[1];
        $paramedicC = $paramedics[2];

        $service = app(ShiftPlanService::class);
        $plan = $service->createMonthlyPlan(7, 2026);
        $plan = $service->startLeaderPoll($plan);
        $plan = $service->startScoutPoll($plan);
        $plan = $service->startParamedicPoll($plan);

        foreach ([
            ['user' => $leaderA, 'rank' => 'leader'],
            ['user' => $scoutB, 'rank' => 'scout'],
            ['user' => $paramedicC, 'rank' => 'paramedic'],
        ] as $entry) {
            ShiftPollReservation::create([
                'shift_plan_id' => $plan->id,
                'center_id' => $centerA->id,
                'user_id' => $entry['user']->id,
                'day' => 5,
                'shift_type' => 'morning',
                'rank' => $entry['rank'],
                'status' => 'confirmed',
                'expires_at' => null,
            ]);
        }

        $service->buildSchedule($plan);

        $centerAShift = Shift::where('shift_plan_id', $plan->id)
            ->where('center_id', $centerA->id)
            ->whereDate('date', '2026-07-05')
            ->where('type', 'morning')
            ->first();

        $this->assertNotNull($centerAShift);

        foreach ([$leaderA, $scoutB, $paramedicC] as $reservedUser) {
            $this->assertDatabaseHas('shift_assignments', [
                'shift_id' => $centerAShift->id,
                'user_id' => $reservedUser->id,
            ]);

            $countEverywhere = ShiftAssignment::whereHas('shift', function ($q) use ($plan) {
                $q->where('shift_plan_id', $plan->id)->whereDate('date', '2026-07-05')->where('type', 'morning');
            })->where('user_id', $reservedUser->id)->count();

            $this->assertSame(1, $countEverywhere, "User {$reservedUser->id} must appear exactly once for Day 5 Morning, at Center A only.");
        }

        $otherCenterShiftIds = Shift::where('shift_plan_id', $plan->id)
            ->where('center_id', '!=', $centerA->id)
            ->whereDate('date', '2026-07-05')
            ->where('type', 'morning')
            ->pluck('id');

        foreach ([$leaderA, $scoutB, $paramedicC] as $reservedUser) {
            $this->assertSame(
                0,
                ShiftAssignment::whereIn('shift_id', $otherCenterShiftIds)->where('user_id', $reservedUser->id)->count(),
                "User {$reservedUser->id} must not appear at any other center for Day 5 Morning."
            );
        }
    }

    public function test_confirmed_reservation_at_full_center_slot_blocks_further_reservations(): void
    {
        // Once Center A / Day 5 / Morning has a confirmed Leader, no
        // additional reservation of the same rank can be made for that exact
        // slot — enforced at the reservation layer (unique index).
        $plan = ShiftPlan::create(['month' => 7, 'year' => 2026, 'status' => 'polling_leaders']);
        $centerA = Center::create(['name' => 'Center A', 'status' => 'active']);

        $leaderA = User::factory()->create(['role' => 'paramedic', 'rank' => 'leader']);
        $leaderD = User::factory()->create(['role' => 'paramedic', 'rank' => 'leader']);

        $this->actingAs($leaderA)->postJson("/api/shift-plans/{$plan->id}/reserve", [
            'center_id' => $centerA->id,
            'day' => 5,
            'shift_type' => 'morning',
            'rank' => 'leader',
        ])->assertStatus(201);

        $response = $this->actingAs($leaderD)->postJson("/api/shift-plans/{$plan->id}/reserve", [
            'center_id' => $centerA->id,
            'day' => 5,
            'shift_type' => 'morning',
            'rank' => 'leader',
        ]);

        $response->assertStatus(409);
    }

    public function test_build_schedule_completes_without_type_errors(): void
    {
        $center = Center::create(['name' => 'Center A', 'status' => 'active']);
        User::factory()->count(2)->create(['role' => 'paramedic', 'rank' => 'leader']);
        User::factory()->count(2)->create(['role' => 'paramedic', 'rank' => 'scout']);
        User::factory()->count(2)->create(['role' => 'paramedic', 'rank' => 'paramedic']);

        $plan = $this->makePlanReadyForBuild($center);

        $service = app(ShiftPlanService::class);
        $result = $service->buildSchedule($plan);

        $this->assertArrayHasKey('assignments', $result);
        $this->assertArrayHasKey('unfilled', $result);
        $this->assertSame('building', $plan->fresh()->status);
    }
}
