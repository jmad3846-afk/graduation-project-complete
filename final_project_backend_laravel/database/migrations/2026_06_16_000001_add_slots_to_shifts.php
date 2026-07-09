<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('shifts')) return;

        Schema::table('shifts', function (Blueprint $table) {
            if (!Schema::hasColumn('shifts', 'slots')) {
                $table->unsignedTinyInteger('slots')->default(1)->after('team_number');
            }
        });

        // backfill from existing team_number where possible
        try {
            if (Schema::hasColumn('shifts', 'team_number') && Schema::hasColumn('shifts', 'slots')) {
                DB::table('shifts')->whereNull('slots')->update(['slots' => DB::raw('team_number')]);
            }
        } catch (\Throwable $e) {
            // ignore any runtime issues during backfill
        }
    }

    public function down(): void
    {
        if (!Schema::hasTable('shifts')) return;

        Schema::table('shifts', function (Blueprint $table) {
            if (Schema::hasColumn('shifts', 'slots')) {
                $table->dropColumn('slots');
            }
        });
    }
};
