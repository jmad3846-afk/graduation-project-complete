<?php

namespace App\Services;

use App\Models\ShiftPollReservation;
use App\Models\ShiftPlan;
use App\Events\ShiftReserved;
use App\Events\ShiftReleased;
use App\Events\ShiftConfirmed;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;

class ShiftReservationService
{
    /**
     * Reserve a slot.
     *
     * @throws ConflictHttpException if another reservation already exists for the same slot.
     */
    public function reserve(int $shiftPlanId, int $centerId, int $day, string $shift, string $rank, int $userId): ShiftPollReservation
    {
        return DB::transaction(function () use ($shiftPlanId, $centerId, $day, $shift, $rank, $userId) {
            // Verify plan exists
            ShiftPlan::findOrFail($shiftPlanId);

            // Check if slot already reserved (any user on this plan, same center, same rank)
            $exists = ShiftPollReservation::where('shift_plan_id', $shiftPlanId)
                ->where('center_id', $centerId)
                ->where('day', $day)
                ->where('shift_type', $shift)
                ->where('rank', $rank)
                ->first();

            if ($exists) {
                throw new ConflictHttpException('Slot already reserved');
            }

            $reservation = ShiftPollReservation::create([
                'shift_plan_id' => $shiftPlanId,
                'center_id'  => $centerId,
                'user_id'    => $userId,
                'day'        => $day,
                'shift_type' => $shift,
                'rank'       => $rank,
                'status'     => 'reserved',
                'expires_at' => now()->addSeconds(120),
            ]);

            event(new ShiftReserved($shiftPlanId, $centerId, $day, $shift, $rank, $userId));
            return $reservation;
        });
    }

    /**
     * Release a reservation owned by the user.
     */
    public function release(int $reservationId, int $userId): void
    {
        DB::transaction(function () use ($reservationId, $userId) {
            $reservation = ShiftPollReservation::where('id', $reservationId)
                ->where('user_id', $userId)
                ->firstOrFail();

            $reservation->delete();
            event(new ShiftReleased($reservation->shift_plan_id, $reservation->center_id, $reservation->day, $reservation->shift_type, $reservation->rank, $reservation->user_id));
        });
    }

    /**
     * Confirm a reservation owned by the user.
     */
    public function confirm(int $reservationId, int $userId): void
    {
        DB::transaction(function () use ($reservationId, $userId) {
            $reservation = ShiftPollReservation::where('id', $reservationId)
                ->where('user_id', $userId)
                ->firstOrFail();

            $reservation->update([
                'status' => 'confirmed',
                'expires_at' => null,
            ]);

            event(new ShiftConfirmed($reservation->shift_plan_id, $reservation->center_id, $reservation->day, $reservation->shift_type, $reservation->rank, $reservation->user_id));
        });
    }

    /**
     * Cleanup expired reservations (status = reserved && expires_at past).
     */
    public function cleanupExpiredReservations(): void
    {
        $expired = ShiftPollReservation::where('status', 'reserved')
            ->where('expires_at', '<', now())
            ->get();

        foreach ($expired as $reservation) {
            $reservation->delete();
            event(new ShiftReleased($reservation->shift_plan_id, $reservation->center_id, $reservation->day, $reservation->shift_type, $reservation->rank, $reservation->user_id));
        }
    }

    /**
     * Get current reservations for a plan (both actively-held and already-confirmed slots,
     * so a fresh client load can render locked/confirmed state without waiting for a
     * websocket event).
     */
    public function currentReservations(int $shiftPlanId): array
    {
        return ShiftPollReservation::where('shift_plan_id', $shiftPlanId)
            ->whereIn('status', ['reserved', 'confirmed'])
            ->get()
            ->toArray();
    }
}

?>
