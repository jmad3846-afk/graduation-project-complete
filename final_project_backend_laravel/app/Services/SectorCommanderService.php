<?php

namespace App\Services;

use App\Models\EmsCase;
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
