<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class ShiftRequestResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'requester_assignment_id' => $this->requester_assignment_id,
            'target_assignment_id' => $this->target_assignment_id,
            'requester_name' => $this->requesterAssignment ? ($this->requesterAssignment->user ? $this->requesterAssignment->user->name : 'Unknown') : 'Unknown',
            'target_name' => $this->targetAssignment ? ($this->targetAssignment->user ? $this->targetAssignment->user->name : 'Unknown') : 'Unknown',
            'role' => $this->requesterAssignment ? $this->requesterAssignment->role : 'Unknown',
            'reason' => $this->reason,
            'status' => $this->status,
            'approved_by' => $this->approved_by,
            'approved_at' => $this->approved_at,
            'created_at' => $this->created_at,
        ];
    }
}
