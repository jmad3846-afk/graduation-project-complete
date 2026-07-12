<?php

use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('App.Models.User.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});

Broadcast::channel('cases.new', function ($user) {
    // Dispatchers/admins triage incoming cases; sector_leader (the lidar
    // operations-room "Leader" dashboard) needs new cases to appear in its
    // Pending Tasks list in real time too.
    return in_array($user->role, ['admin', 'dispatcher', 'sector_leader']);
});

Broadcast::channel('vehicles.{id}', function ($user, $id) {
    // Deprecated public vehicle channel. Keep for backward compatibility but deny access.
    return false;
});

Broadcast::channel('cases.assigned', function ($user) {
    return in_array($user->role, ['admin', 'dispatcher', 'sector_leader', 'radio']);
});

Broadcast::channel('cases.status', function ($user) {
    return in_array($user->role, ['admin', 'dispatcher', 'sector_leader', 'radio']);
});

// Private team channels for operational use
Broadcast::channel('vehicle.{id}', function ($user, $id) {
    if (!$user) return false;
    // user must have an active shift assignment for this vehicle
    return \App\Models\ShiftAssignment::where('user_id', $user->id)
        ->where('vehicle_id', $id)
        ->exists();
});

Broadcast::channel('center.{center_id}', function ($user, $center_id) {
    if (!$user) return false;
    // user must belong to the center
    return (int)$user->center_id === (int)$center_id;
});
// Shift plan reservation channel — shared by every user participating in that
// monthly plan's poll, so reservation locks are visible across users in real time.
Broadcast::channel('shift-plan.{shiftPlanId}', function ($user, $shiftPlanId) {
    return $user != null;
});
