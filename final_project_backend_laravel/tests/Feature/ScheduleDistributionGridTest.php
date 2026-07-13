<?php

namespace Tests\Feature;

use App\Models\Center;
use App\Models\ShiftPlan;
use App\Models\ShiftPollReservation;
use App\Models\User;
use App\Services\ShiftPlanService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ScheduleDistributionGridTest extends TestCase
{
    use RefreshDatabase;

    public function test_schedule_grid_reflects_assignments_built_from_confirmed_reservations(): void
    {
        $center = Center::create(['name' => 'Center A', 'status' => 'active']);
        $leader = User::factory()->create(['role' => 'paramedic', 'rank' => 'leader']);
        $scout = User::factory()->create(['role' => 'paramedic', 'rank' => 'scout']);

        $service = app(ShiftPlanService::class);
        $plan = $service->createMonthlyPlan(7, 2026);
        $plan = $service->startLeaderPoll($plan);
        $plan = $service->startScoutPoll($plan);
        $plan = $service->startParamedicPoll($plan);

        ShiftPollReservation::create([
            'shift_plan_id' => $plan->id,
            'center_id' => $center->id,
            'user_id' => $leader->id,
            'day' => 10,
            'shift_type' => 'morning',
            'rank' => 'leader',
            'status' => 'confirmed',
        ]);

        ShiftPollReservation::create([
            'shift_plan_id' => $plan->id,
            'center_id' => $center->id,
            'user_id' => $scout->id,
            'day' => 10,
            'shift_type' => 'morning',
            'rank' => 'scout',
            'status' => 'confirmed',
        ]);

        // Not confirmed yet: must not become an assignment or appear in the grid.
        ShiftPollReservation::create([
            'shift_plan_id' => $plan->id,
            'center_id' => $center->id,
            'user_id' => $leader->id,
            'day' => 11,
            'shift_type' => 'evening',
            'rank' => 'leader',
            'status' => 'reserved',
        ]);

        $service->buildSchedule($plan);

        $rows = $service->scheduleGrid($plan);

        $this->assertCount(1, $rows);
        $row = $rows[0];

        $this->assertSame('Center A', $row['center']);
        $this->assertSame('2026-07-10', \Illuminate\Support\Carbon::parse($row['date'])->toDateString());
        $this->assertSame('morning', $row['shift_type']);
        $this->assertSame($leader->id, $row['leader']['user_id']);
        $this->assertSame($scout->id, $row['scout']['user_id']);
        $this->assertNull($row['paramedic']);
    }
}
