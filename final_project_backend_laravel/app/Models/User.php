<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'password',
        'phone',
        'role',
        'rank',
        'center_id',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'password' => 'hashed',
        ];
    }

    /*
    |--------------------------------------------------------------------------
    | Relationships
    |--------------------------------------------------------------------------
    */

    public function center()
    {
        return $this->belongsTo(Center::class);
    }

    public function shiftAssignments()
    {
        return $this->hasMany(ShiftAssignment::class);
    }

    public function shiftPolls()
    {
        return $this->hasMany(ShiftPoll::class);
    }

    public function shiftRequests()
    {
        // Requests made by this user via their assignments
        return $this->hasManyThrough(
            ShiftRequest::class,
            ShiftAssignment::class,
            'user_id', // Foreign key on ShiftAssignment table...
            'requester_assignment_id', // Foreign key on ShiftRequest table...
            'id', // Local key on users table
            'id'  // Local key on shift_assignments table
        );
    }

    public function receivedShiftRequests()
    {
        // Requests targeting this user via assignments
        return $this->hasManyThrough(
            ShiftRequest::class,
            ShiftAssignment::class,
            'user_id',
            'target_assignment_id',
            'id',
            'id'
        );
    }

    public function approvedShiftRequests()
    {
        return $this->hasMany(ShiftRequest::class, 'approved_by');
    }
}
