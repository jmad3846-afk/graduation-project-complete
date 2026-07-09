<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Shift;
use App\Models\ShiftAssignment;
use App\Services\NotificationService;
use Carbon\Carbon;

class SendUpcomingShiftReminders extends Command
{
    protected $signature = 'shifts:send-reminders {--hours=1 : Remind for shifts starting within N hours}';
    protected $description = 'Send reminders to paramedics for upcoming shifts';

    public function handle(NotificationService $notificationService)
    {
        $hours = (int)$this->option('hours');
        $now = Carbon::now();
        $windowStart = $now;
        $windowEnd = $now->copy()->addHours($hours);

        $shifts = Shift::whereBetween('date', [$windowStart->toDateString(), $windowEnd->toDateString()])->get();

        foreach ($shifts as $shift) {
            $assignments = ShiftAssignment::where('shift_id', $shift->id)->get();
            foreach ($assignments as $assignment) {
                $notificationService->send([
                    'user_id' => $assignment->user_id,
                    'title' => 'Upcoming shift',
                    'message' => "You have an upcoming shift on {$shift->date} ({$shift->type}).",
                    'data' => ['shift_id' => $shift->id, 'date' => $shift->date, 'type' => $shift->type],
                    'is_read' => false
                ]);
            }
        }

        $this->info('Shift reminders sent.');
    }
}
