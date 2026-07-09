<?php
$data = json_decode(file_get_contents('e2e_run_result.json'), true);

$r = [];

// Helper to check HTTP code
function ok($call, $expected = [200, 201]) {
    return isset($call['http_code']) && in_array($call['http_code'], $expected);
}

// Phase 1
$r['Create Plan'] = ok($data['phase1']['create_plan']) ? 'PASS' : 'FAIL';
$r['Generate Shifts'] = ok($data['phase1']['create_plan']) ? 'PASS' : 'FAIL'; // Part of create plan

$polls = $data['phase1']['submit_polls'] ?? [];
$r['Leader Poll'] = ok($polls['leader'] ?? null) ? 'PASS' : 'FAIL';
$r['Scout Poll'] = ok($polls['scout'] ?? null) ? 'PASS' : 'FAIL';
$r['Paramedic Poll'] = ok($polls['paramedic'] ?? null) ? 'PASS' : 'FAIL';

$r['Build Schedule'] = ok($data['phase1']['build']) ? 'PASS' : 'FAIL';
$r['Publish Schedule'] = ok($data['phase1']['publish']) ? 'PASS' : 'FAIL';

// Phase 2 (Swaps)
$swap_pass = true;
foreach ($data['phase2'] as $k => $t) {
    if ($t['expect'] === 'PASS') {
        if (!ok($t['create'])) $swap_pass = false;
        if (!ok($t['accept'])) $swap_pass = false;
        if (!ok($t['approve'])) $swap_pass = false;
        if (!$t['swap_ok']) $swap_pass = false;
    } else {
        if (ok($t['create']) || ok($t['accept']) || ok($t['approve'])) $swap_pass = false;
    }
}
$r['Swap Workflow'] = $swap_pass ? 'PASS' : 'FAIL';

$db_ok = true;
foreach ($data['phase2'] as $k => $t) {
    if (isset($t['dup_ok']) && $t['dup_ok'] === false) $db_ok = false;
}
$r['Database Integrity'] = $db_ok ? 'PASS' : 'FAIL';

echo "| Test | Result |\n";
echo "| --- | --- |\n";
foreach ($r as $name => $status) {
    echo "| $name | $status |\n";
}

echo "\nDetailed Details Phase 1:\n";
echo "Create Plan: " . $data['phase1']['create_plan']['http_code'] . "\n";
echo "Build: " . $data['phase1']['build']['http_code'] . "\n";
echo "Publish: " . $data['phase1']['publish']['http_code'] . "\n";
echo "Polls: \n";
foreach ($polls as $role => $resp) echo "  $role: " . ($resp['http_code'] ?? 'null') . "\n";

echo "\nDetailed Details Phase 2 (Swaps):\n";
foreach ($data['phase2'] as $k => $t) {
    echo "Test $k: Expected: {$t['expect']} | Swap OK: ".($t['swap_ok']?'true':($t['swap_ok']===false?'false':'null'))."\n";
    echo "  Create: " . ($t['create']['http_code'] ?? 'null') . "\n";
    echo "  Accept: " . ($t['accept']['http_code'] ?? 'null') . "\n";
    echo "  Approve: " . ($t['approve']['http_code'] ?? 'null') . "\n";
}
