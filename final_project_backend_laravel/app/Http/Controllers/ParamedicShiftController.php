<?php

namespace App\Http\Controllers;

use App\Models\ShiftPoll;
use App\Models\ShiftRequest;
use App\Models\ShiftAssignment;
use App\Services\ShiftService;
use Illuminate\Http\Request;

class ParamedicShiftController extends Controller
{
    protected $shiftService;

    public function __construct(ShiftService $shiftService)
    {
        $this->shiftService = $shiftService;
    }

    public function myShifts(Request $request)
    {
        $user = $request->user();
        $assignments = ShiftAssignment::with('shift', 'vehicle')
            ->where('user_id', $user->id)
            ->get();

        return response()->json($assignments);
    }

    public function activePoll(Request $request)
    {
        $user = $request->user();

        $polls = ShiftPoll::with('shift')
            ->where('status', 'open')
            ->where('role', $user->rank)
            ->get();

        $result = $polls->map(function ($poll) {
            $shift = $poll->shift;
            $assignedCount = ShiftAssignment::where('shift_id', $shift->id)->count();
            $remaining = max(0, ($shift->slots ?? 1) - $assignedCount);
            return [
                'poll_id' => $poll->id,
                'shift_id' => $shift->id,
                'date' => $shift->date,
                'type' => $shift->type,
                'center_id' => $shift->center_id,
                'current_role' => $poll->role,
                'remaining_slots' => $remaining
            ];
        });

        return response()->json(['polls' => $result]);
    }

    public function requestShift(Request $request)
    {
        $user = $request->user();
        $validated = $request->validate(['shift_id' => 'required|exists:shifts,id']);

        $shiftId = $validated['shift_id'];

        $poll = ShiftPoll::where('shift_id', $shiftId)->where('status', 'open')->where('role', $user->rank)->first();

        if (!$poll) {
            return response()->json(['message' => 'No open poll for this shift and role'], 422);
        }

        // prevent duplicate requests
        $exists = ShiftRequest::where('shift_id', $shiftId)->where('user_id', $user->id)->exists();
        if ($exists) {
            return response()->json(['message' => 'You have already requested this shift'], 422);
        }

        // prevent selecting full shifts
        $shift = $poll->shift;
        $assignedCount = ShiftAssignment::where('shift_id', $shift->id)->count();
        $remaining = max(0, ($shift->slots ?? 1) - $assignedCount);
        if ($remaining <= 0) {
            return response()->json(['message' => 'Shift is full'], 422);
        }

        $req = $this->shiftService->requestJoinShift($shiftId, $user, $poll->id);

        return response()->json(['message' => 'Request submitted', 'request' => $req]);
    }

    public function myRequests(Request $request)
    {
        $user = $request->user();
        $requests = ShiftRequest::with('requesterAssignment.shift', 'targetAssignment.shift', 'approver')
            ->whereHas('requesterAssignment', function ($q) use ($user) {
                $q->where('user_id', $user->id);
            })
            ->orWhereHas('targetAssignment', function ($q) use ($user) {
                $q->where('user_id', $user->id);
            })
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($requests);
    }
}
