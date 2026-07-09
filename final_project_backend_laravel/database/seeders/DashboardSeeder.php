<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Center;
use App\Models\Vehicle;
use App\Models\Shift;
use App\Models\ShiftAssignment;
use App\Models\EmsCase;
use App\Models\Patient;
use App\Models\Caller;
use App\Models\User;
use Carbon\Carbon;

class DashboardSeeder extends Seeder
{
    public function run(): void
    {
        // Create centers
        $c1 = Center::firstOrCreate(['name' => 'Central'], ['location' => 'Downtown', 'status' => 'open']);
        $c2 = Center::firstOrCreate(['name' => 'North'], ['location' => 'Northside', 'status' => 'open']);

        // Create vehicles
        $v1 = Vehicle::firstOrCreate(['code' => 'A01'], ['status' => 'available', 'center_id' => $c1->id]);
        $v2 = Vehicle::firstOrCreate(['code' => 'A02'], ['status' => 'available', 'center_id' => $c1->id]);
        $v3 = Vehicle::firstOrCreate(['code' => 'B01'], ['status' => 'available', 'center_id' => $c2->id]);
        $v4 = Vehicle::firstOrCreate(['code' => 'B02'], ['status' => 'available', 'center_id' => $c2->id]);

        // Create a shift plan and shifts for today
        $today = Carbon::now()->toDateString();
                $plan = \App\Models\ShiftPlan::firstOrCreate(['month' => Carbon::now()->month, 'year' => Carbon::now()->year], ['status' => 'published', 'published_at' => now()]);
        $s1 = Shift::firstOrCreate(['shift_plan_id' => $plan->id, 'date' => $today, 'center_id' => $c1->id, 'type' => 'morning']);
        $s2 = Shift::firstOrCreate(['shift_plan_id' => $plan->id, 'date' => $today, 'center_id' => $c2->id, 'type' => 'morning']);

        // Find users to assign (use available paramedics or fallback to first users)
        $p1 = User::where('role', 'paramedic')->where('rank', 'paramedic')->first() ?? User::first();
        $p2 = User::where('role', 'paramedic')->where('rank', 'leader')->first() ?? User::skip(1)->first();
        $p3 = User::where('role', 'paramedic')->where('rank', 'paramedic')->skip(1)->first() ?? User::skip(2)->first();
        $p4 = User::where('role', 'paramedic')->where('rank', 'scout')->first() ?? User::skip(3)->first();

        // Create shift assignments
        ShiftAssignment::create(['shift_id' => $s1->id, 'user_id' => $p1->id ?? 1, 'role' => 'paramedic', 'team_number' => 1, 'assigned_at' => now(), 'vehicle_id' => $v1->id]);
        ShiftAssignment::create(['shift_id' => $s1->id, 'user_id' => $p2->id ?? 2, 'role' => 'leader', 'team_number' => 1, 'assigned_at' => now(), 'vehicle_id' => $v1->id]);
        ShiftAssignment::create(['shift_id' => $s2->id, 'user_id' => $p3->id ?? 3, 'role' => 'paramedic', 'team_number' => 1, 'assigned_at' => now(), 'vehicle_id' => $v3->id]);
        // Create additional leader and scout assignments for second shift
        ShiftAssignment::create(['shift_id' => $s2->id, 'user_id' => $p2->id ?? 2, 'role' => 'leader', 'team_number' => 1, 'assigned_at' => now(), 'vehicle_id' => $v3->id]);
        ShiftAssignment::create(['shift_id' => $s1->id, 'user_id' => $p4->id ?? 4, 'role' => 'scout', 'team_number' => 1, 'assigned_at' => now(), 'vehicle_id' => $v1->id]);

        // Create cases: two waiting (pending), one assigned to vehicle A01 (active)
        $case1 = EmsCase::create(['triage_code' => 'green', 'status' => 'waiting', 'latitude' => null, 'longitude' => null, 'tracking_token' => 
            \Illuminate\Support\Str::uuid()->toString()]);

        Caller::create(['case_id' => $case1->id, 'name' => 'Caller One', 'phone' => '011111111']);

        $case2 = EmsCase::create(['triage_code' => 'yellow', 'status' => 'waiting', 'latitude' => null, 'longitude' => null, 'tracking_token' => \Illuminate\Support\Str::uuid()->toString()]);
        Caller::create(['case_id' => $case2->id, 'name' => 'Caller Two', 'phone' => '022222222']);

        $case3 = EmsCase::create(['triage_code' => 'red', 'status' => 'assigned', 'vehicle_id' => $v1->id, 'center_id' => $c1->id, 'latitude' => null, 'longitude' => null, 'tracking_token' => \Illuminate\Support\Str::uuid()->toString()]);
        Caller::create(['case_id' => $case3->id, 'name' => 'Caller Three', 'phone' => '033333333']);
    }
}
