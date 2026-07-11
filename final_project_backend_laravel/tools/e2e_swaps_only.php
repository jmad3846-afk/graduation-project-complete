<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$k = $app->make(Illuminate\Contracts\Console\Kernel::class);
$k->bootstrap();

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request as HttpRequest;
use App\Models\User;

function http_call_local($method, $path, $token = null, $data = null) {
    try {
        $server = [];
        if ($token) $server['HTTP_AUTHORIZATION'] = 'Bearer '.$token;
        $server['HTTP_ACCEPT'] = 'application/json';
        $server['CONTENT_TYPE'] = 'application/json';
        $body = $data !== null ? json_encode($data) : null;
        $request = HttpRequest::create($path, $method, [], [], [], $server, $body);
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

function http_post_local($path, $token = null, $data = null) {
    return http_call_local('POST', $path, $token, $data);
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
    SELECT sa.id, sa.user_id, sa.role, sa.shift_id, s.date
    FROM shift_assignments sa
    JOIN shifts s ON sa.shift_id = s.id
    WHERE s.shift_plan_id = ?
", [$planId]);

$byRole = ['paramedic' => [], 'scout' => [], 'leader' => []];

foreach ($assignments as $a) {
    if (isset($byRole[$a->role])) $byRole[$a->role][] = $a;
}

function wouldCollideLocal($a, $b, $allForRole) {
    if ($a->shift_id === $b->shift_id) return true;
    foreach ($allForRole as $x) {
        if ($x->id === $a->id || $x->id === $b->id) continue;
        if (($x->shift_id === $a->shift_id && $x->user_id === $b->user_id)
            || ($x->shift_id === $b->shift_id && $x->user_id === $a->user_id)) {
            return true;
        }
    }
    return false;
}

function getTwoDifferentUsers($list) {
    // Prefer a pair that a real swap could satisfy (different shifts, and
    // neither user already independently holds the other's shift). Fall back
    // to a same-shift pair only if no valid pair exists for this role, so the
    // "cannot swap" guard itself can still be exercised.
    foreach ($list as $first) {
        foreach ($list as $candidate) {
            if ($candidate->user_id !== $first->user_id && !wouldCollideLocal($first, $candidate, $list)) {
                return [$first, $candidate];
            }
        }
    }
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

function getThirdUserSameRole($list, $excludeUserIds) {
    foreach ($list as $a) {
        if (!in_array($a->user_id, $excludeUserIds)) {
            return $a;
        }
    }
    return null;
}

$pairs = [
    'Paramedic Swap' => getTwoDifferentUsers($byRole['paramedic']),
    'Scout Swap' => getTwoDifferentUsers($byRole['scout']),
    'Leader Swap' => getTwoDifferentUsers($byRole['leader']),
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

    // Candidates dropdown check: same-role candidates must exclude self and any
    // assignment that would collide (same shift, or would create a duplicate
    // (shift_id,user_id) elsewhere) if swapped with.
    $candResp = http_call_local('GET', $base.'/shift-requests/candidates?my_assignment_id='.$reqA->id, $reqToken);
    $candBody = json_decode($candResp['body'], true);
    $candIds = array_column($candBody['data'] ?? $candBody, 'id');
    $candUserIds = array_column($candBody['data'] ?? $candBody, 'user_id');
    $wouldCollide = wouldCollideLocal($reqA, $tgtA, $byRole[$reqA->role]);
    $targetPresenceOk = $wouldCollide ? !in_array($tgtA->id, $candIds) : in_array($tgtA->id, $candIds);
    if ($candResp['http_code'] !== 200 || in_array($reqA->user_id, $candUserIds) || !$targetPresenceOk) {
        $results["$testName - Candidates"] = ['Result' => 'FAIL', 'reason' => 'Candidates endpoint did not return expected set. HTTP '.$candResp['http_code']];
    } else {
        $results["$testName - Candidates"] = ['Result' => 'PASS'];
    }

    if ($wouldCollide) {
        // A colliding pair is unrepresentable under "swap only user_id" (it would
        // violate the shift_assignments unique(shift_id,user_id) constraint), so
        // store() rejects it by design. Verify the rejection and move on instead
        // of asserting a swap that cannot happen for this pair.
        $rejResp = http_post_local($base.'/shift-requests', $reqToken, [
            'requester_assignment_id' => $reqA->id,
            'target_assignment_id' => $tgtA->id,
            'reason' => 'E2E ' . $testName . ' (colliding pair, expect reject)'
        ]);
        $results[$testName] = $rejResp['http_code'] === 422
            ? ['Result' => 'SKIP (colliding pair correctly rejected)']
            : ['Result' => 'FAIL', 'reason' => 'Colliding swap was not rejected. HTTP '.$rejResp['http_code']];
        continue;
    }

    // Create
    $createResp = http_post_local($base.'/shift-requests', $reqToken, [
        'requester_assignment_id' => $reqA->id,
        'target_assignment_id' => $tgtA->id,
        'reason' => 'E2E ' . $testName
    ]);
    echo "CREATE RESPONSE: " . $createResp['http_code'] . "\n" . $createResp['body'] . "\n\n";

    if ($createResp['http_code'] !== 201) {
        $err = 'Create failed. HTTP ' . $createResp['http_code'];
        if (preg_match('/"message":"(.*?)"/', $createResp['body'], $m)) {
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

    // Duplicate request should be rejected
    $dupResp = http_post_local($base.'/shift-requests', $reqToken, [
        'requester_assignment_id' => $reqA->id,
        'target_assignment_id' => $tgtA->id,
        'reason' => 'Duplicate attempt'
    ]);
    if ($dupResp['http_code'] === 422) {
        $results["$testName - Duplicate Rejected"] = ['Result' => 'PASS'];
    } else {
        $results["$testName - Duplicate Rejected"] = ['Result' => 'FAIL', 'reason' => 'Duplicate request was not rejected. HTTP '.$dupResp['http_code']];
    }

    // Self-swap should be rejected (use a different assignment owned by requester, if any)
    $selfTarget = null;
    foreach ($byRole[$reqA->role] as $a) {
        if ($a->user_id === $reqA->user_id && $a->id !== $reqA->id) { $selfTarget = $a; break; }
    }
    if ($selfTarget) {
        $selfResp = http_post_local($base.'/shift-requests', $reqToken, [
            'requester_assignment_id' => $reqA->id,
            'target_assignment_id' => $selfTarget->id,
            'reason' => 'Self swap attempt'
        ]);
        $results["$testName - Self Swap Rejected"] = $selfResp['http_code'] === 422
            ? ['Result' => 'PASS']
            : ['Result' => 'FAIL', 'reason' => 'Self swap was not rejected. HTTP '.$selfResp['http_code']];
    } else {
        $results["$testName - Self Swap Rejected"] = ['Result' => 'SKIP', 'reason' => 'No second same-role assignment owned by requester to test with.'];
    }

    // Approve (admin/manager only, no target-accept step anymore)
    $approveResp = http_post_local($base.'/admin/shift-requests/'.$reqId.'/approve', $adminToken, null);
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

    // Double-approve must be rejected and must NOT swap back
    $reApproveResp = http_post_local($base.'/admin/shift-requests/'.$reqId.'/approve', $adminToken, null);
    $afterSecond = [
        dump_assignment($reqA->id),
        dump_assignment($tgtA->id)
    ];
    $noSwapBack = $afterSecond[0]['user_id'] === $after[0]['user_id'] && $afterSecond[1]['user_id'] === $after[1]['user_id'];
    if ($reApproveResp['http_code'] === 422 && $noSwapBack) {
        $results["$testName - Idempotent Approve"] = ['Result' => 'PASS'];
    } else {
        $results["$testName - Idempotent Approve"] = ['Result' => 'FAIL', 'reason' => 'Second approve did not return 422 and/or swapped back. HTTP '.$reApproveResp['http_code']];
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
        if (preg_match('/"message":"(.*?)"/', $createResp['body'], $m)) {
            $err .= ' - Exception: ' . $m[1];
        }
        $results['Cross Role Validation'] = ['Result' => 'FAIL', 'reason' => $err];
    }
} else {
    $results['Cross Role Validation'] = ['Result' => 'FAIL', 'reason' => 'Could not find users for cross role swap.'];
}

// DB Integrity
$integrity = 'PASS';
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
foreach ($results as $t => $v) {
    $r = $v['Result'] ?? 'UNKNOWN';
    echo "| $t | $r |\n";
}
echo "====================\n\n";

foreach ($results as $k => $v) {
    if ($v['Result'] === 'FAIL') {
        echo "Failure details for $k: " . ($v['reason'] ?? '') . "\n";
    }
}
