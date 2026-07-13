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

        // Right after publish, the leader has a scheduled assignment but has
        // not checked in yet — compensation must be 0 until attended.
        $beforeCheckIn = $this->actingAs($leader)->getJson('/api/my-schedule');

        $beforeCheckIn->assertStatus(200);
        $beforeCheckIn->assertJsonStructure([
            'month', 'year', 'compensation', 'shift_count', 'assignments',
        ]);

        $beforeData = $beforeCheckIn->json();
        $this->assertSame(7, $beforeData['month']);
        $this->assertSame(2026, $beforeData['year']);
        $this->assertSame(0, $beforeData['shift_count']);
        $this->assertSame(0, $beforeData['compensation']);
        $this->assertNotEmpty($beforeData['assignments']);

        foreach ($beforeData['assignments'] as $assignment) {
            $this->assertArrayHasKey('center', $assignment);
            $this->assertArrayHasKey('date', $assignment);
            $this->assertArrayHasKey('shift_type', $assignment);
            $this->assertArrayHasKey('role', $assignment);
        }

        // Checking in flips the assignment to "done" — now it must count.
        $assignmentId = $beforeData['assignments'][0]['id'];

        $this->actingAs($admin)
            ->postJson("/api/shift-assignments/{$assignmentId}/check-in")
            ->assertStatus(200);

        $afterCheckIn = $this->actingAs($leader)->getJson('/api/my-schedule');
        $afterData = $afterCheckIn->json();

        $this->assertSame(1, $afterData['shift_count']);
        $this->assertSame(500, $afterData['compensation']);

        $this->actingAs($admin)
            ->postJson("/api/admin/shift-plans/{$plan->id}/send-schedule")
            ->assertStatus(200)
            ->assertJsonStructure(['message', 'notified_users']);
    }
}
