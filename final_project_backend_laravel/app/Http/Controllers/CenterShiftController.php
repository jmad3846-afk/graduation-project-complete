<?php

namespace App\Http\Controllers;

use App\Models\Shift;
use App\Models\ShiftAssignment;
use Illuminate\Http\Request;

class CenterShiftController extends Controller
{
    /**
     * The next upcoming shift (today or later) for the caller's center,
     * with one row per team, each row's leader/scout/paramedic assignments.
     * Pass ?after_shift_id= to fetch the shift following a given one (used
     * by the dashboard's "Next Shift" button once the current shift's
     * assignments are all checked in).
     */
    public function upcoming(Request $request)
    {
        $user = $request->user();

        // center_manager is locked to their own center; admin may pass
        // ?center_id= to pick a center (defaults to their own if set).
        $centerId = $user->role === 'admin'
            ? ($request->query('center_id') ?? $user->center_id)
            : $user->center_id;

        if (!$centerId) {
            return response()->json(['message' => 'No center assigned to this user'], 422);
        }

        $query = Shift::where('center_id', $centerId)
            ->whereDate('date', '>=', now()->toDateString())
            ->with(['assignments.user'])
            ->orderBy('date')
            ->orderBy('id');

        $afterShiftId = $request->query('after_shift_id');
        if ($afterShiftId) {
            $afterShift = Shift::find($afterShiftId);
            if ($afterShift) {
                $query->where(function ($q) use ($afterShift) {
                    $q->where('date', '>', $afterShift->date)
                        ->orWhere(function ($q2) use ($afterShift) {
                            $q2->where('date', $afterShift->date)->where('id', '>', $afterShift->id);
                        });
                });
            }
        }

        $shift = $query->first();

        if (!$shift) {
            return response()->json(['shift' => null]);
        }

        return response()->json(['shift' => $this->shiftPayload($shift)]);
    }

    private function shiftPayload(Shift $shift): array
    {
        $teams = [];
        for ($team = 1; $team <= $shift->team_number; $team++) {
            $byRole = ['leader' => null, 'scout' => null, 'paramedic' => null];

            foreach ($shift->assignments as $assignment) {
                if ((int) $assignment->team_number === $team && array_key_exists($assignment->role, $byRole)) {
                    $byRole[$assignment->role] = [
                        'assignment_id' => $assignment->id,
                        'user_id' => $assignment->user_id,
                        'name' => $assignment->user->name ?? null,
                        'status' => $assignment->status,
                        'checked_in_at' => $assignment->checked_in_at?->toDateTimeString(),
                    ];
                }
            }

            $teams[] = [
                'team' => $team,
                'leader' => $byRole['leader'],
                'scout' => $byRole['scout'],
                'paramedic' => $byRole['paramedic'],
            ];
        }

        return [
            'shift_id' => $shift->id,
            'date' => $shift->date,
            'shift_type' => $shift->type,
            'teams' => $teams,
        ];
    }

    /**
     * Mark a shift assignment as attended ("done"). Restricted to
     * center_manager/admin, scoped to the caller's own center.
     */
    public function checkIn(Request $request, $assignmentId)
    {
        $user = $request->user();

        if (!in_array($user->role, ['admin', 'center_manager'])) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $assignment = ShiftAssignment::with('shift')->findOrFail($assignmentId);

        if ($user->role === 'center_manager' && $assignment->shift->center_id !== $user->center_id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        if ($assignment->status === 'done') {
            return response()->json(['message' => 'This assignment is already checked in'], 422);
        }

        $assignment->status = 'done';
        $assignment->checked_in_at = now();
        $assignment->checked_in_by = $user->id;
        $assignment->save();

        return response()->json([
            'message' => 'Checked in',
            'assignment' => [
                'assignment_id' => $assignment->id,
                'status' => $assignment->status,
                'checked_in_at' => $assignment->checked_in_at?->toDateTimeString(),
            ],
        ]);
    }
}
