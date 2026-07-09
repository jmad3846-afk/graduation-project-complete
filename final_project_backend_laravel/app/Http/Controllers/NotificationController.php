<?php

namespace App\Http\Controllers;

use App\Services\NotificationService;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    public function send(Request $request)
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'title' => 'required|string',
            'message' => 'required|string',
        ]);

        $notification = $this->notificationService->send($validated);
        return response()->json(['message' => 'Notification sent', 'notification' => $notification], 201);
    }

    public function getUserNotifications(Request $request)
    {
        $notifications = $this->notificationService->getUserNotifications($request->user());
        return response()->json(['notifications' => $notifications]);
    }
}
