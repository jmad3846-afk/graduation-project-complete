<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MovementLog extends Model
{
    protected $fillable = [
        'case_id',
        'depart_patient',
        'arrive_patient',
        'depart_hospital',
        'arrive_hospital',
        'depart_center',
        'arrive_center',
        'team_leader_name',
        'transported',
        'reason_not_transported',
    ];

    protected $casts = [
        'transported' => 'boolean',
        'depart_patient' => 'datetime',
        'arrive_patient' => 'datetime',
        'depart_hospital' => 'datetime',
        'arrive_hospital' => 'datetime',
        'depart_center' => 'datetime',
        'arrive_center' => 'datetime',
    ];

    public function emsCase()
    {
        return $this->belongsTo(EmsCase::class, 'case_id');
    }
}
