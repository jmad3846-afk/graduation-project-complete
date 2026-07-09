<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$k = $app->make(Illuminate\Contracts\Console\Kernel::class);
$k->bootstrap();

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request as HttpRequest;
use App\Models\User;

function http_post_local($path, $token = null, $data = null) {
    try {
        $server = [];
        if ($token) $server['HTTP_AUTHORIZATION'] = 'Bearer '.$token;
        $server['HTTP_ACCEPT'] = 'application/json';
        $server['CONTENT_TYPE'] = 'application/json';
        $body = $data !== null ? json_encode($data) : null;
        $request = HttpRequest::create($path, 'POST', [], [], [], $server, $body);
        \Illuminate\Support\Facades\Auth::forgetGuards();
        $kernel = app()->make(Illuminate\Contracts\Http\Kernel::class);
        $response = $kernel->handle($request);
        $content = $response->getContent();
        $status = $response->getStatusCode();
        $kernel->terminate($request, $response);
        return ['http_code' => $status, 'body' => $content, 'error' => null];
    } catch (\Throwable $e) {
        return ['http_code' => 500, 'body' => null, 'error' => $e->getMessage()];
    }
}

$base = '/api';

// Admin Token
$adminUser = User::where('role', 'admin')->first();
$adminToken = $adminUser->createToken('e2e')->plainTextToken;

// Latest plan
$plan = DB::select('SELECT id FROM shift_plans WHERE status = ? ORDER BY id DESC LIMIT 1', ['published']);
if (!$plan) {
    die("No published shift plan found.\n");
}
$planId = $plan[0]->id;

echo "Using Shift Plan ID: $planId\n\n";

