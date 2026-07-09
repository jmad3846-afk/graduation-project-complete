<?php

namespace App\Http\Controllers;

use App\Models\ShiftPlan;
use App\Models\ShiftPoll;
use App\Models\ShiftAssignment;
use Illuminate\Http\Request;

class ShiftStatisticsController extends Controller
{
    public function currentPlan(Request $request)
    {
        $plan = ShiftPlan::orderByDesc('created_at')->first();
        if (! $plan) return response()->json(null, 204);

        $total_leaders = \App\Models\User::where('role','paramedic')->where('rank','leader')->count();
        $total_scouts = \App\Models\User::where('role','paramedic')->where('rank','scout')->count();
        $total_paramedics = \App\Models\User::where('role','paramedic')->where('rank','paramedic')->count();

        $total_polls = ShiftPoll::where('shift_plan_id', $plan->id)->count();
        $submitted_polls = ShiftPoll::where('shift_plan_id', $plan->id)->where('status','submitted')->count();

        $total_assignments = ShiftAssignment::whereHas('shift', function ($q) use ($plan) {
            $q->where('shift_plan_id', $plan->id);
        })->count();

        $unfilled = [];

        return response()->json([
            'plan_id' => $plan->id,
            'total_leaders' => $total_leaders,
            'total_scouts' => $total_scouts,
            'total_paramedics' => $total_paramedics,
            'total_polls' => $total_polls,
            'submitted_polls' => $submitted_polls,
            'completion_percentage' => $total_polls ? round($submitted_polls / $total_polls * 100, 2) : 0,
            'total_assignments' => $total_assignments,
            'unfilled_slots' => $unfilled,
        ]);
    }
}
