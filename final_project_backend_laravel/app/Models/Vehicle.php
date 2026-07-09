<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Vehicle extends Model
{
    protected $fillable = ['code', 'status', 'current_lat', 'current_lng', 'center_id'];

    public function center()
    {
        return $this->belongsTo(Center::class);
    }

    public function gpsLogs()
    {
        return $this->hasMany(GpsLog::class);
    }

    public function cases()
    {
        return $this->hasMany(EmsCase::class);
    }
}
