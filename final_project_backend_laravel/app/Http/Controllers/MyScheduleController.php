<?php

namespace App\Http\Controllers;

use App\Http\Resources\AssignmentResource;
use App\Models\ShiftAssignment;
use Illuminate\Http\Request;

class MyScheduleController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $assignments = ShiftAssignment::where('user_id', $user->id)
            ->whereHas('shift', function ($q) { $q->where('date', '>=', now()->toDateString()); })
            ->with(['shift.center'])
            ->orderBy('assigned_at')
            ->get();

        return AssignmentResource::collection($assignments);
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
