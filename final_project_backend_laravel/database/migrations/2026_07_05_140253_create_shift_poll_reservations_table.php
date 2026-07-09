<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('shift_poll_reservations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('poll_id')->constrained('shift_polls')->onDelete('cascade');
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('rank'); // leader, scout, paramedic
            $table->integer('day'); // 1-7
            $table->string('shift_type'); // morning, night
            $table->string('status')->default('reserved'); // reserved, released, confirmed
            $table->timestamps();

            $table->unique(['poll_id', 'day', 'shift_type', 'rank'], 'unique_shift_slot_reservation');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('shift_poll_reservations');
    }
};
