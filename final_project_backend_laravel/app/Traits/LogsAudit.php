<?php

namespace App\Traits;

use App\Models\AuditLog;
use Illuminate\Support\Facades\Auth;

trait LogsAudit
{
    /**
     * Boot the trait to hook into Eloquent's model events.
     */
    protected static function bootLogsAudit()
    {
        static::created(function ($model) {
            self::logAction($model, 'created');
        });

        static::updated(function ($model) {
            self::logAction($model, 'updated');
        });

        static::deleted(function ($model) {
            self::logAction($model, 'deleted');
        });
    }

    /**
     * Store the generic Audit Log action.
     */
    protected static function logAction($model, string $action)
    {
        // Capture active user ID via Sanctum/Session safely
        $userId = Auth::id() ?? 1; // Default to System (Admin) if run from CLI or internal queues

        AuditLog::create([
            'user_id' => $userId,
            'action' => $action,
            'entity_type' => class_basename($model),
            'entity_id' => $model->getKey(),
        ]);
    }
}
