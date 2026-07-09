<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class AssignmentResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'date' => $this->shift->date,
            'shift_type' => $this->shift->type,
            'center' => $this->shift->center->name ?? null,
            'role' => $this->role,
            'team_number' => $this->team_number,
            'vehicle_id' => $this->vehicle_id,
        ];
    }
}
