<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class ShiftPlanResource extends JsonResource
{
    public function toArray($request): array
    {
        $plan = $this;

        return [
            'id' => $plan->id,
            'month' => $plan->month,
            'year' => $plan->year,
            'status' => $plan->status,
            'published_at' => $plan->published_at,
            'created_by' => $plan->created_by,
            'statistics' => [
                'total_shifts' => $plan->shifts()->count(),
                'total_assignments' => \App\Models\ShiftAssignment::whereHas('shift', function ($q) use ($plan) { $q->where('shift_plan_id', $plan->id); })->count(),
                'total_polls' => \App\Models\ShiftPoll::where('shift_plan_id', $plan->id)->count(),
                'completed_polls' => \App\Models\ShiftPoll::where('shift_plan_id', $plan->id)->where('status','submitted')->count(),
            ],
        ];
    }
}
