<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('shift_plans', function (Blueprint $table) {
    $table->id();

    $table->unsignedTinyInteger('month');
    $table->unsignedSmallInteger('year');

    $table->enum('status', [
        'draft',
        'polling_leaders',
        'polling_scouts',
        'polling_paramedics',
        'building',
        'published',
        'closed'
    ])->default('draft');

    $table->foreignId('created_by')
        ->nullable()
        ->constrained('users')
        ->nullOnDelete();

    $table->timestamp('published_at')->nullable();

    $table->timestamps();

    $table->unique(['month','year']);
});
    }

    public function down(): void
    {
        Schema::dropIfExists('shift_plans');
    }
};
