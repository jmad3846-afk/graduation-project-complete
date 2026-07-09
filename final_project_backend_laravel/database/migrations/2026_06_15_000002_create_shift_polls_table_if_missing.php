<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('shift_polls')) {
            Schema::create('shift_polls', function (Blueprint $table) {
                $table->id();

                $table->foreignId('shift_plan_id')->constrained()->cascadeOnDelete();
                $table->foreignId('user_id')->constrained()->cascadeOnDelete();

                $table->enum('role', ['leader','scout','paramedic'])->nullable();

                $table->json('preferred_days')->nullable();
                $table->json('unavailable_days')->nullable();

                $table->timestamp('submitted_at')->nullable();

                $table->timestamps();

                $table->unique(['shift_plan_id','user_id']);
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('shift_polls')) {
            Schema::dropIfExists('shift_polls');
        }
    }
};
