<?php

namespace Tests\Feature;

use App\Events\CaseStatusUpdated;
use App\Models\EmsCase;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Event;
use Tests\TestCase;

class MovementLogBroadcastTest extends TestCase
{
    use RefreshDatabase;

    public function test_saving_a_movement_log_field_broadcasts_case_status_updated(): void
    {
        Event::fake([CaseStatusUpdated::class]);

        $user = User::factory()->create(['role' => 'radio']);
        $case = EmsCase::create(['triage_code' => 'red', 'status' => 'assigned']);

        $response = $this->actingAs($user)->postJson('/api/movement_logs', [
            'case_id' => $case->id,
            'field' => 'depart_patient',
            'timestamp' => '14:32:00',
        ]);

        $response->assertStatus(200);

        Event::assertDispatched(CaseStatusUpdated::class, function ($event) use ($case) {
            return $event->case->id === $case->id
                && $event->case->movementLog->depart_patient !== null;
        });
    }

    public function test_saving_the_full_movement_log_form_broadcasts_case_status_updated(): void
    {
        Event::fake([CaseStatusUpdated::class]);

        $user = User::factory()->create(['role' => 'radio']);
        $case = EmsCase::create(['triage_code' => 'red', 'status' => 'assigned']);

        $response = $this->actingAs($user)->postJson('/api/movement_logs/save', [
            'case_id' => $case->id,
            'arrive_patient' => '14:45:00',
        ]);

        $response->assertStatus(200);

        Event::assertDispatched(CaseStatusUpdated::class, function ($event) use ($case) {
            return $event->case->id === $case->id
                && $event->case->movementLog->arrive_patient !== null;
        });
    }
}
