<?php

namespace App\Services;

use App\Models\Shift;
use App\Models\ShiftAssignment;
use App\Models\ShiftPoll;
use App\Models\ShiftRequest;
use App\Models\User;

class ShiftService
{
    public function createShift(array $data): Shift
    {
        return Shift::create($data);
    }

    public function assignShift(int $shiftId, array $data): ShiftAssignment
    {
        return ShiftAssignment::create([
            'shift_id' => $shiftId,
            'user_id' => $data['user_id'],
            'role' => $data['role']
        ]);
    }

    public function submitPoll(int $shiftId, User $user, bool $selected): ShiftPoll
    {
        return ShiftPoll::create([
            'shift_id' => $shiftId,
            'user_id' => $user->id,
            'selected' => $selected
        ]);
    }

    public function swapRequest(int $shiftId, User $user, int $toUserId): ShiftRequest
    {
        return ShiftRequest::create([
            'shift_id' => $shiftId,
            'user_id' => $user->id,
            'status' => 'pending'
        ]);
    }

    public function requestJoinShift(int $shiftId, User $user, ?int $shiftPollId = null): ShiftRequest
    {
        return ShiftRequest::create([
            'shift_id' => $shiftId,
            'user_id' => $user->id,
            'shift_poll_id' => $shiftPollId,
            'status' => 'pending'
        ]);
    }

    public function approveRequest(int $requestId, User $approver, ?int $vehicleId = null): ShiftRequest
    {
        $request = ShiftRequest::findOrFail($requestId);

        if ($request->status !== 'pending') {
            throw new \Exception('Request is not pending');
        }

        // create assignment
        $assignment = ShiftAssignment::create([
            'shift_id' => $request->shift_id,
            'user_id' => $request->user_id,
            'role' => $approver->role === 'admin' ? 'paramedic' : ($approver->role ?? 'paramedic'),
            'vehicle_id' => $vehicleId
        ]);

        $request->status = 'approved';
        $request->approved_by = $approver->id;
        $request->approved_at = now();
        $request->save();

        // notify the requester
        $notificationService = app(\App\Services\NotificationService::class);
        $notificationService->send([
            'user_id' => $request->user_id,
            'title' => 'Shift request approved',
            'message' => "Your request for Shift #{$request->shift_id} has been approved.",
            'is_read' => false
        ]);

        return $request;
    }

    public function rejectRequest(int $requestId, User $approver): ShiftRequest
    {
        $request = ShiftRequest::findOrFail($requestId);

        if ($request->status !== 'pending') {
            throw new \Exception('Request is not pending');
        }

        $request->status = 'rejected';
        $request->approved_by = $approver->id;
        $request->approved_at = now();
        $request->save();

        $notificationService = app(\App\Services\NotificationService::class);
        $notificationService->send([
            'user_id' => $request->user_id,
            'title' => 'Shift request rejected',
            'message' => "Your request for Shift #{$request->shift_id} has been rejected.",
            'is_read' => false
        ]);

        return $request;
    }
}
