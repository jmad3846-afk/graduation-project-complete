<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ShiftPollReservation extends Model
{
    use HasFactory;

    protected $table = 'shift_poll_reservations';

    protected $fillable = [
        'shift_plan_id',
        'center_id',
        'user_id',
        'day',
        'shift_type',
        'rank',
        'status',
        'expires_at',
    ];

    protected $casts = [
        'shift_plan_id' => 'integer',
        'center_id' => 'integer',
        'user_id' => 'integer',
        'day' => 'integer',
        'expires_at' => 'datetime',
    ];

    public function shiftPlan()
    {
        return $this->belongsTo(ShiftPlan::class, 'shift_plan_id');
    }

    public function center()
    {
        return $this->belongsTo(Center::class, 'center_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
?>
