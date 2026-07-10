<?php

namespace Database\Seeders;

use App\Models\Center;
use Illuminate\Database\Seeder;

class CentersSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $centers = [
            ['name' => 'مركز اليرموك', 'location' => 'Al Yarmouk'],
            ['name' => 'مركز الزاهرة', 'location' => 'Al Zahera'],
            ['name' => 'مركز أبو رمانة', 'location' => 'Abu Rummaneh'],
            ['name' => 'مركز جرمانا', 'location' => 'Jaramana'],
        ];

        foreach ($centers as $center) {
            Center::firstOrCreate(
                ['name' => $center['name']],
                ['location' => $center['location'], 'status' => 'active']
            );
        }
    }
}
