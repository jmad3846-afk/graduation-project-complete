<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ShiftAssignment extends Model
{
    use \App\Traits\LogsAudit;

    protected $fillable = [
        'shift_id',
        'user_id',
        'role',
        'team_number',
        'vehicle_id',
        'assigned_at',
        'status',
        'checked_in_at',
        'checked_in_by',
    ];

    protected $casts = [
        'assigned_at' => 'datetime',
        'checked_in_at' => 'datetime',
    ];

    public function shift()
    {
        return $this->belongsTo(Shift::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function checkedInBy()
    {
        return $this->belongsTo(User::class, 'checked_in_by');
    }

    public function vehicle()
    {
        return $this->belongsTo(Vehicle::class);
    }
}