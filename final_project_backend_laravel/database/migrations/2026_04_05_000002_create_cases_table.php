<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cases', function (Blueprint $table) {
            $table->id();
            $table->foreignId('center_id')->nullable()->constrained('centers')->nullOnDelete();
            $table->foreignId('vehicle_id')->nullable()->constrained('vehicles')->nullOnDelete();
            $table->enum('triage_code', ['red','yellow','green'])->index();
            $table->string('transfer_type', 100)->nullable();
            $table->enum('status', ['waiting','assigned','in_progress','at_hospital','closed'])->default('waiting')->index();
            $table->text('symptoms')->nullable();
            $table->integer('breathing_rate')->nullable();
            $table->text('medical_aid_given')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cases');
    }
};
