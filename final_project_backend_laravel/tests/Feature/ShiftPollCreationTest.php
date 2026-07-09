<?php

namespace Tests\Feature;

use App\Models\ShiftPlan;
use App\Models\ShiftPoll;
use App\Models\User;
use App\Services\ShiftPlanService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ShiftPollCreationTest extends TestCase
{
    use RefreshDatabase;

    protected function makeUser(string $rank): User
    {
        return User::factory()->create(['role' => 'paramedic', 'rank' => $rank]);
    }

    public function test_starting_leader_poll_creates_polls_for_all_ranks_immediately(): void
    {
        $leader = $this->makeUser('leader');
        $scout = $this->makeUser('scout');
        $paramedic = $this->makeUser('paramedic');

        $plan = ShiftPlan::create(['month' => 7, 'year' => 2026, 'status' => 'draft']);

        app(ShiftPlanService::class)->startLeaderPoll($plan);

        $this->assertDatabaseHas('shift_polls', [
            'shift_plan_id' => $plan->id,
            'user_id' => $leader->id,
            'role' => 'leader',
            'status' => 'pending',
        ]);
        $this->assertDatabaseHas('shift_polls', [
            'shift_plan_id' => $plan->id,
            'user_id' => $scout->id,
            'role' => 'scout',
            'status' => 'pending',
        ]);
        $this->assertDatabaseHas('shift_polls', [
            'shift_plan_id' => $plan->id,
            'user_id' => $paramedic->id,
            'role' => 'paramedic',
            'status' => 'pending',
        ]);

        $this->assertSame(3, ShiftPoll::where('shift_plan_id', $plan->id)->count());
    }

    public function test_all_three_ranks_receive_current_poll_via_api_immediately(): void
    {
        $leader = $this->makeUser('leader');
        $scout = $this->makeUser('scout');
        $paramedic = $this->makeUser('paramedic');

        $plan = ShiftPlan::create(['month' => 7, 'year' => 2026, 'status' => 'draft']);
        app(ShiftPlanService::class)->startLeaderPoll($plan);

        foreach ([$leader, $scout, $paramedic] as $user) {
            $response = $this->actingAs($user)->getJson('/api/shift-polls/current');
            $response->assertOk();
            $response->assertJsonPath('data.role', $user->rank);
        }
    }

    public function test_submitted_poll_is_not_reset_when_scout_phase_starts(): void
    {
        $scout = $this->makeUser('scout');
        $this->makeUser('leader');

        $plan = ShiftPlan::create(['month' => 7, 'year' => 2026, 'status' => 'draft']);
        $service = app(ShiftPlanService::class);
        $service->startLeaderPoll($plan);

        $poll = ShiftPoll::where('shift_plan_id', $plan->id)->where('user_id', $scout->id)->first();
        $poll->update([
            'preferred_days' => [1, 2, 3],
            'status' => 'submitted',
        ]);

        // Advancing to the scout phase re-runs poll creation for scouts;
        // it must not wipe the submission that already happened.
        $service->startScoutPoll($plan->fresh());

        $poll->refresh();
        $this->assertSame('submitted', $poll->status);
        $this->assertSame([1, 2, 3], $poll->preferred_days);
    }
}
