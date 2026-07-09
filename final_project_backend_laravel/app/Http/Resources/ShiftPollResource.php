<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class ShiftPollResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'plan_id' => $this->shift_plan_id,
            'role' => $this->role,
            'status' => $this->status,
            'preferred_shifts' => $this->preferred_days,
            'unavailable_shifts' => $this->unavailable_days,
            'submitted_at' => $this->submitted_at,
        ];
    }
}
