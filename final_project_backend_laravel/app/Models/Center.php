<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Center extends Model
{
    protected $fillable = ['name', 'location', 'status'];

    public function vehicles()
    {
        return $this->hasMany(Vehicle::class);
    }

    public function cases()
    {
        return $this->hasMany(EmsCase::class);
    }
}
