<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Services\ShiftReservationService;

class CleanupExpiredReservations extends Command
{
    /**
     * The name and signature of the console command.
     */
    protected $signature = 'shifts:cleanup-expired';

    /**
     * The console command description.
     */
    protected $description = 'Cleanup expired shift poll reservations';

    /**
     * Execute the console command.
     */
    public function handle(ShiftReservationService $service)
    {
        $service->cleanupExpiredReservations();
        $this->info('Expired reservations cleaned up');
    }
}
?>
