<?php

namespace App\Http\Controllers;

use App\Http\Resources\AssignmentResource;
use App\Models\ShiftAssignment;
use App\Models\ShiftPlan;
use App\Services\ShiftPlanService;
use Illuminate\Http\Request;

class MyScheduleController extends Controller
{
    /**
     * Current user's assignments plus this month's compensation, for the
     * "My Schedule" screen. Resolves the "current" plan as the most recently
     * published plan (falls back to the latest plan overall if none is
     * published yet), so this keeps working the same way it always has for
     * existing callers that only read the assignment list.
     */
    public function index(Request $request)
    {
        $user = $request->user();

        $plan = ShiftPlan::where('status', 'published')->orderByDesc('published_at')->first()
            ?? ShiftPlan::orderByDesc('created_at')->first();

        if (!$plan) {
            return response()->json([
                'month' => (int) now()->month,
                'year' => (int) now()->year,
                'compensation' => 0,
                'shift_count' => 0,
                'assignments' => [],
            ]);
        }

        $assignments = ShiftAssignment::where('user_id', $user->id)
            ->whereHas('shift', function ($q) use ($plan) { $q->where('shift_plan_id', $plan->id); })
            ->with(['shift.center'])
            ->orderBy('assigned_at')
            ->get();

        // Only attended (checked-in) shifts count toward the shown shift
        // count and compensation — a "selected" shift the user never
        // checked into is not paid.
        $attendedCount = $assignments->where('status', 'done')->count();

        return response()->json([
            'month' => $plan->month,
            'year' => $plan->year,
            'compensation' => $attendedCount * ShiftPlanService::COMPENSATION_PER_SHIFT,
            'shift_count' => $attendedCount,
            'assignments' => AssignmentResource::collection($assignments),
        ]);
    }

    public function month(Request $request, $month, $year)
    {
        $user = $request->user();
        $assignments = ShiftAssignment::where('user_id', $user->id)
            ->whereHas('shift', function ($q) use ($month, $year) {
                $q->whereMonth('date', $month)->whereYear('date', $year);
            })->with(['shift.center'])->orderBy('shift.date')->get();

        return AssignmentResource::collection($assignments);
    }
}
