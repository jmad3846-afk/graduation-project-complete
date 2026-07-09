<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;
$checks = [
    'shift_plans' => ['status','created_by','published_at'],
    'shifts' => ['team_number'],
    'shift_assignments' => ['team_number','vehicle_id'],
    'shift_polls' => ['preferred_days','unavailable_days','status'],
    'shift_requests' => ['requester_assignment_id','target_assignment_id','approved_by','approved_at'],
];
foreach ($checks as $table => $cols) {
    echo "Table: $table\n";
    foreach ($cols as $c) {
        echo str_pad($c, 30) . ': ' . (Schema::hasColumn($table, $c) ? 'exists' : 'MISSING') . PHP_EOL;
    }
    echo PHP_EOL;
}
$tables = array_keys($checks);
foreach ($tables as $t) {
    echo "Full schema for: $t\n";
    $cols = DB::select("SHOW COLUMNS FROM $t");
    foreach ($cols as $col) {
        echo $col->Field . '\t' . $col->Type . '\t' . $col->Null . '\t' . $col->Key . '\t' . $col->Default . '\t' . $col->Extra . PHP_EOL;
    }
    echo PHP_EOL;
}
