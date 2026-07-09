<?php

namespace App\Http\Controllers;

use App\Models\EmsCase;
use App\Services\CaseService;
use Illuminate\Http\Request;

class CitizenCaseController extends Controller
{
    protected $caseService;

    public function __construct(CaseService $caseService)
    {
        $this->caseService = $caseService;
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'caller_name' => 'required|string|max:255',
            'caller_phone' => 'required|string|max:50',
            'relation' => 'nullable|string|max:100',
            'patient_name' => 'required|string|max:255',
            'age' => 'nullable|integer',
            'weight' => 'nullable|numeric',
            'medical_history' => 'nullable|string',
            'oxygen_level' => 'nullable|numeric',
            'blood_pressure' => 'nullable|string|max:50',
            'blood_sugar' => 'nullable|numeric',
            'conscious' => 'nullable|boolean',
            'has_tube' => 'nullable|boolean',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'destination_hospital' => 'nullable|string|max:255',
        ]);

        $validated['device_id'] = $request->header('X-Device-Id');
        // Assume default red code if patient is unconscious
        $validated['triage_code'] = (isset($validated['conscious']) && $validated['conscious'] === false) ? 'red' : 'yellow';

        $case = $this->caseService->createCase($validated);

        return response()->json([
            'message' => 'Emergency request dispatched successfully.',
            'case_id' => $case->id,
            'tracking_token' => $case->tracking_token,
            'status' => $case->status,
        ], 201);
    }

    public function show(Request $request, $trackingToken)
    {
        \Illuminate\Support\Facades\Log::info("Citizen tracking requested for token {$trackingToken}");

        $case = EmsCase::with(['vehicle', 'center', 'movementLog'])
            ->where('tracking_token', $trackingToken)
            ->first();

        if (!$case) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid tracking token. Please contact emergency services directly if you still require assistance.'
            ], 404);
        }

        // Lightweight device ownership sanity check
        $deviceId = $request->header('X-Device-Id');
        if ($deviceId && $case->device_id !== $deviceId) {
            \Illuminate\Support\Facades\Log::warning("Unauthorized citizen tracking attempt on {$trackingToken}");
            return response()->json(['success' => false, 'message' => 'Unauthorized tracking attempt.'], 403);
        }

        // Readable status mapping
        $statusLabels = [
            'waiting' => 'Waiting for Dispatch',
            'assigned' => 'Assigned',
            'in_progress' => 'On The Way',
            'at_hospital' => 'At Hospital',
            'closed' => 'Closed',
        ];

        // Estimated arrival mock logic (could be tied to actual GPS matrix later)
        $eta = 'Determining...';
        if (in_array($case->status, ['assigned', 'in_progress'])) {
            $eta = '5 - 8 minutes';
        }

        // Polling optimization: Check if status changed
        $lastStatus = $request->query('last_status');
        $statusChanged = $lastStatus && $lastStatus !== $case->status;

        // If closed, return a final optimized summary
        if ($case->status === 'closed') {
            return response()->json([
                'success' => true,
                'id' => $case->id,
                'status' => $case->status,
                'readable_status' => $statusLabels[$case->status] ?? 'Resolved',
                'final_summary' => [
                    'message' => 'This emergency response has been concluded. We wish you a safe recovery.',
                    'closed_at' => $case->updated_at,
                ],
            ]);
        }

        return response()->json([
            'success' => true,
            'id' => $case->id,
            'status' => $case->status,
            'readable_status' => $statusLabels[$case->status] ?? 'Unknown',
            'status_changed' => $statusChanged,
            'estimated_arrival' => $eta,
            'triage_code' => $case->triage_code,
            'assigned_center' => $case->center ? $case->center->name : null,
            'vehicle' => $case->vehicle ? [
                'plate' => $case->vehicle->plate_number,
                'status' => $case->vehicle->status,
                'location' => [
                    'lat' => $case->vehicle->latitude,
                    'lng' => $case->vehicle->longitude,
                ]
            ] : null,
            'movement_timestamps' => $case->movementLog,
            'created_at' => $case->created_at,
        ]);
    }
}
