<?php

namespace App\Events;

use App\Models\EmsCase;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

// Broadcasts immediately (not queued) so a new report reaches the leader's
// Pending Tasks list without depending on a queue worker being run.
class CaseCreated implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $case;

    /**
     * Create a new event instance.
     */
    public function __construct(EmsCase $case)
    {
        $this->case = $case;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return \Illuminate\Broadcasting\Channel|array
     */
    public function broadcastOn()
    {
        return new PrivateChannel('cases.new');
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'case.created';
    }
}
