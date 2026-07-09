<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Gate;
use App\Models\ShiftRequest;
use App\Models\ShiftAssignment;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Gate::define('admin', function ($user) {
            return in_array($user->role, ['admin','manager']);
        });

        Gate::define('manage-shift-request', function ($user, ShiftRequest $sr) {
            // admin/manager or requester/target user
            if (in_array($user->role, ['admin','manager'])) return true;
            $req = ShiftAssignment::find($sr->requester_assignment_id);
            $tgt = ShiftAssignment::find($sr->target_assignment_id);
            return ($req && $req->user_id === $user->id) || ($tgt && $tgt->user_id === $user->id);
        });
    }
}
