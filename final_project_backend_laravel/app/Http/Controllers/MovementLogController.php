<?php

namespace App\Http\Controllers;

use App\Models\MovementLog;
use Illuminate\Http\Request;

class MovementLogController extends Controller
{
    public function log(Request $request)
    {
        $validated = $request->validate([
            'case_id' => 'required|exists:cases,id',
            'field' => 'required|in:depart_patient,arrive_patient,depart_hospital,arrive_hospital,depart_center,arrive_center',
            'timestamp' => 'required|date_format:H:i:s'
        ]);

        $log = MovementLog::firstOrCreate(['case_id' => $validated['case_id']]);
        
        // Prevent duplicate overwrite if already set
        if ($log->{$validated['field']} !== null) {
            return response()->json(['message' => 'Log already exists'], 422);
        }
        
        $log->update([$validated['field'] => $validated['timestamp']]);

        return response()->json(['message' => 'Log updated successfully', 'data' => $log]);
    }
}
