<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cases', function (Blueprint $table) {
            $table->decimal('latitude', 10, 8)->nullable()->after('medical_aid_given');
            $table->decimal('longitude', 11, 8)->nullable()->after('latitude');
            $table->string('destination_hospital')->nullable()->after('longitude');
            $table->string('device_id')->nullable()->index()->after('destination_hospital');
            $table->uuid('tracking_token')->nullable()->unique()->after('device_id');
        });
    }

    public function down(): void
    {
        Schema::table('cases', function (Blueprint $table) {
            $table->dropColumn(['latitude', 'longitude', 'destination_hospital', 'device_id', 'tracking_token']);
        });
    }
};
