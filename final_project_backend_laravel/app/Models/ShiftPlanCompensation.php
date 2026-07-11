<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ShiftPlanCompensation extends Model
{
    protected $table = 'shift_plan_compensations';

    protected $fillable = [
        'shift_plan_id',
        'user_id',
        'monthly_shift_count',
        'monthly_compensation',
    ];

    public function shiftPlan()
    {
        return $this->belongsTo(ShiftPlan::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
