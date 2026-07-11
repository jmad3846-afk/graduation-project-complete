<?php

namespace App\Services;

use App\Events\CaseCreated;
use App\Events\CaseAssigned;
use App\Events\CaseStatusUpdated;
use App\Models\EmsCase;
use App\Models\Patient;
use App\Models\Caller;

class CaseService
{
    public function getAllCases()
    {
        return EmsCase::with(['patient', 'caller', 'vehicle', 'center', 'movementLog'])
            ->orderBy('created_at', 'desc')
            ->get();
    }

    public function createCase(array $data): EmsCase
    {
        $trackingToken = \Illuminate\Support\Str::uuid()->toString();

        $case = EmsCase::create([
            'triage_code' => $data['triage_code'] ?? 'green',
            'transfer_type' => $data['transfer_type'] ?? null,
            'symptoms' => $data['symptoms'] ?? null,
            'breathing_rate' => $data['breathing_rate'] ?? null,
            'medical_aid_given' => $data['medical_aid_given'] ?? null,
            'operations_officer' => $data['operations_officer'] ?? null,
            'sector_commander' => $data['sector_commander'] ?? null,
            'status' => 'waiting',
            'latitude' => $data['latitude'] ?? null,
            'longitude' => $data['longitude'] ?? null,
            'destination_hospital' => $data['destination_hospital'] ?? null,
            'device_id' => $data['device_id'] ?? null,
            'tracking_token' => $trackingToken,
        ]);

        if (!empty($data['patient_name'])) {
            Patient::create([
                'case_id' => $case->id, 
                'full_name' => $data['patient_name'],
                'age' => $data['age'] ?? null,
                'weight' => $data['weight'] ?? null,
                'medical_history' => $data['medical_history'] ?? null,
                'oxygen_level' => $data['oxygen_level'] ?? null,
                'blood_pressure' => $data['blood_pressure'] ?? null,
                'blood_sugar' => $data['blood_sugar'] ?? null,
                'oxygen_before' => $data['oxygen_before'] ?? null,
                'oxygen_after' => $data['oxygen_after'] ?? null,
                'has_tube' => $data['has_tube'] ?? false,
                'conscious' => $data['conscious'] ?? true,
            ]);
        }

        if (!empty($data['caller_name'])) {
            Caller::create([
                'case_id' => $case->id, 
                'name' => $data['caller_name'], 
                'phone' => $data['caller_phone'] ?? null,
                'relation' => $data['relation'] ?? null,
            ]);
        }

        $case->load('patient', 'caller');
        
        event(new CaseCreated($case));

        return $case;
    }

    public function updateCase(int $id, array $data): EmsCase
    {
        $case = EmsCase::findOrFail($id);
        $user = auth()->user();

        if ($user && $user->role === 'paramedic') {
            $assignedVehicleIds = \App\Models\ShiftAssignment::where('user_id', $user->id)
                ->whereNotNull('vehicle_id')
                ->pluck('vehicle_id')
                ->toArray();

            if (empty($assignedVehicleIds) || !in_array($case->vehicle_id, $assignedVehicleIds)) {
                throw \Illuminate\Validation\ValidationException::withMessages([
                    'permission' => 'You are not assigned to this case vehicle and cannot modify it.'
                ]);
            }
        }

        $case->update($data);
        return $case;
    }

    public function assignCenter(int $id, int $centerId): EmsCase
    {
        $case = EmsCase::findOrFail($id);
        
        if ($case->status !== 'waiting' || $case->center_id !== null) {
            throw \Illuminate\Validation\ValidationException::withMessages([
                'status' => 'Case is already assigned or not waiting.'
            ]);
        }

        $case->update(['center_id' => $centerId, 'status' => 'assigned']);
        
        event(new CaseAssigned($case));

        $this->notifyRole('radio', 'New case assigned', "Case #{$case->id} assigned to Center #{$centerId}");

        // Notify paramedics: if case has vehicle_id, notify users assigned to that vehicle;
        // otherwise notify paramedics in the center.
        $notificationService = app(\App\Services\NotificationService::class);

        if ($case->vehicle_id) {
            $userIds = \App\Models\ShiftAssignment::where('vehicle_id', $case->vehicle_id)
                ->pluck('user_id')
                ->unique()
                ->toArray();
        } else {
            $userIds = \App\Models\User::where('role', 'paramedic')->where('center_id', $centerId)->pluck('id')->toArray();
        }

        foreach ($userIds as $uid) {
            $notificationService->send([
                'user_id' => $uid,
                'title' => 'New case assigned',
                'message' => "Case #{$case->id} assigned to your team/center",
                'is_read' => false
            ]);
        }

        return $case;
    }

    public function changeStatus(int $id, string $status): EmsCase
    {
        $case = EmsCase::findOrFail($id);
        $user = auth()->user();

        if ($user && $user->role === 'paramedic') {
            $assignedVehicleIds = \App\Models\ShiftAssignment::where('user_id', $user->id)
                ->whereNotNull('vehicle_id')
                ->pluck('vehicle_id')
                ->toArray();

            if (empty($assignedVehicleIds) || !in_array($case->vehicle_id, $assignedVehicleIds)) {
                throw \Illuminate\Validation\ValidationException::withMessages([
                    'permission' => 'You are not assigned to this case vehicle and cannot change its status.'
                ]);
            }
        }
        
        $validTransitions = [
            'waiting' => ['assigned'],
            'assigned' => ['in_progress'],
            'in_progress' => ['at_hospital', 'closed'],
            'at_hospital' => ['closed'],
            'closed' => []
        ];

        if (!in_array($status, $validTransitions[$case->status] ?? [])) {
             throw \Illuminate\Validation\ValidationException::withMessages([
                'status' => "Invalid transition from {$case->status} to {$status}."
            ]);
        }


        $case->update(['status' => $status]);

        event(new CaseStatusUpdated($case));

        // Notify paramedics for status updates (vehicle team or center members)
        $notificationService = app(\App\Services\NotificationService::class);

        if ($case->vehicle_id) {
            $userIds = \App\Models\ShiftAssignment::where('vehicle_id', $case->vehicle_id)
                ->pluck('user_id')
                ->unique()
                ->toArray();
        } else {
            $userIds = \App\Models\User::where('role', 'paramedic')->where('center_id', $case->center_id)->pluck('id')->toArray();
        }

        foreach ($userIds as $uid) {
            $notificationService->send([
                'user_id' => $uid,
                'title' => 'Case status updated',
                'message' => "Case #{$case->id} is now {$case->status}.",
                'data' => ['case_id' => $case->id, 'status' => $case->status],
                'is_read' => false
            ]);
        }

        if ($status === 'closed') {
             $this->notifyRole('dispatcher', 'Case Closed', "Case #{$case->id} has been fully closed.");
        }

        return $case;
    }

    protected function notifyRole(string $role, string $title, string $message)
    {
        $usersToNotify = \App\Models\User::where('role', $role)->get();
        $notificationService = app(\App\Services\NotificationService::class);
        foreach($usersToNotify as $user) {
             $notificationService->send([
                 'user_id' => $user->id,
                 'title' => $title,
                 'message' => $message,
                 'is_read' => false
             ]);
        }
    }
}
