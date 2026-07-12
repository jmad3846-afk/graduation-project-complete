<?php

namespace App\Services;

use App\Models\Center;
use App\Models\EmsCase;
use App\Models\Shift;
use Carbon\Carbon;

class OverviewService
{
    public function getActiveTasks()
    {
        return EmsCase::with(['patient', 'caller', 'vehicle', 'center', 'movementLog'])
            ->whereIn('status', ['assigned', 'in_progress', 'at_hospital'])
            ->orderBy('created_at', 'desc')
            ->get();
    }

    /**
     * Per-center breakdown: active vs. completed case counts, each split
     * by triage code (red/yellow/green).
     */
    public function getCentersOverview()
    {
        $centers = Center::withCount(['vehicles'])->get();

        $triageCodes = ['red', 'yellow', 'green'];

        return $centers->map(function (Center $center) use ($triageCodes) {
            $activeByTriage = EmsCase::where('center_id', $center->id)
                ->whereIn('status', ['assigned', 'in_progress', 'at_hospital'])
                ->selectRaw('triage_code, count(*) as total')
                ->groupBy('triage_code')
                ->pluck('total', 'triage_code');

            $completedByTriage = EmsCase::where('center_id', $center->id)
                ->where('status', 'closed')
                ->selectRaw('triage_code, count(*) as total')
                ->groupBy('triage_code')
                ->pluck('total', 'triage_code');

            $fill = fn ($counts) => collect($triageCodes)
                ->mapWithKeys(fn ($code) => [$code => (int) ($counts[$code] ?? 0)])
                ->all();

            return [
                'id' => $center->id,
                'name' => $center->name,
                'location' => $center->location,
                'status' => $center->status,
                'vehicle_count' => $center->vehicles_count,
                'active_by_triage' => $fill($activeByTriage),
                'completed_by_triage' => $fill($completedByTriage),
                'active_total' => array_sum($fill($activeByTriage)),
                'completed_total' => array_sum($fill($completedByTriage)),
            ];
        })->values();
    }

    /**
     * Shift and task (case) counts for a center over a day/week/month period
     * containing today.
     */
    public function getCenterStatistics(int $centerId, string $period): array
    {
        [$start, $end] = $this->periodBounds($period);

        $shifts = Shift::where('center_id', $centerId)
            ->whereBetween('date', [$start->toDateString(), $end->toDateString()])
            ->count();

        $tasks = EmsCase::where('center_id', $centerId)
            ->whereBetween('created_at', [$start->startOfDay(), $end->endOfDay()])
            ->count();

        return [
            'center_id' => $centerId,
            'period' => $period,
            'start' => $start->toDateString(),
            'end' => $end->toDateString(),
            'shifts' => $shifts,
            'tasks' => $tasks,
        ];
    }

    private function periodBounds(string $period): array
    {
        $now = Carbon::now();

        return match ($period) {
            'week' => [$now->copy()->startOfWeek(), $now->copy()->endOfWeek()],
            'month' => [$now->copy()->startOfMonth(), $now->copy()->endOfMonth()],
            default => [$now->copy()->startOfDay(), $now->copy()->endOfDay()],
        };
    }
}
