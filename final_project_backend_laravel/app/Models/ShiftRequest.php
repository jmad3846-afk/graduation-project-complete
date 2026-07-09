<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ShiftRequest extends Model
{
    protected $fillable = [
        'requester_assignment_id',
        'target_assignment_id',
        'reason',
        'status',
        'approved_by',
        'approved_at',
    ];

    protected $casts = [
        'approved_at' => 'datetime',
    ];

    public function requesterAssignment()
    {
        return $this->belongsTo(ShiftAssignment::class, 'requester_assignment_id');
    }

    public function targetAssignment()
    {
        return $this->belongsTo(ShiftAssignment::class, 'target_assignment_id');
    }

    public function approver()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }
}
