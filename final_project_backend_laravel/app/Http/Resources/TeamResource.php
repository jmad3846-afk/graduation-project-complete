<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class TeamResource extends JsonResource
{
    public function toArray($request): array
    {
        $data = $this->resource;

        return [
            'team_id' => $data->team_id ?? null,
            'shift_id' => $data->shift_id ?? null,
            'vehicle_id' => $data->vehicle_id ?? null,
            'center_id' => $data->center_id ?? null,
            'vehicle' => $data->vehicle ?? null,
            'shift_date' => $data->shift_date ?? null,
            'slots' => $data->slots ?? null,
            'members' => $data->members ?? [],
        ];
    }
}
