<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ShiftPoll extends Model
{
    protected $table = 'shift_polls';

    protected $fillable = [
        'shift_plan_id',
        'user_id',
        'role',
        'preferred_days',
        'unavailable_days',
        'status',
        'submitted_at',
    ];

    protected $casts = [
        'preferred_days' => 'array',
        'unavailable_days' => 'array',
        'submitted_at' => 'datetime',
    ];

    public function shiftPlan()
    {
        return $this->belongsTo(ShiftPlan::class, 'shift_plan_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}