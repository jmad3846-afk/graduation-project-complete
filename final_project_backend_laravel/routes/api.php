<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\CaseController;
use App\Http\Controllers\VehicleController;
use App\Http\Controllers\GpsController;
use App\Http\Controllers\ShiftController;
use App\Http\Controllers\NotificationController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ParamedicAuthController;

// Public Authentication Endpoints
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/paramedic/login', [ParamedicAuthController::class, 'login']);

// Citizen External Mobile APIs
Route::prefix('citizen')->group(function () {
    Route::post('/cases', [\App\Http\Controllers\CitizenCaseController::class, 'store']);
    Route::get('/cases/{trackingToken}', [\App\Http\Controllers\CitizenCaseController::class, 'show']);
});

// Protected Endpoints
Route::middleware('auth:sanctum')->group(function () {

    // User Context
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // CASES API
    Route::get('/cases', [CaseController::class, 'index']);
    Route::post('/cases', [CaseController::class, 'store']);
    Route::put('/cases/{id}', [CaseController::class, 'update']);
    Route::patch('/cases/{id}/center', [CaseController::class, 'assignCenter']);
    Route::patch('/cases/{id}/status', [CaseController::class, 'changeStatus']);
    
    // ARCHIVE & MOVEMENT LOGS
    Route::post('/movement_logs', [\App\Http\Controllers\MovementLogController::class, 'log']);
    Route::post('/archives', [\App\Http\Controllers\ArchiveController::class, 'store']);

    // CENTERS API
    Route::get('/centers', [\App\Http\Controllers\CenterController::class, 'index']);

    // Sector Commander Dashboard
    Route::get('/sector-commander/dashboard', [\App\Http\Controllers\SectorCommanderController::class, 'dashboardResponse']);

    // VEHICLES API
    Route::get('/vehicles', [VehicleController::class, 'index']);
    Route::patch('/vehicles/{id}/location', [VehicleController::class, 'updateLocation']);
    Route::patch('/vehicles/{id}/status', [VehicleController::class, 'changeStatus']);

    // GPS TRACKING API
    Route::post('/gps', [GpsController::class, 'store']);
    Route::get('/vehicles/{vehicle_id}/live-location', [GpsController::class, 'liveLocation']);

    // SHIFTS API
    Route::post('/shifts', [ShiftController::class, 'store']);
    Route::post('/shifts/{id}/assign', [ShiftController::class, 'assignShift']);
    Route::post('/shifts/{id}/poll', [ShiftController::class, 'submitPoll']);
    Route::post('/shifts/{id}/swap-request', [ShiftController::class, 'swapRequest']);

    // NOTIFICATIONS API
    Route::post('/notifications', [NotificationController::class, 'send']);
    Route::get('/notifications', [NotificationController::class, 'getUserNotifications']);

    // PARAMEDIC SCOPES
    Route::prefix('paramedic')->group(function () {
        Route::get('/my-cases', [\App\Http\Controllers\ParamedicController::class, 'myCases']);
        Route::get('/center-cases', [\App\Http\Controllers\ParamedicController::class, 'centerCases']);
        Route::post('/logout', [ParamedicAuthController::class, 'logout']);
        Route::get('/cases/{id}', [\App\Http\Controllers\ParamedicController::class, 'show']);
        Route::patch('/cases/{id}/status', [\App\Http\Controllers\ParamedicController::class, 'updateStatus']);
        // Shift APIs
        Route::get('/shifts', [\App\Http\Controllers\ParamedicShiftController::class, 'myShifts']);
        Route::get('/shift-poll', [\App\Http\Controllers\ParamedicShiftController::class, 'activePoll']);
        Route::post('/shift-request', [\App\Http\Controllers\ParamedicShiftController::class, 'requestShift']);
        Route::get('/shift-requests', [\App\Http\Controllers\ParamedicShiftController::class, 'myRequests']);
    });

    // Admin: approve/reject shift requests
    Route::post('/admin/shift-requests/{id}/approve', function ($id, Request $request, \App\Services\ShiftService $shiftService) {
        $user = $request->user();
        if (!in_array($user->role, ['admin','manager'])) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $vehicleId = $request->input('vehicle_id');
        try {
            $req = $shiftService->approveRequest((int)$id, $user, $vehicleId);
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json(['message' => 'Request approved', 'request' => $req]);
    });
    Route::post('/admin/shift-requests/{id}/reject', function ($id, Request $request, \App\Services\ShiftService $shiftService) {
        $user = $request->user();
        if (!in_array($user->role, ['admin','manager'])) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        try {
            $req = $shiftService->rejectRequest((int)$id, $user);
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json(['message' => 'Request rejected', 'request' => $req]);
    });

    // Shift Management APIs (Admin)
    Route::prefix('admin')->middleware('role:admin')->group(function () {
        Route::post('/shift-plans', [\App\Http\Controllers\ShiftPlanController::class, 'store']);
        Route::get('/shift-plans', [\App\Http\Controllers\ShiftPlanController::class, 'index']);
        Route::get('/shift-plans/{id}', [\App\Http\Controllers\ShiftPlanController::class, 'show']);
        Route::post('/shift-plans/{id}/start-leader-poll', [\App\Http\Controllers\ShiftPlanController::class, 'startLeaderPoll']);
        Route::post('/shift-plans/{id}/start-scout-poll', [\App\Http\Controllers\ShiftPlanController::class, 'startScoutPoll']);
        Route::post('/shift-plans/{id}/start-paramedic-poll', [\App\Http\Controllers\ShiftPlanController::class, 'startParamedicPoll']);
        Route::post('/shift-plans/{id}/build', [\App\Http\Controllers\ShiftPlanController::class, 'build']);
        Route::post('/shift-plans/{id}/publish', [\App\Http\Controllers\ShiftPlanController::class, 'publish']);
        Route::post('/shift-plans/{id}/close', [\App\Http\Controllers\ShiftPlanController::class, 'close']);
        Route::get('/shift-plans/{id}/schedule', [\App\Http\Controllers\ShiftPlanController::class, 'schedule']);
        Route::post('/shift-plans/{id}/send-schedule', [\App\Http\Controllers\ShiftPlanController::class, 'sendSchedule']);

        // shift request admin actions
        Route::post('/shift-requests/{id}/approve', [\App\Http\Controllers\ShiftRequestController::class, 'approve']);
        Route::post('/shift-requests/{id}/cancel', [\App\Http\Controllers\ShiftRequestController::class, 'cancel']);

        Route::get('/shift-statistics/current-plan', [\App\Http\Controllers\ShiftStatisticsController::class, 'currentPlan']);
    });

    // Poll APIs (authenticated users)
    Route::get('/shift-polls/current', [\App\Http\Controllers\ShiftPollController::class, 'current']);
    Route::post('/shift-polls/{id}/submit', [\App\Http\Controllers\ShiftPollController::class, 'submit']);
    Route::get('/shift-polls/history', [\App\Http\Controllers\ShiftPollController::class, 'history']);
    // Reservation endpoints, scoped by shift_plan_id so all users on the same
    // monthly plan share one reservation pool (see ShiftReservationService).
    Route::post('/shift-plans/{plan}/reserve', [\App\Http\Controllers\ShiftPollController::class, 'reserve']);
    Route::post('/shift-plans/{plan}/release', [\App\Http\Controllers\ShiftPollController::class, 'release']);
    Route::post('/shift-plans/{plan}/confirm', [\App\Http\Controllers\ShiftPollController::class, 'confirm']);
    Route::get('/shift-plans/{plan}/reservations', [\App\Http\Controllers\ShiftPollController::class, 'reservations']);
    // My schedule
    Route::get('/my-schedule', [\App\Http\Controllers\MyScheduleController::class, 'index']);
    Route::get('/my-schedule/month/{month}/{year}', [\App\Http\Controllers\MyScheduleController::class, 'month']);

    // Shift requests
    Route::get('/shift-requests/candidates', [\App\Http\Controllers\ShiftRequestController::class, 'candidates']);
    Route::post('/shift-requests', [\App\Http\Controllers\ShiftRequestController::class, 'store']);
    Route::get('/shift-requests', [\App\Http\Controllers\ShiftRequestController::class, 'index']);
    Route::get('/shift-requests/pending', [\App\Http\Controllers\ShiftRequestController::class, 'pending']);
    Route::post('/shift-requests/{id}/reject', [\App\Http\Controllers\ShiftRequestController::class, 'reject']);

    // DEBUG TESTING
    Route::delete('/debug/reset', function () {
        if (!in_array(request()->user()->role, ['admin'])) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }
        
        \Illuminate\Support\Facades\DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        \App\Models\EmsCase::truncate();
        \App\Models\MovementLog::truncate();
        \App\Models\Notification::truncate();
        \App\Models\Patient::truncate();
        \App\Models\Caller::truncate();
        \App\Models\Archive::truncate();
        \Illuminate\Support\Facades\DB::statement('SET FOREIGN_KEY_CHECKS=1;');
        
        return response()->json(['message' => 'Test environment reset.']);
    });
});
