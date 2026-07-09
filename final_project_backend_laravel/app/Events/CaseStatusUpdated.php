<?php

namespace App\Events;

use App\Models\EmsCase;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class CaseStatusUpdated implements ShouldBroadcast
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
        $channels = [new PrivateChannel('cases.status')];

        if ($this->case->vehicle_id) {
            $channels[] = new PrivateChannel('vehicle.' . $this->case->vehicle_id);
        }

        if ($this->case->center_id) {
            $channels[] = new PrivateChannel('center.' . $this->case->center_id);
        }

        return $channels;
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'case.status.updated';
    }
}
