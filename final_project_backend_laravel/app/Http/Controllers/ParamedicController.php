<?php

namespace App\Http\Controllers;

use App\Models\EmsCase;
use App\Models\ShiftAssignment;
use Illuminate\Http\Request;
use App\Services\CaseService;
use Illuminate\Validation\ValidationException;

class ParamedicController extends Controller
{
    public function myCases(Request $request)
    {
        $user = $request->user();

        if (!$user || $user->role !== 'paramedic') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $assignedVehicleIds = ShiftAssignment::where('user_id', $user->id)
            ->whereNotNull('vehicle_id')
            ->pluck('vehicle_id')
            ->toArray();

        if (empty($assignedVehicleIds)) {
            return response()->json([]);
        }

        $cases = EmsCase::with(['patient', 'caller', 'vehicle', 'center', 'movementLog'])
            ->whereIn('vehicle_id', $assignedVehicleIds)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($cases);
    }

    public function centerCases(Request $request)
    {
        $user = $request->user();

        if (!$user || $user->role !== 'paramedic') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $centerId = $user->center_id;
        if (!$centerId) {
            return response()->json([]);
        }

        $cases = EmsCase::with(['patient', 'caller', 'vehicle', 'center', 'movementLog'])
            ->where('center_id', $centerId)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($cases);
    }

    public function show(Request $request, $id)
    {
        $user = $request->user();

        if (!$user || $user->role !== 'paramedic') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $case = EmsCase::with(['patient', 'caller', 'vehicle', 'center', 'movementLog'])->findOrFail($id);

        $assignedVehicleIds = ShiftAssignment::where('user_id', $user->id)
            ->whereNotNull('vehicle_id')
            ->pluck('vehicle_id')
            ->toArray();

        if (empty($assignedVehicleIds) || !in_array($case->vehicle_id, $assignedVehicleIds)) {
            return response()->json(['message' => 'Forbidden: not assigned to this case'], 403);
        }

        return response()->json($case);
    }

    public function updateStatus(Request $request, $id, CaseService $caseService)
    {
        $user = $request->user();

        if (!$user || $user->role !== 'paramedic') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'status' => 'required|in:assigned,in_progress,at_hospital,closed'
        ]);

        try {
            $case = $caseService->changeStatus((int)$id, $request->status);
        } catch (ValidationException $e) {
            return response()->json(['errors' => $e->errors()], 422);
        }

        return response()->json(['message' => 'Status updated', 'case' => $case]);
    }
}
