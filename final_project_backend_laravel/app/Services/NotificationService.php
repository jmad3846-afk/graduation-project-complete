<?php

namespace App\Services;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

class NotificationService
{
    public function send(array $data): Notification
    {
        $notification = Notification::create($data);
        event(new \App\Events\NotificationCreated($notification));
        return $notification;
    }

    public function getUserNotifications(User $user): Collection
    {
        return Notification::where('user_id', $user->id)->orderByDesc('created_at')->get();
    }
}
