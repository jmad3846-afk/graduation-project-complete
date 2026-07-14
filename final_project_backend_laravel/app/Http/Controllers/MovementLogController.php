<?php

namespace App\Http\Controllers;

use App\Events\CaseStatusUpdated;
use App\Models\EmsCase;
use App\Models\MovementLog;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class MovementLogController extends Controller
{
    private const TIME_FIELDS = [
        'depart_patient', 'arrive_patient',
        'depart_hospital', 'arrive_hospital',
        'depart_center', 'arrive_center',
    ];

    public function log(Request $request)
    {
        $validated = $request->validate([
            'case_id' => 'required|exists:cases,id',
            'field' => 'required|in:' . implode(',', self::TIME_FIELDS),
            'timestamp' => 'required|date_format:H:i:s'
        ]);

        $log = MovementLog::firstOrCreate(['case_id' => $validated['case_id']]);

        // Prevent duplicate overwrite if already set
        if ($log->{$validated['field']} !== null) {
            return response()->json(['message' => 'Log already exists'], 422);
        }

        $log->update([$validated['field'] => $this->todayAt($validated['timestamp'])]);

        $this->broadcastCaseUpdate($validated['case_id']);

        return response()->json(['message' => 'Log updated successfully', 'data' => $log]);
    }

    /**
     * Upserts the full Radio-interface movement form for a case in one call:
     * all 6 vehicle timestamps, team leader name, whether transport
     * happened, and the reason if it did not. Unlike log(), this allows
     * re-saving as the radio operator fills in the form over time.
     */
    public function save(Request $request)
    {
        $validated = $request->validate([
            'case_id' => 'required|exists:cases,id',
            'depart_patient' => 'nullable|date_format:H:i:s',
            'arrive_patient' => 'nullable|date_format:H:i:s',
            'depart_hospital' => 'nullable|date_format:H:i:s',
            'arrive_hospital' => 'nullable|date_format:H:i:s',
            'depart_center' => 'nullable|date_format:H:i:s',
            'arrive_center' => 'nullable|date_format:H:i:s',
            'team_leader_name' => 'nullable|string',
            'transported' => 'nullable|boolean',
            'reason_not_transported' => 'nullable|string',
        ]);

        $caseId = $validated['case_id'];
        unset($validated['case_id']);

        foreach (self::TIME_FIELDS as $field) {
            if (array_key_exists($field, $validated) && $validated[$field] !== null) {
                $validated[$field] = $this->todayAt($validated[$field]);
            }
        }

        $log = MovementLog::firstOrCreate(['case_id' => $caseId]);
        $log->update($validated);

        $this->broadcastCaseUpdate($caseId);

        return response()->json(['message' => 'Movement log saved', 'data' => $log]);
    }

    private function todayAt(string $time): string
    {
        return Carbon::today()->setTimeFromTimeString($time)->toDateTimeString();
    }

    /**
     * Radio-set movement timestamps are the primary live signal the Leader
     * dashboard reacts to, so reuse the existing case.status.updated
     * broadcast (same channels/listeners as coarse status transitions)
     * rather than adding a second event type for Leader screens to bind to.
     */
    private function broadcastCaseUpdate(int $caseId): void
    {
        $case = EmsCase::with('movementLog')->find($caseId);

        if ($case) {
            event(new CaseStatusUpdated($case));
        }
    }
}
