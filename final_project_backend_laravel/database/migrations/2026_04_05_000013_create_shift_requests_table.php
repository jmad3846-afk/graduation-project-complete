<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
       Schema::create('shift_requests', function (Blueprint $table) {

    $table->id();

    $table->foreignId('requester_assignment_id')
        ->constrained('shift_assignments')
        ->cascadeOnDelete();

    $table->foreignId('target_assignment_id')
        ->constrained('shift_assignments')
        ->cascadeOnDelete();

    $table->text('reason')
        ->nullable();

    $table->enum('status', [
        'pending',
        'accepted_by_target',
        'approved',
        'rejected',
        'cancelled'
    ])->default('pending');

    $table->foreignId('approved_by')
        ->nullable()
        ->constrained('users')
        ->nullOnDelete();

    $table->timestamp('approved_at')
        ->nullable();

    $table->timestamps();
});
    }

    public function down(): void
    {
        Schema::dropIfExists('shift_requests');
    }
};
