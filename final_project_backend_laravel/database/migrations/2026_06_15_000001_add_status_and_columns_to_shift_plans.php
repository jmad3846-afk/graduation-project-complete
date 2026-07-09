<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('shift_plans', function (Blueprint $table) {
            if (!Schema::hasColumn('shift_plans', 'status')) {
                $table->enum('status', [
                    'draft',
                    'polling_leaders',
                    'polling_scouts',
                    'polling_paramedics',
                    'building',
                    'published',
                    'closed',
                ])->default('draft')->after('year');
            }

            if (!Schema::hasColumn('shift_plans', 'created_by')) {
                $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete()->after('status');
            }

            if (!Schema::hasColumn('shift_plans', 'published_at')) {
                $table->timestamp('published_at')->nullable()->after('created_by');
            }
        });
    }

    public function down(): void
    {
        Schema::table('shift_plans', function (Blueprint $table) {
            if (Schema::hasColumn('shift_plans', 'published_at')) {
                $table->dropColumn('published_at');
            }

            if (Schema::hasColumn('shift_plans', 'created_by')) {
                $table->dropForeign(['created_by']);
                $table->dropColumn('created_by');
            }

            if (Schema::hasColumn('shift_plans', 'status')) {
                $table->dropColumn('status');
            }
        });
    }
};
