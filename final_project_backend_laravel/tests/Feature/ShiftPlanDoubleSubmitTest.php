<?php

namespace Tests\Feature;

use App\Models\Center;
use App\Models\ShiftAssignment;
use App\Models\ShiftPlan;
use App\Models\User;
use App\Services\ShiftPlanService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ShiftPlanDoubleSubmitTest extends TestCase
{
    use RefreshDatabase;

    protected function makePlanReadyForBuild(): ShiftPlan
    {
        Center::create(['name' => 'Center A', 'status' => 'active']);
        User::factory()->create(['role' => 'paramedic', 'rank' => 'leader']);
        User::factory()->create(['role' => 'paramedic', 'rank' => 'scout']);
        User::factory()->create(['role' => 'paramedic', 'rank' => 'paramedic']);

        $service = app(ShiftPlanService::class);
        $plan = $service->createMonthlyPlan(7, 2026);
        $plan = $service->startLeaderPoll($plan);
        $plan = $service->startScoutPoll($plan);
        $plan = $service->startParamedicPoll($plan);

        return $plan;
    }

    public function test_double_submitting_build_never_returns_a_raw_500_and_never_duplicates_assignments(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $plan = $this->makePlanReadyForBuild();

        $first = $this->actingAs($admin)->postJson("/api/admin/shift-plans/{$plan->id}/build");
        $first->assertStatus(200);

        // Simulates a double-tap: the plan is already past polling_paramedics
        // by the time this second request runs.
        $second = $this->actingAs($admin)->postJson("/api/admin/shift-plans/{$plan->id}/build");
        $second->assertStatus(200);
        $second->assertJsonPath('status', 'building');

        $this->assertSame('building', $plan->fresh()->status);

        $assignments = ShiftAssignment::whereHas('shift', function ($q) use ($plan) {
            $q->where('shift_plan_id', $plan->id);
        })->get();

        // The second call must not have run buildSchedule() again and
        // duplicated every assignment.
        $this->assertGreaterThan(0, $assignments->count());

        $seen = [];
        foreach ($assignments as $assignment) {
            $key = $assignment->shift_id . ':' . $assignment->user_id . ':' . $assignment->role;
            $this->assertArrayNotHasKey($key, $seen, 'Duplicate assignment detected after double-submit.');
            $seen[$key] = true;
        }
    }

    public function test_double_submitting_publish_never_returns_a_raw_500(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $plan = $this->makePlanReadyForBuild();

        $this->actingAs($admin)->postJson("/api/admin/shift-plans/{$plan->id}/build")->assertStatus(200);

        $firstPublish = $this->actingAs($admin)->postJson("/api/admin/shift-plans/{$plan->id}/publish");
        $firstPublish->assertStatus(200)->assertJsonPath('message', 'Published');

        $secondPublish = $this->actingAs($admin)->postJson("/api/admin/shift-plans/{$plan->id}/publish");
        $secondPublish->assertStatus(200);
        $secondPublish->assertJsonPath('status', 'published');

        $this->assertSame('published', $plan->fresh()->status);
    }

    public function test_publish_before_build_returns_409_not_a_raw_500(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $plan = $this->makePlanReadyForBuild();

        // Plan is still at polling_paramedics; publish is invalid at this stage
        // and there's no later status to fall back to, so this must be a clean 409.
        $response = $this->actingAs($admin)->postJson("/api/admin/shift-plans/{$plan->id}/publish");
        $response->assertStatus(409);
    }
}
