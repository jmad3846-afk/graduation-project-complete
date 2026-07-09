<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('patients', function (Blueprint $table) {
            $table->id();
            $table->foreignId('case_id')->constrained('cases')->cascadeOnDelete();
            $table->string('full_name')->nullable();
            $table->integer('age')->nullable();
            $table->float('weight')->nullable();
            $table->text('medical_history')->nullable();
            $table->float('oxygen_level')->nullable();
            $table->string('blood_pressure', 50)->nullable();
            $table->float('blood_sugar')->nullable();
            $table->float('oxygen_before')->nullable();
            $table->float('oxygen_after')->nullable();
            $table->boolean('has_tube')->default(false);
            $table->boolean('conscious')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('patients');
    }
};
