<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('shift_polls', function (Blueprint $table) {
            // status indicates whether poll is accepting submissions
            $table->enum('status', ['pending','submitted'])->default('pending')->after('role');
        });
    }

    public function down(): void
    {
        Schema::table('shift_polls', function (Blueprint $table) {
            $table->dropColumn(['status']);
        });
    }
};
