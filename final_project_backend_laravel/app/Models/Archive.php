<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Archive extends Model
{
    protected $table = 'archive';
    protected $fillable = ['case_id', 'disclaimer_image', 'printed', 'archived_at'];

    public function emsCase()
    {
        return $this->belongsTo(EmsCase::class, 'case_id');
    }
}
