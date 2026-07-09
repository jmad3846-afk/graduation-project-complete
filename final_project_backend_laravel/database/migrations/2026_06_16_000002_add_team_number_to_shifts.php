<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('shifts')) return;

        Schema::table('shifts', function (Blueprint $table) {
            if (!Schema::hasColumn('shifts', 'team_number')) {
                $table->unsignedTinyInteger('team_number')->default(1)->after('type');
            }
        });
    }

    public function down(): void
    {
        if (!Schema::hasTable('shifts')) return;

        Schema::table('shifts', function (Blueprint $table) {
            if (Schema::hasColumn('shifts', 'team_number')) {
                $table->dropColumn('team_number');
            }
        });
    }
};
