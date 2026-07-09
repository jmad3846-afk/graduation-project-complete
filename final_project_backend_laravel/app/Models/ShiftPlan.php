<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ShiftPlan extends Model
{
    protected $fillable = [
        'month',
        'year',
        'status',
        'published_at',
        'created_by',
    ];

    protected $casts = [
        'published_at' => 'datetime',
    ];

    public function shifts()
    {
        return $this->hasMany(Shift::class);
    }

    public function polls()
    {
        return $this->hasMany(ShiftPoll::class, 'shift_plan_id');
    }

    public function createdBy()
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}