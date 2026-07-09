<?php
// E2E Phase 1 script: create plan, start polls, submit sample polls, build, publish, and snapshot DB
function http_post($url, $token, $data=null) {
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    $headers = ['Authorization: Bearer '.$token, 'Content-Type: application/json'];
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    if ($data !== null) curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    $res = curl_exec($ch);
    $info = curl_getinfo($ch);
    curl_close($ch);
    return ['http_code' => $info['http_code'], 'body' => $res];
}

$base = 'http://127.0.0.1:8000';
$adminToken = '3fa7b3f7e916ae1852c94757cd6d5010e6b21232586e0d8b857f9a1f699d497b';
// Create plan July 2026
$create = http_post($base.'/api/admin/shift-plans', $adminToken, ['month'=>7,'year'=>2026]);
file_put_contents('tools/e2e_create_plan.json', json_encode($create));
echo "CREATE_PLAN_STATUS: {$create['http_code']}\n";
echo "CREATE_PLAN_BODY: {$create['body']}\n";
$plan = json_decode($create['body'], true);
$planId = $plan['data']['id'] ?? null;
if (!$planId) {
    echo "Failed to create plan, aborting Phase 1.\n";
    exit(1);
}
// Start polls
foreach (['start-leader-poll'=>'Leader','start-scout-poll'=>'Scout','start-paramedic-poll'=>'Paramedic'] as $ep=>$label) {
    $res = http_post($base."/api/admin/shift-plans/{$planId}/{$ep}", $adminToken, null);
    file_put_contents("tools/e2e_{$ep}.json", json_encode($res));
    echo strtoupper($label)."_POLL_START_STATUS: {$res['http_code']}\n";
    echo "BODY: {$res['body']}\n";
}
// List polls via DB
$app = require __DIR__.'/../bootstrap/app.php';
$k = $app->make(Illuminate\Contracts\Console\Kernel::class);
$k->bootstrap();
// List polls via DB
$app = require __DIR__.'/../bootstrap/app.php';
$k = $app->make(Illuminate\Contracts\Console\Kernel::class);
$k->bootstrap();
$polls = Illuminate\Support\Facades\DB::select('SELECT id,user_id,role,status FROM shift_polls WHERE shift_plan_id=?', [$planId]);
file_put_contents('tools/e2e_polls.json', json_encode($polls));
echo "POLLS_COUNT: ".count($polls)."\n";
// Submit sample poll responses for first poll per role
$roleTokenMap = [
    'paramedic' => 'b5d8099c64cb657fbc38f389e8aaabdcb88eae8d1ca298b312c46ade2d4f9e8e',
    'scout' => '38fce0c103e3c9cce67894e08f5835172c5850664aef66d7c0ff6f9c30a39400',
    'leader' => '923240d2c7be82ad81ca0f0a19a8f64fb9833ecb731a85b046a73292a27df991',
];
foreach ($polls as $p) {
    if ($p->status !== 'pending') continue;
    $role = $p->role;
    if (!isset($roleTokenMap[$role])) continue;
    $token = $roleTokenMap[$role];
    $res = http_post($base.'/api/shift-polls/'.$p->id.'/submit', $token, ['preferred_days'=>[], 'unavailable_days'=>[]]);
    echo "SUBMIT_POLL role={$role} poll_id={$p->id} status={$res['http_code']}\n";
    file_put_contents('tools/e2e_submit_poll_'.$p->id.'.json', json_encode($res));
}
// Build schedule
$build = http_post($base.'/api/admin/shift-plans/'.$planId.'/build', $adminToken, null);
file_put_contents('tools/e2e_build.json', json_encode($build));
echo "BUILD_STATUS: {$build['http_code']} BODY: {$build['body']}\n";
// Query assignments
$assignments = Illuminate\Support\Facades\DB::select('SELECT sa.id, sa.user_id, u.name, sa.role, s.date, s.type, sa.team_number FROM shift_assignments sa JOIN shifts s ON s.id=sa.shift_id JOIN users u ON u.id=sa.user_id WHERE s.shift_plan_id=?', [$planId]);
file_put_contents('tools/e2e_assignments.json', json_encode($assignments));
echo "ASSIGNMENTS_COUNT: ".count($assignments)."\n";
// Publish
$publish = http_post($base.'/api/admin/shift-plans/'.$planId.'/publish', $adminToken, null);
file_put_contents('tools/e2e_publish.json', json_encode($publish));
echo "PUBLISH_STATUS: {$publish['http_code']} BODY: {$publish['body']}\n";
// Final plan row
$planRow = Illuminate\Support\Facades\DB::select('SELECT id,month,year,status,published_at FROM shift_plans WHERE id=?', [$planId]);
file_put_contents('tools/e2e_plan_final.json', json_encode($planRow));
echo "PLAN_FINAL:".json_encode($planRow)."\n";
