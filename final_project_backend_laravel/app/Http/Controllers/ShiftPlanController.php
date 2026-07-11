<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreShiftPlanRequest;
use App\Http\Resources\ShiftPlanResource;
use App\Models\ShiftAssignment;
use App\Models\ShiftPlan;
use App\Services\NotificationService;
use App\Services\ShiftPlanService;
use Illuminate\Http\Request;

class ShiftPlanController extends Controller
{
    protected $service;

    public function __construct(ShiftPlanService $service)
    {
        $this->service = $service;
    }

    public function store(StoreShiftPlanRequest $request)
    {
        $plan = $this->service->createMonthlyPlan($request->input('month'), $request->input('year'), $request->user()->id);

        return response()->json(new ShiftPlanResource($plan), 201);
    }

    public function index(Request $request)
    {
        $plans = ShiftPlan::orderByDesc('created_at')->get();
        return ShiftPlanResource::collection($plans);
    }

    public function show($id)
    {
        $plan = ShiftPlan::findOrFail($id);
        return new ShiftPlanResource($plan);
    }

    public function startLeaderPoll($id)
    {
        $plan = ShiftPlan::findOrFail($id);
        $this->service->startLeaderPoll($plan);
        return response()->json(['message' => 'Leader poll started']);
    }

    public function startScoutPoll($id)
    {
        $plan = ShiftPlan::findOrFail($id);
        $this->service->startScoutPoll($plan);
        return response()->json(['message' => 'Scout poll started']);
    }

    public function startParamedicPoll($id)
    {
        $plan = ShiftPlan::findOrFail($id);
        $this->service->startParamedicPoll($plan);
        return response()->json(['message' => 'Paramedic poll started']);
    }

    public function build($id)
    {
        $plan = ShiftPlan::findOrFail($id);

        try {
            $result = $this->service->buildSchedule($plan);
        } catch (\RuntimeException $e) {
            // A concurrent/duplicate request already moved this plan past
            // polling_paramedics (e.g. a double-tap of the Build button).
            // The other request's build stands; tell the client the plan is
            // already built/beyond that stage instead of a raw 500.
            $plan->refresh();
            if (in_array($plan->status, ['building', 'published', 'closed'], true)) {
                return response()->json([
                    'message' => 'Schedule already built for this plan',
                    'status' => $plan->status,
                ], 200);
            }
            return response()->json(['message' => $e->getMessage()], 409);
        }

        return response()->json(['created_assignments' => $result['assignments']->count(), 'unfilled_slots' => $result['unfilled']]);
    }

    public function publish($id)
    {
        $plan = ShiftPlan::findOrFail($id);

        try {
            $this->service->publishSchedule($plan);
        } catch (\RuntimeException $e) {
            $plan->refresh();
            if (in_array($plan->status, ['published', 'closed'], true)) {
                return response()->json([
                    'message' => 'Schedule already published for this plan',
                    'status' => $plan->status,
                ], 200);
            }
            return response()->json(['message' => $e->getMessage()], 409);
        }

        return response()->json(['message' => 'Published']);
    }

    public function close($id)
    {
        $plan = ShiftPlan::findOrFail($id);
        $this->service->closePlan($plan);
        return response()->json(['message' => 'Closed']);
    }

    public function schedule($id)
    {
        $plan = ShiftPlan::findOrFail($id);
        return response()->json([
            'plan' => new ShiftPlanResource($plan),
            'rows' => $this->service->scheduleGrid($plan),
        ]);
    }

    public function sendSchedule($id, NotificationService $notificationService)
    {
        $plan = ShiftPlan::findOrFail($id);

        $userIds = ShiftAssignment::whereHas('shift', function ($q) use ($plan) {
            $q->where('shift_plan_id', $plan->id);
        })->distinct()->pluck('user_id');

        foreach ($userIds as $userId) {
            $notificationService->send([
                'user_id' => $userId,
                'title' => 'Shift Schedule Published',
                'message' => "Your shift schedule for {$plan->month}/{$plan->year} is ready. Check My Schedule.",
            ]);
        }

        return response()->json(['message' => 'Schedule sent', 'notified_users' => $userIds->count()]);
    }
}
