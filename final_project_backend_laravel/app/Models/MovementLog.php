<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MovementLog extends Model
{
    protected $fillable = ['case_id', 'depart_patient', 'arrive_patient', 'depart_hospital', 'arrive_hospital', 'depart_center', 'arrive_center'];

    public function emsCase()
    {
        return $this->belongsTo(EmsCase::class, 'case_id');
    }
}
