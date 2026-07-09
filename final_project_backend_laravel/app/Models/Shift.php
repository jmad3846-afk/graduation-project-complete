<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Shift extends Model
{
    use \App\Traits\LogsAudit;

    protected $fillable = [
        'shift_plan_id',
        'date',
        'center_id',
        'type',
        'team_number',
    ];

    protected $casts = [
        'date' => 'date',
    ];

    public function shiftPlan()
    {
        return $this->belongsTo(ShiftPlan::class);
    }

    public function center()
    {
        return $this->belongsTo(Center::class);
    }

    public function assignments()
    {
        return $this->hasMany(ShiftAssignment::class);
    }

    public function polls()
    {
        return $this->hasMany(ShiftPoll::class);
    }

    public function requests()
    {
        return $this->hasMany(ShiftRequest::class);
    }
}