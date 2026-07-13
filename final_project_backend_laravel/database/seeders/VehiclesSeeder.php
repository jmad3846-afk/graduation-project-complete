<?php

namespace Database\Seeders;

use App\Models\Center;
use App\Models\Vehicle;
use Illuminate\Database\Seeder;

class VehiclesSeeder extends Seeder
{
    /**
     * Seed 8 vehicles, 2 per center, with real Damascus-area coordinates
     * near each center's neighborhood so the fleet map has something to show.
     */
    public function run(): void
    {
        $vehicles = [
            'مركز اليرموك' => [
                ['code' => 'YRM-01', 'status' => 'available', 'lat' => 33.4738, 'lng' => 36.2865],
                ['code' => 'YRM-02', 'status' => 'on_mission', 'lat' => 33.4762, 'lng' => 36.2901],
            ],
            'مركز الزاهرة' => [
                ['code' => 'ZHR-01', 'status' => 'available', 'lat' => 33.4886, 'lng' => 36.3230],
                ['code' => 'ZHR-02', 'status' => 'out_of_service', 'lat' => 33.4901, 'lng' => 36.3187],
            ],
            'مركز أبو رمانة' => [
                ['code' => 'ABR-01', 'status' => 'on_mission', 'lat' => 33.5175, 'lng' => 36.2802],
                ['code' => 'ABR-02', 'status' => 'available', 'lat' => 33.5142, 'lng' => 36.2846],
            ],
            'مركز جرمانا' => [
                ['code' => 'JRM-01', 'status' => 'available', 'lat' => 33.4839, 'lng' => 36.4009],
                ['code' => 'JRM-02', 'status' => 'on_mission', 'lat' => 33.4802, 'lng' => 36.3975],
            ],
        ];

        foreach ($vehicles as $centerName => $centerVehicles) {
            $center = Center::where('name', $centerName)->first();

            if (!$center) {
                continue;
            }

            foreach ($centerVehicles as $v) {
                Vehicle::updateOrCreate(
                    ['code' => $v['code']],
                    [
                        'status' => $v['status'],
                        'current_lat' => $v['lat'],
                        'current_lng' => $v['lng'],
                        'center_id' => $center->id,
                    ]
                );
            }
        }
    }
}
