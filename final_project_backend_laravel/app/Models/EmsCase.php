<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EmsCase extends Model
{
    use \App\Traits\LogsAudit;

    protected $table = 'cases';
    protected $fillable = ['center_id', 'vehicle_id', 'triage_code', 'transfer_type', 'status', 'symptoms', 'breathing_rate', 'medical_aid_given', 'latitude', 'longitude', 'destination_hospital', 'device_id', 'tracking_token', 'operations_officer', 'sector_commander'];

    public function center()
    {
        return $this->belongsTo(Center::class);
    }

    public function vehicle()
    {
        return $this->belongsTo(Vehicle::class);
    }

    public function patient()
    {
        return $this->hasOne(Patient::class, 'case_id');
    }

    public function caller()
    {
        return $this->hasOne(Caller::class, 'case_id');
    }

    public function movementLog()
    {
        return $this->hasOne(MovementLog::class, 'case_id');
    }
}
