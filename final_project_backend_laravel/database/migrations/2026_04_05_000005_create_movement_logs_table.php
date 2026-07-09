<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('movement_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('case_id')->constrained('cases')->cascadeOnDelete();
            $table->timestamp('depart_patient')->nullable();
            $table->timestamp('arrive_patient')->nullable();
            $table->timestamp('depart_hospital')->nullable();
            $table->timestamp('arrive_hospital')->nullable();
            $table->timestamp('depart_center')->nullable();
            $table->timestamp('arrive_center')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('movement_logs');
    }
};
