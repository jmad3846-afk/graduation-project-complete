<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class SwapCandidateResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'user_name' => $this->user->name ?? 'Unknown',
            'date' => $this->shift->date,
            'shift_type' => $this->shift->type,
            'center' => $this->shift->center->name ?? null,
            'role' => $this->role,
        ];
    }
}
