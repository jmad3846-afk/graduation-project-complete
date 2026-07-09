<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Http;

function testLogin($phone, $password, $endpoint) {
    $url = "http://localhost:8000/api/$endpoint";
    $response = Http::withHeaders(['Accept' => 'application/json'])->post($url, [
        'phone' => $phone,
        'password' => $password,
    ]);
    return $response->status() === 200 ? "✔" : "✘";
}

$dashboardRoles = [
    'Admin User' => '0501234567',
    'Manager User' => '0501234568',
    'Sector Leader User' => '0501234569',
    'Center Manager User' => '0501234570',
    'Operations User' => '0501234571',
    'Radio User' => '0501234572',
    'Citizen User' => '0501234573',
];

$paramedicRoles = [
    'Leader 1' => '0501234574',
    'Scout 1' => '0501234576',
    'Paramedic 1' => '0501234578',
];

echo "## Dashboard\n";
foreach ($dashboardRoles as $name => $phone) {
    echo str_pad($name . " login", 30) . testLogin($phone, 'password', 'login') . "\n";
}
echo str_pad("Paramedic login", 30) . testLogin('0501234578', 'password', 'login') . "\n";

echo "\n## Paramedic App\n";
foreach ($paramedicRoles as $name => $phone) {
    echo str_pad($name . " login", 30) . testLogin($phone, 'password', 'paramedic/login') . "\n";
}
foreach ($dashboardRoles as $name => $phone) {
    echo str_pad($name . " login", 30) . testLogin($phone, 'password', 'paramedic/login') . "\n";
}
