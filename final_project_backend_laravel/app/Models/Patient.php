<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Patient extends Model
{
    protected $fillable = ['case_id', 'full_name', 'age', 'weight', 'medical_history', 'oxygen_level', 'blood_pressure', 'blood_sugar', 'oxygen_before', 'oxygen_after', 'has_tube', 'conscious'];

    public function emsCase()
    {
        return $this->belongsTo(EmsCase::class, 'case_id');
    }
}
