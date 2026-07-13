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

    public function test_schedule_grid_groups_reservations_by_center_day_and_shift(): void
    {
        $center = Center::create(['name' => 'Center A', 'status' => 'active']);
        $admin = User::factory()->create(['role' => 'admin']);
        $leader = User::factory()->create(['role' => 'paramedic', 'rank' => 'leader']);
        $scout = User::factory()->create(['role' => 'paramedic', 'rank' => 'scout']);

        $plan = ShiftPlan::create(['month' => 7, 'year' => 2026, 'status' => 'building']);

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

        // Not confirmed yet: must not appear in the grid.
        ShiftPollReservation::create([
            'shift_plan_id' => $plan->id,
            'center_id' => $center->id,
            'user_id' => $leader->id,
            'day' => 11,
            'shift_type' => 'evening',
            'rank' => 'leader',
            'status' => 'reserved',
        ]);

        $rows = app(ShiftPlanService::class)->scheduleGrid($plan);

        $this->assertCount(1, $rows);
        $row = $rows[0];

        $this->assertSame('Center A', $row['center']);
        $this->assertSame('2026-07-10', $row['date']);
        $this->assertSame('morning', $row['shift_type']);
        $this->assertSame($leader->id, $row['leader']['user_id']);
        $this->assertSame($scout->id, $row['scout']['user_id']);
        $this->assertNull($row['paramedic']);
    }
}
