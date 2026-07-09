<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Superseded: the shift_poll_reservations table was already created by the
        // 2026_07_05_140253 migration, and the missing expires_at column was added
        // additively by 2026_07_09_195814_add_expires_at_to_shift_poll_reservations_table.
        // This migration is intentionally a no-op to preserve migration history
        // without attempting to recreate an existing table.
        if (!Schema::hasTable('shift_poll_reservations')) {
            Schema::create('shift_poll_reservations', function (Blueprint $table) {
                $table->id();
                $table->foreignId('poll_id')->constrained('shift_polls')->onDelete('cascade');
                $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
                $table->unsignedTinyInteger('day');
                $table->enum('shift_type', ['morning', 'evening', 'night']);
                $table->enum('rank', ['leader', 'scout', 'paramedic']);
                $table->enum('status', ['reserved', 'confirmed'])->default('reserved');
                $table->timestamp('expires_at')->nullable();
                $table->timestamps();
                $table->unique(['poll_id', 'day', 'shift_type', 'rank'], 'unique_reservation_per_slot');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // No-op: see up(). Do not drop the table here since the base migration owns it.
    }
};
?>
