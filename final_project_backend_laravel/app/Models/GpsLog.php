<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class GpsLog extends Model
{
    protected $fillable = ['vehicle_id', 'latitude', 'longitude', 'recorded_at'];

    public function vehicle()
    {
        return $this->belongsTo(Vehicle::class);
    }
}
