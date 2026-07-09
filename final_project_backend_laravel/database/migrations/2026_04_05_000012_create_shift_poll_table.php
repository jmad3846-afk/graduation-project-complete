<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('shift_polls', function (Blueprint $table) {

    $table->id();

    $table->foreignId('shift_plan_id')
        ->constrained()
        ->cascadeOnDelete();

    $table->foreignId('user_id')
        ->constrained()
        ->cascadeOnDelete();

    $table->enum('role', [
        'leader',
        'scout',
        'paramedic'
    ]);

    $table->json('preferred_days');

    $table->json('unavailable_days')
        ->nullable();

    $table->timestamp('submitted_at')
        ->nullable();

    $table->timestamps();

    $table->unique([
        'shift_plan_id',
        'user_id'
    ]);
});
    }

    public function down(): void
    {
        Schema::dropIfExists('shift_polls');
    }
};
