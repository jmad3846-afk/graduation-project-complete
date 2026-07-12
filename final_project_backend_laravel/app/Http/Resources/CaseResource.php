<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class CaseResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     */
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'status' => $this->status,
            'triage_code' => $this->triage_code,
            'center' => $this->whenLoaded('center', function() { return [
                'id' => $this->center->id ?? null,
                'name' => $this->center->name ?? null,
                'status' => $this->center->status ?? null,
            ]; }),
            'vehicle' => $this->whenLoaded('vehicle', function() { return $this->vehicle ? [
                'id' => $this->vehicle->id,
                'code' => $this->vehicle->code,
                'status' => $this->vehicle->status,
                'current_lat' => $this->vehicle->current_lat,
                'current_lng' => $this->vehicle->current_lng,
            ] : null; }),
            'patient' => $this->whenLoaded('patient', function() { return $this->patient ? [
                'id' => $this->patient->id,
                'full_name' => $this->patient->full_name ?? null,
                'age' => $this->patient->age ?? null,
            ] : null; }),
            'caller' => $this->whenLoaded('caller', function() { return $this->caller ? [
                'id' => $this->caller->id,
                'name' => $this->caller->name ?? null,
                'phone' => $this->caller->phone ?? null,
            ] : null; }),
            'movement_log' => $this->whenLoaded('movementLog', function() { return $this->movementLog ? [
                'depart_patient' => $this->movementLog->depart_patient?->format('H:i'),
                'arrive_patient' => $this->movementLog->arrive_patient?->format('H:i'),
                'depart_hospital' => $this->movementLog->depart_hospital?->format('H:i'),
                'arrive_hospital' => $this->movementLog->arrive_hospital?->format('H:i'),
                'depart_center' => $this->movementLog->depart_center?->format('H:i'),
                'arrive_center' => $this->movementLog->arrive_center?->format('H:i'),
                'team_leader_name' => $this->movementLog->team_leader_name,
                'transported' => $this->movementLog->transported,
                'reason_not_transported' => $this->movementLog->reason_not_transported,
            ] : null; }),
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'destination_hospital' => $this->destination_hospital,
            'tracking_token' => $this->tracking_token,
            'created_at' => $this->created_at?->toDateTimeString(),
            'updated_at' => $this->updated_at?->toDateTimeString(),
        ];
    }
}
