<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('shifts', function (Blueprint $table) {

    $table->id();

    $table->foreignId('shift_plan_id')
        ->constrained()
        ->cascadeOnDelete();

    $table->foreignId('center_id')
        ->constrained()
        ->cascadeOnDelete();

    $table->date('date');

    $table->enum('type', [
        'morning',
        'evening',
        'night'
    ]);

    $table->unsignedTinyInteger('team_number')
        ->default(2);

    $table->timestamps();

    $table->unique([
        'center_id',
        'date',
        'type'
    ]);
});
    }

    public function down(): void
    {
        Schema::dropIfExists('shifts');
    }
};
