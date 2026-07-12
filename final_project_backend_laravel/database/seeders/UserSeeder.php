<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Admin
        User::create([
            'name' => 'Admin User',
            'phone' => '0501234567',
            'password' => Hash::make('password'),
            'role' => 'admin',
            'rank' => null,
            'center_id' => null,
        ]);

        // Manager
        User::create([
            'name' => 'Manager User',
            'phone' => '0501234568',
            'password' => Hash::make('password'),
            'role' => 'manager',
            'rank' => null,
            'center_id' => null,
        ]);

        // Sector Leader
        User::create([
            'name' => 'Sector Leader User',
            'phone' => '0501234569',
            'password' => Hash::make('password'),
            'role' => 'sector_leader',
            'rank' => null,
            'center_id' => null,
        ]);

        // Center Manager (Yarmouk Center)
        User::create([
            'name' => 'Center Manager User',
            'phone' => '0501234570',
            'password' => Hash::make('password'),
            'role' => 'center_manager',
            'rank' => null,
            'center_id' => 1, // مركز اليرموك (Yarmouk Center)
        ]);

        // Operations
        User::create([
            'name' => 'Operations User',
            'phone' => '0501234571',
            'password' => Hash::make('password'),
            'role' => 'operations',
            'rank' => null,
            'center_id' => null,
        ]);

        // Radio
        User::create([
            'name' => 'Radio User',
            'phone' => '0501234572',
            'password' => Hash::make('password'),
            'role' => 'radio',
            'rank' => null,
            'center_id' => null,
        ]);

        // Citizen
        User::create([
            'name' => 'Citizen User',
            'phone' => '0501234573',
            'password' => Hash::make('password'),
            'role' => 'citizen',
            'rank' => null,
            'center_id' => null,
        ]);

        // EMS Personnel (role = paramedic)
        User::create([
            'name' => 'Leader 1',
            'phone' => '0501234574',
            'password' => Hash::make('password'),
            'role' => 'paramedic',
            'rank' => 'leader',
            'center_id' => null,
        ]);

        User::create([
            'name' => 'Leader 2',
            'phone' => '0501234575',
            'password' => Hash::make('password'),
            'role' => 'paramedic',
            'rank' => 'leader',
            'center_id' => null,
        ]);

        User::create([
            'name' => 'Scout 1',
            'phone' => '0501234576',
            'password' => Hash::make('password'),
            'role' => 'paramedic',
            'rank' => 'scout',
            'center_id' => null,
        ]);

        User::create([
            'name' => 'Scout 2',
            'phone' => '0501234577',
            'password' => Hash::make('password'),
            'role' => 'paramedic',
            'rank' => 'scout',
            'center_id' => null,
        ]);

        User::create([
            'name' => 'Paramedic 1',
            'phone' => '0501234578',
            'password' => Hash::make('password'),
            'role' => 'paramedic',
            'rank' => 'paramedic',
            'center_id' => null,
        ]);

        User::create([
            'name' => 'Paramedic 2',
            'phone' => '0501234579',
            'password' => Hash::make('password'),
            'role' => 'paramedic',
            'rank' => 'paramedic',
            'center_id' => null,
        ]);
    }
}
