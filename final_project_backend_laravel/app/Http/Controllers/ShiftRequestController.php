<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreShiftRequestRequest;
use App\Http\Resources\ShiftRequestResource;
use App\Http\Resources\SwapCandidateResource;
use App\Models\ShiftAssignment;
use App\Models\ShiftPlan;
use App\Models\ShiftRequest;
use App\Services\NotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ShiftRequestController extends Controller
{
    private function currentPlan()
    {
        return ShiftPlan::where('status', 'published')->orderByDesc('published_at')->first()
            ?? ShiftPlan::orderByDesc('created_at')->first();
    }

    /**
     * Swapping user_id between two assignments would violate the
     * shift_assignments unique(shift_id, user_id) constraint if either user
     * already independently holds an assignment on the other's shift.
     */
    private function wouldCollide(ShiftAssignment $a, ShiftAssignment $b): bool
    {
        if ($a->shift_id === $b->shift_id) {
            return true;
        }

        return ShiftAssignment::where(function ($q) use ($a, $b) {
            $q->where('shift_id', $a->shift_id)->where('user_id', $b->user_id);
        })->orWhere(function ($q) use ($a, $b) {
            $q->where('shift_id', $b->shift_id)->where('user_id', $a->user_id);
        })->whereNotIn('id', [$a->id, $b->id])->exists();
    }

    /**
     * Assignments eligible to swap with the given assignment: same role,
     * belonging to another user, scoped to the current plan.
     */
    public function candidates(Request $request)
    {
        $data = $request->validate([
            'my_assignment_id' => ['required', 'integer', 'exists:shift_assignments,id'],
        ]);

        $mine = ShiftAssignment::findOrFail($data['my_assignment_id']);

        if ($mine->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $plan = $this->currentPlan();

        $candidates = ShiftAssignment::where('role', $mine->role)
            ->where('user_id', '!=', $request->user()->id)
            ->whereHas('shift', function ($q) use ($plan) {
                if ($plan) $q->where('shift_plan_id', $plan->id);
            })
            ->with(['shift.center', 'user'])
            ->get()
            ->reject(fn ($candidate) => $this->wouldCollide($mine, $candidate))
            ->values();

        return SwapCandidateResource::collection($candidates);
    }

    public function store(StoreShiftRequestRequest $request)
    {
        $data = $request->validated();

        $reqAssignment = ShiftAssignment::findOrFail($data['requester_assignment_id']);
        $targetAssignment = ShiftAssignment::findOrFail($data['target_assignment_id']);

        // only requester can create a request from their assignment
        if ($request->user()->id !== $reqAssignment->user_id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        if ($reqAssignment->user_id === $targetAssignment->user_id) {
            return response()->json(['message' => 'Cannot swap with yourself'], 422);
        }

        if ($reqAssignment->role !== $targetAssignment->role) {
            return response()->json(['message' => 'Swap allowed only between same roles'], 422);
        }

        if ($this->wouldCollide($reqAssignment, $targetAssignment)) {
            return response()->json(['message' => 'This swap would conflict with an existing assignment'], 422);
        }

        $plan = $this->currentPlan();
        if ($plan) {
            $bothActive = ShiftAssignment::whereIn('id', [$reqAssignment->id, $targetAssignment->id])
                ->whereHas('shift', function ($q) use ($plan) { $q->where('shift_plan_id', $plan->id); })
                ->count() === 2;
            if (!$bothActive) {
                return response()->json(['message' => 'Both assignments must be active'], 422);
            }
        }

        $duplicate = ShiftRequest::whereIn('status', ['pending', 'accepted_by_target'])
            ->where(function ($q) use ($reqAssignment, $targetAssignment) {
                $q->where('requester_assignment_id', $reqAssignment->id)
                    ->where('target_assignment_id', $targetAssignment->id);
            })
            ->orWhere(function ($q) use ($reqAssignment, $targetAssignment) {
                $q->whereIn('status', ['pending', 'accepted_by_target'])
                    ->where('requester_assignment_id', $targetAssignment->id)
                    ->where('target_assignment_id', $reqAssignment->id);
            })
            ->exists();

        if ($duplicate) {
            return response()->json(['message' => 'A swap request already exists for these assignments'], 422);
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

        if (in_array($user->role, ['admin', 'manager'])) {
            $requests = ShiftRequest::orderByDesc('created_at')->get();

            return ShiftRequestResource::collection($requests);
        }

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

    public function reject($id, Request $request)
    {
        $sr = ShiftRequest::findOrFail($id);
        $user = $request->user();

        // only involved users or admin can reject
        if ($sr->requesterAssignment->user_id !== $user->id && $sr->targetAssignment->user_id !== $user->id && !in_array($user->role, ['admin','manager'])) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        if (!in_array($sr->status, ['pending', 'accepted_by_target'])) {
            return response()->json(['message' => 'This request has already been resolved'], 422);
        }

        $sr->status = 'rejected';
        $sr->save();

        $notificationService = app(NotificationService::class);
        foreach ([$sr->requesterAssignment->user_id, $sr->targetAssignment->user_id] as $userId) {
            $notificationService->send([
                'user_id' => $userId,
                'title' => 'Shift swap rejected',
                'message' => 'Your shift swap request has been rejected.',
                'is_read' => false,
            ]);
        }

        return new ShiftRequestResource($sr);
    }

    // Admin approve
    public function approve($id, Request $request)
    {
        $user = $request->user();
        if (!in_array($user->role, ['admin','manager'])) return response()->json(['message' => 'Forbidden'], 403);

        $sr = ShiftRequest::findOrFail($id);

        if (!in_array($sr->status, ['pending', 'accepted_by_target'])) {
            return response()->json(['message' => 'This request has already been resolved'], 422);
        }

        // swap user_id between assignments
        $reqA = $sr->requesterAssignment;
        $tgtA = $sr->targetAssignment;

        // enforce same role
        if ($reqA->role !== $tgtA->role) return response()->json(['message' => 'Cannot swap different roles'], 422);

        if ($this->wouldCollide($reqA, $tgtA)) {
            return response()->json(['message' => 'This swap would conflict with an existing assignment'], 422);
        }

        $requesterUserId = $reqA->user_id;
        $targetUserId = $tgtA->user_id;

        try {
            DB::transaction(function () use ($reqA, $tgtA, $sr) {
                $locked = ShiftRequest::whereKey($sr->id)->lockForUpdate()->firstOrFail();
                if (!in_array($locked->status, ['pending', 'accepted_by_target'])) {
                    throw new \RuntimeException('already_resolved');
                }

                $tmp = $reqA->user_id;
                $reqA->user_id = $tgtA->user_id;
                $tgtA->user_id = $tmp;
                $reqA->save();
                $tgtA->save();

                $locked->status = 'approved';
                $locked->approved_by = request()->user()->id;
                $locked->approved_at = now();
                $locked->save();
            });
        } catch (\RuntimeException $e) {
            if ($e->getMessage() === 'already_resolved') {
                return response()->json(['message' => 'This request has already been resolved'], 422);
            }
            throw $e;
        }

        $notificationService = app(NotificationService::class);
        foreach ([$requesterUserId, $targetUserId] as $userId) {
            $notificationService->send([
                'user_id' => $userId,
                'title' => 'Shift swap approved',
                'message' => 'Your shift swap request has been approved.',
                'is_read' => false,
            ]);
        }

        return new ShiftRequestResource($sr->fresh());
    }

    public function cancel($id, Request $request)
    {
        $user = $request->user();
        if (!in_array($user->role, ['admin','manager'])) return response()->json(['message' => 'Forbidden'], 403);

        $sr = ShiftRequest::findOrFail($id);

        if (!in_array($sr->status, ['pending', 'accepted_by_target'])) {
            return response()->json(['message' => 'This request has already been resolved'], 422);
        }

        $sr->status = 'cancelled';
        $sr->save();

        return new ShiftRequestResource($sr);
    }
}
