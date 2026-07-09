<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreShiftRequestRequest;
use App\Http\Resources\ShiftRequestResource;
use App\Models\ShiftAssignment;
use App\Models\ShiftRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ShiftRequestController extends Controller
{
    public function store(StoreShiftRequestRequest $request)
    {
        $data = $request->validated();

        $reqAssignment = ShiftAssignment::findOrFail($data['requester_assignment_id']);
        $targetAssignment = ShiftAssignment::findOrFail($data['target_assignment_id']);

        if ($reqAssignment->role !== $targetAssignment->role) {
            return response()->json(['message' => 'Swap allowed only between same roles'], 422);
        }

        // only requester can create a request from their assignment
        if ($request->user()->id !== $reqAssignment->user_id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $sr = ShiftRequest::create([
            'requester_assignment_id' => $reqAssignment->id,
            'target_assignment_id' => $targetAssignment->id,
            'reason' => $data['reason'] ?? null,
            'status' => 'pending',
        ]);

        return response()->json(new ShiftRequestResource($sr), 201);
    }

    public function index(Request $request)
    {
        $user = $request->user();

        // requests where user is requester or target
        $requests = ShiftRequest::whereHas('requesterAssignment', function ($q) use ($user) {
            $q->where('user_id', $user->id);
        })->orWhereHas('targetAssignment', function ($q) use ($user) {
            $q->where('user_id', $user->id);
        })->orderByDesc('created_at')->get();

        return ShiftRequestResource::collection($requests);
    }

    public function pending(Request $request)
    {
        $user = $request->user();

        $requests = ShiftRequest::where('status','pending')->whereHas('targetAssignment', function ($q) use ($user) {
            $q->where('user_id', $user->id);
        })->get();

        return ShiftRequestResource::collection($requests);
    }

    public function accept($id, Request $request)
    {
        $sr = ShiftRequest::findOrFail($id);
        $user = $request->user();

        $targetAssignment = $sr->targetAssignment;
        if (!$targetAssignment) return response()->json(['message' => 'No target assignment found'], 403);
        if ((int)$targetAssignment->user_id !== (int)$user->id) {
            return response()->json(['message' => 'Forbidden', 't_user' => $targetAssignment->user_id, 'req_user' => $user->id], 403);
        }

        $sr->status = 'accepted_by_target';
        $sr->save();

        return new ShiftRequestResource($sr);
    }

    public function reject($id, Request $request)
    {
        $sr = ShiftRequest::findOrFail($id);
        $user = $request->user();

        // only involved users or admin can reject
        if ($sr->requesterAssignment->user_id !== $user->id && $sr->targetAssignment->user_id !== $user->id && !in_array($user->role, ['admin','manager'])) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $sr->status = 'rejected';
        $sr->save();

        return new ShiftRequestResource($sr);
    }

    // Admin approve
    public function approve($id, Request $request)
    {
        $user = $request->user();
        if (!in_array($user->role, ['admin','manager'])) return response()->json(['message' => 'Forbidden'], 403);

        $sr = ShiftRequest::findOrFail($id);

        // swap user_id between assignments
        $reqA = $sr->requesterAssignment;
        $tgtA = $sr->targetAssignment;

        // enforce same role
        if ($reqA->role !== $tgtA->role) return response()->json(['message' => 'Cannot swap different roles'], 422);

        DB::transaction(function () use ($reqA, $tgtA, $sr, $user) {
            $tmp = $reqA->user_id;
            $reqA->user_id = $tgtA->user_id;
            $tgtA->user_id = $tmp;
            $reqA->save();
            $tgtA->save();

            $sr->status = 'approved';
            $sr->approved_by = $user->id;
            $sr->approved_at = now();
            $sr->save();
        });

        return new ShiftRequestResource($sr);
    }

    public function cancel($id, Request $request)
    {
        $user = $request->user();
        if (!in_array($user->role, ['admin','manager'])) return response()->json(['message' => 'Forbidden'], 403);

        $sr = ShiftRequest::findOrFail($id);
        $sr->status = 'cancelled';
        $sr->save();

        return new ShiftRequestResource($sr);
    }
}
