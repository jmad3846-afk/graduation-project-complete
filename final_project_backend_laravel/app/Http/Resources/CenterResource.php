<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class CenterResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'location' => $this->location ?? null,
            'status' => $this->status ?? null,
            'vehicle_count' => $this->vehicles_count ?? 0,
            'active_cases_count' => $this->active_cases_count ?? 0,
            'pending_cases_count' => $this->pending_cases_count ?? 0,
        ];
    }
}
