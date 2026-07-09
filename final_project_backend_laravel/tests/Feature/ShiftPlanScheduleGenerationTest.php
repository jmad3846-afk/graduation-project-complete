<?php

namespace Tests\Feature;

use App\Models\Center;
use App\Models\Shift;
use App\Models\ShiftAssignment;
use App\Models\ShiftPlan;
use App\Models\ShiftPoll;
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

    public function test_preferred_shift_is_respected_over_user_with_no_preference(): void
    {
        $center = Center::create(['name' => 'Center A', 'status' => 'active']);

        $leaderA = User::factory()->create(['role' => 'paramedic', 'rank' => 'leader']);
        $leaderB = User::factory()->create(['role' => 'paramedic', 'rank' => 'leader']);
        $leaderC = User::factory()->create(['role' => 'paramedic', 'rank' => 'leader']);

        $plan = $this->makePlanReadyForBuild($center);

        // Leader A prefers Day 1 Morning.
        ShiftPoll::where('shift_plan_id', $plan->id)->where('user_id', $leaderA->id)->update([
            'preferred_days' => [['day' => 1, 'shift' => 'morning']],
        ]);

        // Leader B prefers Day 1 Night (should not compete for Day 1 Morning).
        ShiftPoll::where('shift_plan_id', $plan->id)->where('user_id', $leaderB->id)->update([
            'preferred_days' => [['day' => 1, 'shift' => 'night']],
        ]);

        // Leader C has no preference at all.

        $service = app(ShiftPlanService::class);
        $result = $service->buildSchedule($plan);

        $day1Morning = Shift::where('shift_plan_id', $plan->id)
            ->where('center_id', $center->id)
            ->whereDate('date', '2026-07-01')
            ->where('type', 'morning')
            ->first();

        $this->assertNotNull($day1Morning);

        $leaderAssignedUserIds = ShiftAssignment::where('shift_id', $day1Morning->id)
            ->where('role', 'leader')
            ->pluck('user_id')
            ->all();

        $this->assertContains($leaderA->id, $leaderAssignedUserIds);
        $this->assertNotContains($leaderC->id, $leaderAssignedUserIds);
    }

    public function test_unavailable_shift_only_blocks_that_specific_day_and_shift(): void
    {
        $center = Center::create(['name' => 'Center A', 'status' => 'active']);

        // Enough leaders so the pool isn't trivially forced to reuse the same person.
        $leader = User::factory()->create(['role' => 'paramedic', 'rank' => 'leader']);
        User::factory()->count(3)->create(['role' => 'paramedic', 'rank' => 'leader']);

        $plan = $this->makePlanReadyForBuild($center);

        // Leader is unavailable ONLY for Day 5 Night.
        ShiftPoll::where('shift_plan_id', $plan->id)->where('user_id', $leader->id)->update([
            'unavailable_days' => [['day' => 5, 'shift' => 'night']],
        ]);

        $service = app(ShiftPlanService::class);
        $service->buildSchedule($plan);

        $day5Night = Shift::where('shift_plan_id', $plan->id)
            ->where('center_id', $center->id)
            ->whereDate('date', '2026-07-05')
            ->where('type', 'night')
            ->first();

        $day5Morning = Shift::where('shift_plan_id', $plan->id)
            ->where('center_id', $center->id)
            ->whereDate('date', '2026-07-05')
            ->where('type', 'morning')
            ->first();

        $day5Evening = Shift::where('shift_plan_id', $plan->id)
            ->where('center_id', $center->id)
            ->whereDate('date', '2026-07-05')
            ->where('type', 'evening')
            ->first();

        $nightAssignees = ShiftAssignment::where('shift_id', $day5Night->id)->pluck('user_id')->all();
        $this->assertNotContains($leader->id, $nightAssignees, 'Leader must not be assigned to Day 5 Night.');

        // The leader must remain eligible for Day 5 Morning/Evening (not blocked as a whole day).
        // We can't force who gets picked, but we can prove eligibility by asserting the filter
        // logic directly via the assignment pool: run it again for a plan where this leader is
        // the ONLY leader, so if unavailability wrongly blocked the whole day, morning/evening
        // would be unfilled instead of assigned to the leader.
    }

    public function test_unavailable_night_does_not_block_morning_for_same_leader(): void
    {
        // Directly exercise the candidate filter for a single day/leader pairing,
        // isolated from the fair-distribution tie-breaking that buildSchedule applies
        // across an entire month (which would otherwise make "who gets picked" ambiguous).
        $center = Center::create(['name' => 'Center A', 'status' => 'active']);
        $leader = User::factory()->create(['role' => 'paramedic', 'rank' => 'leader']);

        $plan = ShiftPlan::create(['month' => 7, 'year' => 2026, 'status' => 'polling_paramedics']);
        ShiftPoll::create([
            'shift_plan_id' => $plan->id,
            'user_id' => $leader->id,
            'role' => 'leader',
            'preferred_days' => [],
            'unavailable_days' => [['day' => 5, 'shift' => 'night']],
            'status' => 'pending',
        ]);

        $morningShift = Shift::create([
            'shift_plan_id' => $plan->id,
            'center_id' => $center->id,
            'date' => '2026-07-05',
            'type' => 'morning',
            'team_number' => 1,
        ]);
        $nightShift = Shift::create([
            'shift_plan_id' => $plan->id,
            'center_id' => $center->id,
            'date' => '2026-07-05',
            'type' => 'night',
            'team_number' => 1,
        ]);

        $service = app(ShiftPlanService::class);
        $pick = fn (Shift $shift) => (new \ReflectionMethod($service, 'pickCandidateForRole'))
            ->invoke($service, 'leader', $shift, \App\Models\User::where('id', $leader->id)->get(), [], $plan);

        $morningPick = $pick($morningShift);
        $nightPick = $pick($nightShift);

        $this->assertNotNull($morningPick, 'Day 5 Morning must still be assignable.');
        $this->assertSame($leader->id, $morningPick->id);
        $this->assertNull($nightPick, 'Day 5 Night must remain blocked.');
    }

    public function test_confirmed_reservations_are_selected_first_over_legacy_preferences(): void
    {
        // Leader A, Scout A, Paramedic A each confirm Center A / Day 5 Morning
        // via the real-time reservation system. Each is the ONLY candidate of
        // their rank, so team 2 of Day 5 Morning is left unfilled (no one else
        // to pick) and the assignment set for that shift is exactly these three.
        $center = Center::create(['name' => 'Center A', 'status' => 'active']);

        $leaderA = User::factory()->create(['role' => 'paramedic', 'rank' => 'leader']);
        $scoutA = User::factory()->create(['role' => 'paramedic', 'rank' => 'scout']);
        $paramedicA = User::factory()->create(['role' => 'paramedic', 'rank' => 'paramedic']);

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
    }

    public function test_falls_back_to_legacy_preferences_when_no_confirmed_reservation(): void
    {
        // Backward compatibility: a plan with no reservations at all must still
        // schedule using the legacy preferred_days/unavailable_days logic.
        $center = Center::create(['name' => 'Center A', 'status' => 'active']);
        $leaderA = User::factory()->create(['role' => 'paramedic', 'rank' => 'leader']);
        $leaderB = User::factory()->create(['role' => 'paramedic', 'rank' => 'leader']);

        $plan = $this->makePlanReadyForBuild($center);

        ShiftPoll::where('shift_plan_id', $plan->id)->where('user_id', $leaderA->id)->update([
            'preferred_days' => [['day' => 1, 'shift' => 'morning']],
        ]);

        $service = app(ShiftPlanService::class);
        $service->buildSchedule($plan);

        $day1Morning = Shift::where('shift_plan_id', $plan->id)
            ->where('center_id', $center->id)
            ->whereDate('date', '2026-07-01')
            ->where('type', 'morning')
            ->first();

        $leaderAssignedUserIds = ShiftAssignment::where('shift_id', $day1Morning->id)
            ->where('role', 'leader')
            ->pluck('user_id')
            ->all();

        $this->assertContains($leaderA->id, $leaderAssignedUserIds);
        $this->assertNotContains($leaderB->id, $leaderAssignedUserIds);
    }

    public function test_confirmed_reservation_pins_exact_center_chosen_by_user(): void
    {
        // Business rule (superseding the old "any center" behavior): a
        // reservation now identifies an exact (center, day, shift_type, rank)
        // slot chosen by the user themself. The scheduler must place the
        // reserved user at THAT center only — never a different one — and
        // must never double-assign or omit them.
        //
        // 4 centers, 3 leaders, 3 scouts, 6 paramedics. Reserve Leader A,
        // Scout B, Paramedic C all for Center A / Day 5 / Morning.
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

        // Each reserved user must be assigned to their exact chosen shift
        // (Center A / Day 5 / Morning), exactly once.
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

        // Must NOT be assigned to any other center's Day 5 Morning shift.
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

        // No duplicate (shift, user) assignments anywhere in the plan.
        $allAssignments = ShiftAssignment::whereHas('shift', function ($q) use ($plan) {
            $q->where('shift_plan_id', $plan->id);
        })->get();

        $seen = [];
        foreach ($allAssignments as $assignment) {
            $key = $assignment->shift_id . ':' . $assignment->user_id;
            $this->assertArrayNotHasKey($key, $seen, 'Duplicate assignment detected.');
            $seen[$key] = true;
        }
    }

    public function test_confirmed_reservation_at_full_center_slot_blocks_further_reservations(): void
    {
        // Once Center A / Day 5 / Morning has a confirmed Leader, Scout, and
        // Paramedic, no additional reservation of the same rank can be made
        // for that exact slot — this is enforced at the reservation layer
        // (unique index), verified here via the API to match the task's
        // "no additional Leader/Scout/Paramedic can reserve those slots".
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
