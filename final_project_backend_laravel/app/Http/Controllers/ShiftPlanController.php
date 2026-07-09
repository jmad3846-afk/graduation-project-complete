<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreShiftPlanRequest;
use App\Http\Resources\ShiftPlanResource;
use App\Models\ShiftPlan;
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
        $result = $this->service->buildSchedule($plan);
        return response()->json(['created_assignments' => $result['assignments']->count(), 'unfilled_slots' => $result['unfilled']]);
    }

    public function publish($id)
    {
        $plan = ShiftPlan::findOrFail($id);
        $this->service->publishSchedule($plan);
        return response()->json(['message' => 'Published']);
    }

    public function close($id)
    {
        $plan = ShiftPlan::findOrFail($id);
        $this->service->closePlan($plan);
        return response()->json(['message' => 'Closed']);
    }
}
