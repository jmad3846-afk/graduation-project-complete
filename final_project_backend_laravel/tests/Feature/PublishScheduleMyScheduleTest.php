<?php

namespace Tests\Feature;

use App\Models\Center;
use App\Models\ShiftPlan;
use App\Models\ShiftPollReservation;
use App\Services\ShiftPlanService;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PublishScheduleMyScheduleTest extends TestCase
{
    use RefreshDatabase;

    public function test_publish_then_my_schedule_returns_correct_compensation_for_the_authenticated_user(): void
    {
        $center = Center::create(['name' => 'Center A', 'status' => 'active']);
        $admin = User::factory()->create(['role' => 'admin']);
        $leader = User::factory()->create(['role' => 'paramedic', 'rank' => 'leader']);
        User::factory()->create(['role' => 'paramedic', 'rank' => 'scout']);
        User::factory()->create(['role' => 'paramedic', 'rank' => 'paramedic']);

        $service = app(ShiftPlanService::class);
        $plan = $service->createMonthlyPlan(7, 2026);
        $plan = $service->startLeaderPoll($plan);
        $plan = $service->startScoutPoll($plan);
        $plan = $service->startParamedicPoll($plan);

        ShiftPollReservation::create([
            'shift_plan_id' => $plan->id,
            'center_id' => $center->id,
            'user_id' => $leader->id,
            'day' => 5,
            'shift_type' => 'morning',
            'rank' => 'leader',
            'status' => 'confirmed',
        ]);

        $this->actingAs($admin)
            ->postJson("/api/admin/shift-plans/{$plan->id}/build")
            ->assertStatus(200);

        $this->actingAs($admin)
            ->postJson("/api/admin/shift-plans/{$plan->id}/publish")
            ->assertStatus(200);

        $this->assertSame('published', $plan->fresh()->status);

        $response = $this->actingAs($leader)->getJson('/api/my-schedule');

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'month', 'year', 'compensation', 'shift_count', 'assignments',
        ]);

        $data = $response->json();
        $this->assertSame(7, $data['month']);
        $this->assertSame(2026, $data['year']);
        $this->assertGreaterThan(0, $data['shift_count']);
        $this->assertSame($data['shift_count'] * 500, $data['compensation']);

        foreach ($data['assignments'] as $assignment) {
            $this->assertArrayHasKey('center', $assignment);
            $this->assertArrayHasKey('date', $assignment);
            $this->assertArrayHasKey('shift_type', $assignment);
            $this->assertArrayHasKey('role', $assignment);
        }

        $this->actingAs($admin)
            ->postJson("/api/admin/shift-plans/{$plan->id}/send-schedule")
            ->assertStatus(200)
            ->assertJsonStructure(['message', 'notified_users']);
    }
}
