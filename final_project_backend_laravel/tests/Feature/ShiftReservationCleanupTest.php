<?php

namespace Tests\Feature;

use App\Models\Center;
use App\Models\ShiftPlan;
use App\Models\ShiftPoll;
use App\Models\ShiftPollReservation;
use App\Models\User;
use App\Services\ShiftReservationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ShiftReservationCleanupTest extends TestCase
{
    use RefreshDatabase;

    public function test_expired_reservations_are_removed_and_slot_becomes_available_again(): void
    {
        $user = User::factory()->create(['role' => 'paramedic', 'rank' => 'leader']);
        $plan = ShiftPlan::create(['month' => 7, 'year' => 2026, 'status' => 'polling_leaders']);
        $center = Center::create(['name' => 'Center A', 'status' => 'active']);
        ShiftPoll::create([
            'shift_plan_id' => $plan->id,
            'user_id' => $user->id,
            'role' => 'leader',
            'preferred_days' => [],
            'unavailable_days' => [],
            'status' => 'pending',
        ]);

        $reservation = ShiftPollReservation::create([
            'shift_plan_id' => $plan->id,
            'center_id' => $center->id,
            'user_id' => $user->id,
            'day' => 1,
            'shift_type' => 'morning',
            'rank' => 'leader',
            'status' => 'reserved',
            'expires_at' => now()->subSeconds(5),
        ]);

        app(ShiftReservationService::class)->cleanupExpiredReservations();

        $this->assertDatabaseMissing('shift_poll_reservations', ['id' => $reservation->id]);

        $newUser = User::factory()->create(['role' => 'paramedic', 'rank' => 'leader']);
        ShiftPoll::create([
            'shift_plan_id' => $plan->id,
            'user_id' => $newUser->id,
            'role' => 'leader',
            'preferred_days' => [],
            'unavailable_days' => [],
            'status' => 'pending',
        ]);

        $response = $this->actingAs($newUser)->postJson("/api/shift-plans/{$plan->id}/reserve", [
            'center_id' => $center->id,
            'day' => 1,
            'shift_type' => 'morning',
            'rank' => 'leader',
        ]);

        $response->assertStatus(201);
    }

    public function test_non_expired_reservations_are_not_removed(): void
    {
        $user = User::factory()->create(['role' => 'paramedic', 'rank' => 'leader']);
        $plan = ShiftPlan::create(['month' => 7, 'year' => 2026, 'status' => 'polling_leaders']);
        $center = Center::create(['name' => 'Center A', 'status' => 'active']);
        ShiftPoll::create([
            'shift_plan_id' => $plan->id,
            'user_id' => $user->id,
            'role' => 'leader',
            'preferred_days' => [],
            'unavailable_days' => [],
            'status' => 'pending',
        ]);

        $reservation = ShiftPollReservation::create([
            'shift_plan_id' => $plan->id,
            'center_id' => $center->id,
            'user_id' => $user->id,
            'day' => 1,
            'shift_type' => 'morning',
            'rank' => 'leader',
            'status' => 'reserved',
            'expires_at' => now()->addSeconds(120),
        ]);

        app(ShiftReservationService::class)->cleanupExpiredReservations();

        $this->assertDatabaseHas('shift_poll_reservations', ['id' => $reservation->id]);
    }

    public function test_confirmed_reservations_are_never_cleaned_up_even_without_expiry(): void
    {
        $user = User::factory()->create(['role' => 'paramedic', 'rank' => 'leader']);
        $plan = ShiftPlan::create(['month' => 7, 'year' => 2026, 'status' => 'polling_leaders']);
        $center = Center::create(['name' => 'Center A', 'status' => 'active']);
        ShiftPoll::create([
            'shift_plan_id' => $plan->id,
            'user_id' => $user->id,
            'role' => 'leader',
            'preferred_days' => [],
            'unavailable_days' => [],
            'status' => 'pending',
        ]);

        $reservation = ShiftPollReservation::create([
            'shift_plan_id' => $plan->id,
            'center_id' => $center->id,
            'user_id' => $user->id,
            'day' => 1,
            'shift_type' => 'morning',
            'rank' => 'leader',
            'status' => 'confirmed',
            'expires_at' => null,
        ]);

        app(ShiftReservationService::class)->cleanupExpiredReservations();

        $this->assertDatabaseHas('shift_poll_reservations', ['id' => $reservation->id]);
    }
}
