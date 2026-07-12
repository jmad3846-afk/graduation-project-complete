<?php

namespace App\Services;

use App\Models\EmsCase;
use App\Models\Shift;
use App\Models\ShiftAssignment;
use App\Models\Center;
use Carbon\Carbon;

class SectorCommanderService
{
    public function getPendingTasks()
    {
        return EmsCase::with(['patient','caller','vehicle','center','movementLog'])
            ->where('status', 'waiting')
            ->orderBy('created_at','desc')
            ->get();
    }

    /**
     * Readiness of every team on today's shifts at the given center: for
     * each (shift, team_number) group, whether the leader/scout/paramedic
     * have checked in. A center can be assigned a task if at least one of
     * its teams is ready (leader and scout checked in; the medic is
     * optional).
     */
    public function getTeamStatusForCenter(int $centerId): ?array
    {
        $shifts = Shift::where('center_id', $centerId)
            ->whereDate('date', now()->toDateString())
            ->with('assignments.user')
            ->orderBy('id')
            ->get();

        if ($shifts->isEmpty()) {
            return null;
        }

        $teams = [];

        foreach ($shifts as $shift) {
            $byTeam = $shift->assignments->groupBy('team_number');

            foreach ($byTeam as $teamNumber => $assignments) {
                $byRole = ['leader' => null, 'scout' => null, 'paramedic' => null];

                foreach ($assignments as $assignment) {
                    if (array_key_exists($assignment->role, $byRole)) {
                        $byRole[$assignment->role] = [
                            'assignment_id' => $assignment->id,
                            'user_id' => $assignment->user_id,
                            'name' => $assignment->user->name ?? null,
                            'status' => $assignment->status,
                            'checked_in_at' => $assignment->checked_in_at?->toDateTimeString(),
                        ];
                    }
                }

                $leaderReady = $byRole['leader'] && $byRole['leader']['status'] === 'done';
                $scoutReady = $byRole['scout'] && $byRole['scout']['status'] === 'done';

                $teams[] = [
                    'shift_id' => $shift->id,
                    'team_number' => (int) $teamNumber,
                    'leader' => $byRole['leader'],
                    'scout' => $byRole['scout'],
                    'paramedic' => $byRole['paramedic'],
                    'can_assign' => $leaderReady && $scoutReady,
                ];
            }
        }

        $readyTeam = collect($teams)->firstWhere('can_assign', true);

        return [
            'teams' => $teams,
            'can_assign' => $readyTeam !== null,
            'ready_team' => $readyTeam,
        ];
    }

    public function getActiveTasks()
    {
        return EmsCase::with(['patient','caller','vehicle','center','movementLog'])
            ->whereIn('status', ['assigned','in_progress','at_hospital'])
            ->orderBy('created_at','desc')
            ->get();
    }

    public function getTeams($date = null)
    {
        $date = $date ? Carbon::parse($date)->toDateString() : Carbon::now()->toDateString();

        $assignments = ShiftAssignment::with('user','vehicle','shift')
            ->whereHas('shift', function($q) use ($date) {
                $q->whereDate('date', $date);
            })
            ->get();

        $groups = $assignments->groupBy(function($a) {
            return $a->vehicle_id ? 'vehicle_'.$a->vehicle_id : 'shift_'.$a->shift_id;
        });

        $teams = $groups->map(function($groupKey) {
            $first = $groupKey->first();
            $vehicle = $first->vehicle;
            $shift = $first->shift;

            $members = $groupKey->map(function($assign) {
                return [
                    'id' => $assign->user->id ?? null,
                    'name' => $assign->user->name ?? null,
                    'role' => $assign->role,
                    'rank' => $assign->user->rank ?? null,
                    'phone' => $assign->user->phone ?? null,
                    'assigned_at' => $assign->assigned_at,
                ];
            })->values()->all();

            return (object)[
                'team_id' => $vehicle ? $vehicle->id : $shift->id,
                'shift_id' => $shift->id ?? null,
                'vehicle_id' => $vehicle->id ?? null,
                'center_id' => $shift->center_id ?? ($vehicle->center_id ?? null),
                'vehicle' => $vehicle ? [
                    'id' => $vehicle->id,
                    'code' => $vehicle->code,
                    'status' => $vehicle->status,
                    'current_lat' => $vehicle->current_lat,
                    'current_lng' => $vehicle->current_lng,
                ] : null,
                'shift_date' => $shift->date ?? null,
                'slots' => $shift->slots ?? null,
                'members' => $members,
            ];
        })->values()->all();

        return $teams;
    }

    public function getCentersWithCounts()
    {
        return Center::withCount(['vehicles'])
            ->withCount(['cases as active_cases_count' => function($q) { $q->whereIn('status',['assigned','in_progress','at_hospital']); }])
            ->withCount(['cases as pending_cases_count' => function($q) { $q->where('status','waiting'); }])
            ->get();
    }
}
