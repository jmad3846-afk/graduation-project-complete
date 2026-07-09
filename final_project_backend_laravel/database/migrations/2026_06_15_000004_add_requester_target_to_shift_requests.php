<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('shift_requests', function (Blueprint $table) {
            if (!Schema::hasColumn('shift_requests', 'requester_assignment_id')) {
                $table->foreignId('requester_assignment_id')->nullable()->constrained('shift_assignments')->nullOnDelete()->after('id');
            }

            if (!Schema::hasColumn('shift_requests', 'target_assignment_id')) {
                $table->foreignId('target_assignment_id')->nullable()->constrained('shift_assignments')->nullOnDelete()->after('requester_assignment_id');
            }
        });
    }

    public function down(): void
    {
        Schema::table('shift_requests', function (Blueprint $table) {
            if (Schema::hasColumn('shift_requests', 'target_assignment_id')) {
                $table->dropForeign(['target_assignment_id']);
                $table->dropColumn('target_assignment_id');
            }

            if (Schema::hasColumn('shift_requests', 'requester_assignment_id')) {
                $table->dropForeign(['requester_assignment_id']);
                $table->dropColumn('requester_assignment_id');
            }
        });
    }
};
