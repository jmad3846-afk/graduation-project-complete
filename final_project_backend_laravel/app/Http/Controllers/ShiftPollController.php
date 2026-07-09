<?php

namespace App\Http\Controllers;

use App\Http\Requests\SubmitShiftPollRequest;
use App\Http\Resources\ShiftPollResource;
use App\Models\ShiftPoll;
use App\Services\ShiftReservationService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;


use Symfony\Component\HttpKernel\Exception\ConflictHttpException;

class ShiftPollController extends Controller
{
    public function current(Request $request)
    {
        $user = $request->user();
        $poll = ShiftPoll::where('user_id', $user->id)
            ->where('status','pending')
            ->orderByDesc('created_at')
            ->first();

        if (! $poll) return response()->json(null, 204);

        return new ShiftPollResource($poll);
    }

    public function submit(SubmitShiftPollRequest $request, $id)
    {
        $user = $request->user();
        $poll = ShiftPoll::where('id', $id)
            ->where('user_id', $user->id)
            ->firstOrFail();

        $poll->preferred_days = $request->input('preferred_shifts', []);
        $poll->unavailable_days = $request->input('unavailable_shifts', []);
        $poll->status = 'submitted';
        $poll->submitted_at = now();
        $poll->save();

        return response()->json(new ShiftPollResource($poll));
    }

    public function history(Request $request)
    {
        $user = $request->user();
        $polls = ShiftPoll::where('user_id', $user->id)->orderByDesc('created_at')->get();
        return ShiftPollResource::collection($polls);
    }

    // Reservation endpoints (scoped by shift_plan_id, shared across all users on that plan)
    public function reserve(Request $request, $plan): JsonResponse
    {
        $user = $request->user();
        $centerId = $request->input('center_id');
        $day = $request->input('day');
        $shift = $request->input('shift_type');
        $rank = $request->input('rank');
        $service = app(ShiftReservationService::class);
        try {
            $reservation = $service->reserve($plan, $centerId, $day, $shift, $rank, $user->id);
            return response()->json(['reservation_id' => $reservation->id], 201);
        } catch (ConflictHttpException $e) {
            return response()->json(['message' => $e->getMessage()], 409);
        }
    }

    public function release(Request $request, $plan): JsonResponse
    {
        $user = $request->user();
        $reservationId = $request->input('reservation_id');
        $service = app(ShiftReservationService::class);
        $service->release($reservationId, $user->id);
        return response()->json(['message' => 'Reservation released']);
    }

    public function confirm(Request $request, $plan): JsonResponse
    {
        $user = $request->user();
        $reservationId = $request->input('reservation_id');
        $service = app(ShiftReservationService::class);
        $service->confirm($reservationId, $user->id);
        return response()->json(['message' => 'Reservation confirmed']);
    }

    public function reservations(Request $request, $plan): JsonResponse
    {
        $service = app(ShiftReservationService::class);
        $reservations = $service->currentReservations($plan);
        return response()->json($reservations);
    }
}
?>