$assignments = DB::select("
    SELECT sa.id, sa.user_id, sa.role, s.date 
    FROM shift_assignments sa 
    JOIN shifts s ON sa.shift_id = s.id 
    WHERE s.shift_plan_id = ?
", [$planId]);

$byRole = ['paramedic' => [], 'dispatcher' => [], 'sector_leader' => []]; // scout in db might be dispatcher, let's group by DB role

foreach ($assignments as $a) {
    $byRole[$a->role][] = $a;
}

function getTwoDifferentUsers($list) {
    $first = null;
    $second = null;
    foreach ($list as $a) {
        if (!$first) {
            $first = $a;
        } elseif ($a->user_id !== $first->user_id) {
            $second = $a;
            break;
        }
    }
    return [$first, $second];
}

$pairs = [
    'Paramedic Swap' => getTwoDifferentUsers($byRole['paramedic'] ?? []),
    'Scout Swap' => getTwoDifferentUsers($byRole['scout'] ?? $byRole['dispatcher'] ?? []),
    'Leader Swap' => getTwoDifferentUsers($byRole['leader'] ?? $byRole['sector_leader'] ?? []),
];

// Cross role validation pair
$crossRole1 = $pairs['Paramedic Swap'][0] ?? null;
$crossRole2 = $pairs['Scout Swap'][0] ?? null;

// Get dynamic user tokens
$tokens = [];
foreach ($assignments as $a) {
    if (!isset($tokens[$a->user_id])) {
        $u = User::find($a->user_id);
        if ($u) {
            $tokens[$a->user_id] = $u->createToken('e2e')->plainTextToken;
        }
    }
}

$results = [];

function dump_assignment($id) {
    $a = DB::select('SELECT id, user_id, shift_id, role FROM shift_assignments WHERE id = ?', [$id]);
    return $a ? (array)$a[0] : null;
}

foreach ($pairs as $testName => $pair) {
    if (!$pair[0] || !$pair[1]) {
        $results[$testName] = ['Result' => 'FAIL', 'reason' => 'Could not find 2 distinct user assignments for role.'];
        continue;
    }
    $reqA = $pair[0];
    $tgtA = $pair[1];
    
    echo "--- Testing $testName ---\n";
    echo "Requester Assignment ID: {$reqA->id} (User: {$reqA->user_id})\n";
    echo "Target Assignment ID: {$tgtA->id} (User: {$tgtA->user_id})\n";

    $before = [
        dump_assignment($reqA->id),
        dump_assignment($tgtA->id)
    ];
    echo "DB State Before:\n" . json_encode($before, JSON_PRETTY_PRINT) . "\n";

    $reqToken = $tokens[$reqA->user_id];
    $tgtToken = $tokens[$tgtA->user_id];

    // Create
    $createResp = http_post_local($base.'/shift-requests', $reqToken, [
        'requester_assignment_id' => $reqA->id,
        'target_assignment_id' => $tgtA->id,
        'reason' => 'E2E ' . $testName
    ]);
    echo "CREATE RESPONSE: " . $createResp['http_code'] . "\n" . $createResp['body'] . "\n\n";

    if ($createResp['http_code'] !== 201) {
        $err = 'Create failed. HTTP ' . $createResp['http_code'];
        if (preg_match('/"message": "(.*?)"/', $createResp['body'], $m)) {
            $err .= ' - Exception: ' . $m[1];
        }
        $results[$testName] = ['Result' => 'FAIL', 'reason' => $err, 'body' => substr($createResp['body'], 0, 500)];
        continue;
    }

    $createdData = json_decode($createResp['body'], true);
    $reqId = $createdData['data']['id'] ?? $createdData['id'] ?? null;
    
    $reqDb1 = DB::select('SELECT status FROM shift_requests WHERE id=?', [$reqId])[0];
    if ($reqDb1->status !== 'pending') {
        $results[$testName] = ['Result' => 'FAIL', 'reason' => 'Status is not pending after create.'];
        continue;
    }

    // Accept
    $acceptResp = http_post_local($base.'/shift-requests/'.$reqId.'/accept', $tgtToken, null);
    echo "ACCEPT RESPONSE: " . $acceptResp['http_code'] . "\n" . $acceptResp['body'] . "\n\n";

    if ($acceptResp['http_code'] !== 200) {
        $results[$testName] = ['Result' => 'FAIL', 'reason' => 'Accept failed. HTTP ' . $acceptResp['http_code']];
        continue;
    }

    $reqDb2 = DB::select('SELECT status FROM shift_requests WHERE id=?', [$reqId])[0];
    if ($reqDb2->status !== 'accepted_by_target') {
        $results[$testName] = ['Result' => 'FAIL', 'reason' => 'Status is not accepted_by_target after accept.'];
        continue;
    }

    // Approve
    $approveResp = http_post_local($base.'/admin/shift-requests/'.$reqId.'/approve', $adminToken, ['vehicle_id' => null]);
    echo "APPROVE RESPONSE: " . $approveResp['http_code'] . "\n" . $approveResp['body'] . "\n\n";

    if ($approveResp['http_code'] !== 200) {
        $results[$testName] = ['Result' => 'FAIL', 'reason' => 'Approve failed. HTTP ' . $approveResp['http_code']];
        continue;
    }

    $reqDb3 = DB::select('SELECT status FROM shift_requests WHERE id=?', [$reqId])[0];
    if ($reqDb3->status !== 'approved') {
        $results[$testName] = ['Result' => 'FAIL', 'reason' => 'Status is not approved after approve.'];
        continue;
    }

    // Verify Swapped
    $after = [
        dump_assignment($reqA->id),
        dump_assignment($tgtA->id)
    ];
    echo "DB State After:\n" . json_encode($after, JSON_PRETTY_PRINT) . "\n";

    if ($after[0]['user_id'] === $before[1]['user_id'] && $after[1]['user_id'] === $before[0]['user_id']) {
        $results[$testName] = ['Result' => 'PASS'];
    } else {
        $results[$testName] = ['Result' => 'FAIL', 'reason' => 'user_id was not swapped in shift_assignments.'];
    }
}

// Cross Role Validation
echo "--- Testing Cross Role Validation ---\n";
if ($crossRole1 && $crossRole2) {
    $reqToken = $tokens[$crossRole1->user_id];
    $createResp = http_post_local($base.'/shift-requests', $reqToken, [
        'requester_assignment_id' => $crossRole1->id,
        'target_assignment_id' => $crossRole2->id,
        'reason' => 'Cross Role Fail'
    ]);
    echo "CROSS ROLE CREATE RESPONSE: " . $createResp['http_code'] . "\n" . $createResp['body'] . "\n\n";
    if ($createResp['http_code'] === 422 || $createResp['http_code'] === 403) {
        $results['Cross Role Validation'] = ['Result' => 'PASS'];
    } else {
        $err = 'Allowed cross role swap. HTTP ' . $createResp['http_code'];
        if (preg_match('/"message": "(.*?)"/', $createResp['body'], $m)) {
            $err .= ' - Exception: ' . $m[1];
        }
        $results['Cross Role Validation'] = ['Result' => 'FAIL', 'reason' => $err];
    }
} else {
    $results['Cross Role Validation'] = ['Result' => 'FAIL', 'reason' => 'Could not find users for cross role swap.'];
}

// DB Integrity
$integrity = 'PASS';
// check for dupes (same user, same date/shift)
$dupes = DB::select('
    SELECT sa.user_id, s.date, count(*) as cnt 
    FROM shift_assignments sa 
    JOIN shifts s ON sa.shift_id = s.id 
    GROUP BY sa.user_id, s.date 
    HAVING cnt > 1
');

if (count($dupes) > 0) {
    $integrity = 'FAIL (duplicates found)';
}

$results['Database Integrity'] = ['Result' => $integrity];

echo "\n====================\n";
echo "| Test | Result |\n";
echo "| --- | --- |\n";
foreach (['Leader Swap', 'Scout Swap', 'Paramedic Swap', 'Cross Role Validation', 'Database Integrity'] as $t) {
    $r = $results[$t]['Result'] ?? 'UNKNOWN';
    echo "| $t | $r |\n";
}
echo "====================\n\n";

foreach ($results as $k => $v) {
    if ($v['Result'] === 'FAIL') {
        echo "Failure details for $k: " . ($v['reason'] ?? '') . "\n";
    }
}
