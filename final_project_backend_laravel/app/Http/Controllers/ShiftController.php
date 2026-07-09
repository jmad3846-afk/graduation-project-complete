<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreShiftRequest;
use App\Services\ShiftService;
use Illuminate\Http\Request;

class ShiftController extends Controller
{
    protected $shiftService;

    public function __construct(ShiftService $shiftService)
    {
        $this->shiftService = $shiftService;
    }

    public function store(StoreShiftRequest $request)
    {
        $shift = $this->shiftService->createShift($request->validated());
        return response()->json(['message' => 'Shift created', 'shift' => $shift], 201);
    }

    public function assignShift(Request $request, $id)
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'role' => 'required|in:leader,scout,paramedic'
        ]);

        $assignment = $this->shiftService->assignShift($id, $validated);
        return response()->json(['message' => 'Assigned', 'assignment' => $assignment]);
    }

    public function submitPoll(Request $request, $id)
    {
        $request->validate(['selected' => 'required|boolean']);
        $poll = $this->shiftService->submitPoll($id, $request->user(), $request->selected);
        return response()->json(['message' => 'Poll submitted', 'poll' => $poll]);
    }

    public function swapRequest(Request $request, $id)
    {
        $request->validate(['to_user' => 'required|exists:users,id']);
        $swap = $this->shiftService->swapRequest($id, $request->user(), $request->to_user);
        return response()->json(['message' => 'Swap requested', 'request' => $swap]);
    }
}
