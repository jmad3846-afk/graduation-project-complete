<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (!Schema::hasColumn('shift_poll_reservations', 'center_id')) {
            Schema::table('shift_poll_reservations', function (Blueprint $table) {
                $table->unsignedBigInteger('center_id')->nullable()->after('shift_plan_id');
            });
        }

        if (!$this->indexExists('unique_plan_center_slot_reservation')) {
            // The old unique index also backs the shift_plan_id foreign key on
            // MySQL, so it can't be dropped until a replacement index covering
            // shift_plan_id exists. Add a plain (non-unique) index first, then
            // drop the old unique index, then add the real composite unique.
            Schema::table('shift_poll_reservations', function (Blueprint $table) {
                $table->index('shift_plan_id', 'shift_plan_id_index');
            });

            Schema::table('shift_poll_reservations', function (Blueprint $table) {
                $table->dropUnique('unique_plan_slot_reservation');
            });

            Schema::table('shift_poll_reservations', function (Blueprint $table) {
                $table->foreign('center_id')->references('id')->on('centers')->onDelete('cascade');
            });

            Schema::table('shift_poll_reservations', function (Blueprint $table) {
                $table->unique(['shift_plan_id', 'center_id', 'day', 'shift_type', 'rank'], 'unique_plan_center_slot_reservation');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('shift_poll_reservations', function (Blueprint $table) {
            $table->dropUnique('unique_plan_center_slot_reservation');
        });

        Schema::table('shift_poll_reservations', function (Blueprint $table) {
            $table->unique(['shift_plan_id', 'day', 'shift_type', 'rank'], 'unique_plan_slot_reservation');
        });

        Schema::table('shift_poll_reservations', function (Blueprint $table) {
            $table->dropForeign(['center_id']);
            $table->dropIndex('shift_plan_id_index');
            $table->dropColumn('center_id');
        });
    }

    protected function indexExists(string $indexName): bool
    {
        $driver = Schema::getConnection()->getDriverName();

        if ($driver === 'sqlite') {
            $indexes = DB::select("PRAGMA index_list('shift_poll_reservations')");
            foreach ($indexes as $index) {
                if ($index->name === $indexName) {
                    return true;
                }
            }
            return false;
        }

        $indexes = collect(DB::select('SHOW INDEX FROM shift_poll_reservations'))->pluck('Key_name')->unique();
        return $indexes->contains($indexName);
    }
};
