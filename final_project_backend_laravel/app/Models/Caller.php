<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Caller extends Model
{
    protected $fillable = ['case_id', 'name', 'relation', 'phone'];

    public function emsCase()
    {
        return $this->belongsTo(EmsCase::class, 'case_id');
    }
}
