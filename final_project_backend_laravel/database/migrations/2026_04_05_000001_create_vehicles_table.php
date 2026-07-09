<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vehicles', function (Blueprint $table) {
            $table->id();
            $table->string('code', 50)->unique()->index();
            $table->enum('status', ['available','on_mission','out_of_service'])->default('available')->index();
            $table->double('current_lat')->nullable();
            $table->double('current_lng')->nullable();
            $table->foreignId('center_id')->nullable()->constrained('centers')->nullOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vehicles');
    }
};
