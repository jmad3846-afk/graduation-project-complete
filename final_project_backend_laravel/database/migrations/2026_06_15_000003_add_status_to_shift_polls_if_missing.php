<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('shift_polls', function (Blueprint $table) {
            if (!Schema::hasColumn('shift_polls', 'status')) {
                $table->enum('status', ['pending','submitted'])->default('pending')->after('role');
            }
        });
    }

    public function down(): void
    {
        Schema::table('shift_polls', function (Blueprint $table) {
            if (Schema::hasColumn('shift_polls', 'status')) {
                $table->dropColumn('status');
            }
        });
    }
};
