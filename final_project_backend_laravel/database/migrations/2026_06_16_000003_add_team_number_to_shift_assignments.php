<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('shift_assignments')) return;

        Schema::table('shift_assignments', function (Blueprint $table) {
            if (!Schema::hasColumn('shift_assignments', 'team_number')) {
                $table->unsignedTinyInteger('team_number')->default(1)->after('role');
            }
        });
    }

    public function down(): void
    {
        if (!Schema::hasTable('shift_assignments')) return;

        Schema::table('shift_assignments', function (Blueprint $table) {
            if (Schema::hasColumn('shift_assignments', 'team_number')) {
                $table->dropColumn('team_number');
            }
        });
    }
};
