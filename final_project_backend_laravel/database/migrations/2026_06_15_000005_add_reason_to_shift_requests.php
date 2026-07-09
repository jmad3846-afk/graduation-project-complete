<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('shift_requests', function (Blueprint $table) {
            if (!Schema::hasColumn('shift_requests', 'reason')) {
                $table->text('reason')->nullable()->after('target_assignment_id');
            }
        });
    }

    public function down(): void
    {
        Schema::table('shift_requests', function (Blueprint $table) {
            if (Schema::hasColumn('shift_requests', 'reason')) {
                $table->dropColumn('reason');
            }
        });
    }
};
