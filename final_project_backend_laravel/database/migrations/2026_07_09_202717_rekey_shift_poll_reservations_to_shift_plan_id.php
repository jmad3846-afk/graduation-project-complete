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
        if (!Schema::hasColumn('shift_poll_reservations', 'shift_plan_id')) {
            Schema::table('shift_poll_reservations', function (Blueprint $table) {
                $table->unsignedBigInteger('shift_plan_id')->nullable()->after('id');
            });
        }

        if (Schema::hasColumn('shift_poll_reservations', 'poll_id')) {
            // Backfill shift_plan_id from each reservation's poll, since reservations
            // were previously scoped per-user (poll_id) instead of per monthly plan.
            $map = DB::table('shift_poll_reservations')
                ->join('shift_polls', 'shift_polls.id', '=', 'shift_poll_reservations.poll_id')
                ->pluck('shift_polls.shift_plan_id', 'shift_poll_reservations.id');

            foreach ($map as $reservationId => $shiftPlanId) {
                DB::table('shift_poll_reservations')
                    ->where('id', $reservationId)
                    ->update(['shift_plan_id' => $shiftPlanId]);
            }

            Schema::table('shift_poll_reservations', function (Blueprint $table) {
                $table->dropForeign(['poll_id']);
            });

            Schema::table('shift_poll_reservations', function (Blueprint $table) {
                $table->dropUnique('unique_shift_slot_reservation');
            });

            Schema::table('shift_poll_reservations', function (Blueprint $table) {
                $table->dropColumn('poll_id');
            });
        }

        Schema::table('shift_poll_reservations', function (Blueprint $table) {
            $table->unsignedBigInteger('shift_plan_id')->nullable(false)->change();
        });

        if (!$this->indexExists('shift_poll_reservations_shift_plan_id_foreign')) {
            Schema::table('shift_poll_reservations', function (Blueprint $table) {
                $table->foreign('shift_plan_id')->references('id')->on('shift_plans')->onDelete('cascade');
            });
        }

        if (!$this->indexExists('unique_plan_slot_reservation')) {
            Schema::table('shift_poll_reservations', function (Blueprint $table) {
                $table->unique(['shift_plan_id', 'day', 'shift_type', 'rank'], 'unique_plan_slot_reservation');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('shift_poll_reservations', function (Blueprint $table) {
            $table->dropUnique('unique_plan_slot_reservation');
            $table->foreignId('poll_id')->nullable()->after('id')->constrained('shift_polls')->onDelete('cascade');
            $table->dropForeign(['shift_plan_id']);
            $table->dropColumn('shift_plan_id');
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
