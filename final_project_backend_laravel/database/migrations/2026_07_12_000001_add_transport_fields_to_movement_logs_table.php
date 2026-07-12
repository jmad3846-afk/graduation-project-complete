<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('movement_logs', function (Blueprint $table) {
            $table->string('team_leader_name')->nullable();
            $table->boolean('transported')->nullable();
            $table->string('reason_not_transported')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('movement_logs', function (Blueprint $table) {
            $table->dropColumn(['team_leader_name', 'transported', 'reason_not_transported']);
        });
    }
};
