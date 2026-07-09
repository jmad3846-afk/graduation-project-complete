<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$user = App\Models\User::where('role', 'admin')->first();
Laravel\Sanctum\Sanctum::actingAs($user, ['*']);
$request = Illuminate\Http\Request::create('/api/admin/shift-plans', 'GET');
$request->headers->set('Accept', 'application/json');
$request->setUserResolver(function() use ($user) { return $user; });
$response = app()->handle($request);
echo "\n--- API GET RESPONSE ---\n";
echo $response->getContent();
echo "\n--------------------\n";
