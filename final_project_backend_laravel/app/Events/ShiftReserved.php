<?php

namespace App\Events;

use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ShiftReserved implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $shiftPlanId;
    public $centerId;
    public $day;
    public $shiftType;
    public $rank;
    public $userId;
    public $status;

    /**
     * Create a new event instance.
     */
    public function __construct($shiftPlanId, $centerId, $day, $shiftType, $rank, $userId, $status = 'reserved')
    {
        $this->shiftPlanId = $shiftPlanId;
        $this->centerId = $centerId;
        $this->day = $day;
        $this->shiftType = $shiftType;
        $this->rank = $rank;
        $this->userId = $userId;
        $this->status = $status;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('shift-plan.' . $this->shiftPlanId),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'ShiftReserved';
    }

    /**
     * Get the data to broadcast.
     *
     * @return array<string, mixed>
     */
    public function broadcastWith(): array
    {
        return [
            'center_id' => $this->centerId,
            'day' => $this->day,
            'shift_type' => $this->shiftType,
            'rank' => $this->rank,
            'user_id' => $this->userId,
            'status' => $this->status,
        ];
    }
}
