<?php

namespace Tests\Feature;

use App\Models\Center;
use App\Models\ShiftPlan;
use App\Models\ShiftPoll;
use App\Models\ShiftPollReservation;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ShiftPollReservationTest extends TestCase
{
    use RefreshDatabase;

    protected function makeUser(string $rank): User
    {
        return User::factory()->create(['role' => 'paramedic', 'rank' => $rank]);
    }

    protected function makePlan(): ShiftPlan
    {
        return ShiftPlan::create(['month' => 7, 'year' => 2026, 'status' => 'polling_leaders']);
    }

    protected function makeCenter(string $name = 'Center A'): Center
    {
        return Center::create(['name' => $name, 'status' => 'active']);
    }

    protected function makePollFor(ShiftPlan $plan, User $user, string $role): ShiftPoll
    {
        return ShiftPoll::create([
            'shift_plan_id' => $plan->id,
            'user_id' => $user->id,
            'role' => $role,
            'preferred_days' => [],
            'unavailable_days' => [],
            'status' => 'pending',
        ]);
    }

    public function test_user_can_reserve_a_free_slot(): void
    {
        $user = $this->makeUser('leader');
        $plan = $this->makePlan();
        $center = $this->makeCenter();
        $this->makePollFor($plan, $user, 'leader');

        $response = $this->actingAs($user)->postJson("/api/shift-plans/{$plan->id}/reserve", [
            'center_id' => $center->id,
            'day' => 1,
            'shift_type' => 'morning',
            'rank' => 'leader',
        ]);

        $response->assertStatus(201);
        $response->assertJsonStructure(['reservation_id']);

        $this->assertDatabaseHas('shift_poll_reservations', [
            'shift_plan_id' => $plan->id,
            'center_id' => $center->id,
            'user_id' => $user->id,
            'day' => 1,
            'shift_type' => 'morning',
            'rank' => 'leader',
            'status' => 'reserved',
        ]);
    }

    public function test_two_different_users_collide_on_same_center_day_shift_rank(): void
    {
        // The core cross-user guarantee: two distinct leaders, sharing one
        // shift_plan_id, must not both be able to reserve the exact same
        // (center, day, shift_type, rank) slot.
        $plan = $this->makePlan();
        $center = $this->makeCenter();
        $userA = $this->makeUser('leader');
        $userB = $this->makeUser('leader');
        $this->makePollFor($plan, $userA, 'leader');
        $this->makePollFor($plan, $userB, 'leader');

        $this->actingAs($userA)->postJson("/api/shift-plans/{$plan->id}/reserve", [
            'center_id' => $center->id,
            'day' => 1,
            'shift_type' => 'morning',
            'rank' => 'leader',
        ])->assertStatus(201);

        $response = $this->actingAs($userB)->postJson("/api/shift-plans/{$plan->id}/reserve", [
            'center_id' => $center->id,
            'day' => 1,
            'shift_type' => 'morning',
            'rank' => 'leader',
        ]);

        $response->assertStatus(409);
        $this->assertSame(1, ShiftPollReservation::where('shift_plan_id', $plan->id)
            ->where('center_id', $center->id)
            ->where('day', 1)->where('shift_type', 'morning')->where('rank', 'leader')->count());
    }

    public function test_two_different_users_can_reserve_same_day_shift_rank_at_different_centers(): void
    {
        // Reservation locks TIME + CENTER, not just time: the same (day,
        // shift_type, rank) slot at a DIFFERENT center is independent.
        $plan = $this->makePlan();
        $centerA = $this->makeCenter('Center A');
        $centerB = $this->makeCenter('Center B');
        $userA = $this->makeUser('leader');
        $userB = $this->makeUser('leader');
        $this->makePollFor($plan, $userA, 'leader');
        $this->makePollFor($plan, $userB, 'leader');

        $this->actingAs($userA)->postJson("/api/shift-plans/{$plan->id}/reserve", [
            'center_id' => $centerA->id,
            'day' => 1,
            'shift_type' => 'morning',
            'rank' => 'leader',
        ])->assertStatus(201);

        $response = $this->actingAs($userB)->postJson("/api/shift-plans/{$plan->id}/reserve", [
            'center_id' => $centerB->id,
            'day' => 1,
            'shift_type' => 'morning',
            'rank' => 'leader',
        ]);

        $response->assertStatus(201);
    }

    public function test_different_rank_can_reserve_same_center_day_and_shift(): void
    {
        $plan = $this->makePlan();
        $center = $this->makeCenter();
        $leader = $this->makeUser('leader');
        $scout = $this->makeUser('scout');
        $this->makePollFor($plan, $leader, 'leader');
        $this->makePollFor($plan, $scout, 'scout');

        $this->actingAs($leader)->postJson("/api/shift-plans/{$plan->id}/reserve", [
            'center_id' => $center->id,
            'day' => 1,
            'shift_type' => 'morning',
            'rank' => 'leader',
        ])->assertStatus(201);

        $response = $this->actingAs($scout)->postJson("/api/shift-plans/{$plan->id}/reserve", [
            'center_id' => $center->id,
            'day' => 1,
            'shift_type' => 'morning',
            'rank' => 'scout',
        ]);

        $response->assertStatus(201);
    }

    public function test_different_plans_do_not_share_reservations(): void
    {
        $planA = $this->makePlan();
        $planB = ShiftPlan::create(['month' => 8, 'year' => 2026, 'status' => 'polling_leaders']);
        $center = $this->makeCenter();
        $userA = $this->makeUser('leader');
        $userB = $this->makeUser('leader');
        $this->makePollFor($planA, $userA, 'leader');
        $this->makePollFor($planB, $userB, 'leader');

        $this->actingAs($userA)->postJson("/api/shift-plans/{$planA->id}/reserve", [
            'center_id' => $center->id,
            'day' => 1,
            'shift_type' => 'morning',
            'rank' => 'leader',
        ])->assertStatus(201);

        $response = $this->actingAs($userB)->postJson("/api/shift-plans/{$planB->id}/reserve", [
            'center_id' => $center->id,
            'day' => 1,
            'shift_type' => 'morning',
            'rank' => 'leader',
        ]);

        $response->assertStatus(201);
    }

    public function test_user_can_release_own_reservation(): void
    {
        $user = $this->makeUser('leader');
        $plan = $this->makePlan();
        $center = $this->makeCenter();
        $this->makePollFor($plan, $user, 'leader');

        $reserveResponse = $this->actingAs($user)->postJson("/api/shift-plans/{$plan->id}/reserve", [
            'center_id' => $center->id,
            'day' => 2,
            'shift_type' => 'night',
            'rank' => 'leader',
        ]);
        $reservationId = $reserveResponse->json('reservation_id');

        $response = $this->actingAs($user)->postJson("/api/shift-plans/{$plan->id}/release", [
            'reservation_id' => $reservationId,
        ]);

        $response->assertStatus(200);
        $this->assertDatabaseMissing('shift_poll_reservations', ['id' => $reservationId]);
    }

    public function test_user_cannot_release_another_users_reservation(): void
    {
        $plan = $this->makePlan();
        $center = $this->makeCenter();
        $userA = $this->makeUser('leader');
        $userB = $this->makeUser('leader');
        $this->makePollFor($plan, $userA, 'leader');
        $this->makePollFor($plan, $userB, 'leader');

        $reserveResponse = $this->actingAs($userA)->postJson("/api/shift-plans/{$plan->id}/reserve", [
            'center_id' => $center->id,
            'day' => 3,
            'shift_type' => 'evening',
            'rank' => 'leader',
        ]);
        $reservationId = $reserveResponse->json('reservation_id');

        $response = $this->actingAs($userB)->postJson("/api/shift-plans/{$plan->id}/release", [
            'reservation_id' => $reservationId,
        ]);

        $response->assertStatus(404);
        $this->assertDatabaseHas('shift_poll_reservations', ['id' => $reservationId]);
    }

    public function test_user_can_confirm_own_reservation(): void
    {
        $user = $this->makeUser('leader');
        $plan = $this->makePlan();
        $center = $this->makeCenter();
        $this->makePollFor($plan, $user, 'leader');

        $reserveResponse = $this->actingAs($user)->postJson("/api/shift-plans/{$plan->id}/reserve", [
            'center_id' => $center->id,
            'day' => 4,
            'shift_type' => 'morning',
            'rank' => 'leader',
        ]);
        $reservationId = $reserveResponse->json('reservation_id');

        $response = $this->actingAs($user)->postJson("/api/shift-plans/{$plan->id}/confirm", [
            'reservation_id' => $reservationId,
        ]);

        $response->assertStatus(200);
        $this->assertDatabaseHas('shift_poll_reservations', [
            'id' => $reservationId,
            'status' => 'confirmed',
            'expires_at' => null,
        ]);
    }

    public function test_current_reservations_endpoint_lists_reserved_slots(): void
    {
        $user = $this->makeUser('leader');
        $plan = $this->makePlan();
        $center = $this->makeCenter();
        $this->makePollFor($plan, $user, 'leader');

        $this->actingAs($user)->postJson("/api/shift-plans/{$plan->id}/reserve", [
            'center_id' => $center->id,
            'day' => 5,
            'shift_type' => 'night',
            'rank' => 'leader',
        ])->assertStatus(201);

        $response = $this->actingAs($user)->getJson("/api/shift-plans/{$plan->id}/reservations");

        $response->assertStatus(200);
        $response->assertJsonFragment(['center_id' => $center->id, 'day' => 5, 'shift_type' => 'night', 'rank' => 'leader']);
    }

    public function test_current_reservations_endpoint_also_includes_confirmed_slots(): void
    {
        $user = $this->makeUser('leader');
        $plan = $this->makePlan();
        $center = $this->makeCenter();
        $this->makePollFor($plan, $user, 'leader');

        $reserveResponse = $this->actingAs($user)->postJson("/api/shift-plans/{$plan->id}/reserve", [
            'center_id' => $center->id,
            'day' => 6,
            'shift_type' => 'evening',
            'rank' => 'leader',
        ]);
        $reservationId = $reserveResponse->json('reservation_id');

        $this->actingAs($user)->postJson("/api/shift-plans/{$plan->id}/confirm", [
            'reservation_id' => $reservationId,
        ])->assertStatus(200);

        $response = $this->actingAs($user)->getJson("/api/shift-plans/{$plan->id}/reservations");

        $response->assertStatus(200);
        $response->assertJsonFragment(['center_id' => $center->id, 'day' => 6, 'shift_type' => 'evening', 'rank' => 'leader', 'status' => 'confirmed']);
    }

    public function test_reservation_requires_authentication(): void
    {
        $user = $this->makeUser('leader');
        $plan = $this->makePlan();
        $center = $this->makeCenter();
        $this->makePollFor($plan, $user, 'leader');

        $response = $this->postJson("/api/shift-plans/{$plan->id}/reserve", [
            'center_id' => $center->id,
            'day' => 1,
            'shift_type' => 'morning',
            'rank' => 'leader',
        ]);

        $response->assertStatus(401);
    }
}
