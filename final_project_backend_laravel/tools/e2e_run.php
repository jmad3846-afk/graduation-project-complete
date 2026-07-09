<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$k = $app->make(Illuminate\Contracts\Console\Kernel::class);
$k->bootstrap();
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request as HttpRequest;

function http_post_local($path, $token = null, $data = null) {
    try {
        $server = [];
        if ($token) $server['HTTP_AUTHORIZATION'] = 'Bearer '.$token;
        $server['HTTP_ACCEPT'] = 'application/json';
        $server['CONTENT_TYPE'] = 'application/json';
        $body = $data !== null ? json_encode($data) : null;
        $request = HttpRequest::create($path, 'POST', [], [], [], $server, $body);
        $kernel = app()->make(Illuminate\Contracts\Http\Kernel::class);
        $response = $kernel->handle($request);
        $content = $response->getContent();
        $status = $response->getStatusCode();
        // terminate middleware kernel lifecycle
        $kernel->terminate($request, $response);
        return ['http_code' => $status, 'body' => $content, 'error' => null];
    } catch (\Throwable $e) {
        return ['http_code' => 0, 'body' => null, 'error' => $e->getMessage()];
    }
}

$base='/api';
$adminUser = \App\Models\User::where('role', 'admin')->first();
$adminToken = $adminUser->createToken('e2e')->plainTextToken;

$tokenMap = [];
$usersToMap = [5, 8, 9, 10, 11, 12];
foreach ($usersToMap as $uid) {
    $u = \App\Models\User::find($uid);
    if ($u) {
        $tokenMap[$uid] = $u->createToken('e2e')->plainTextToken;
    }
}

$result = ['phase1'=>[], 'phase2'=>[]];

// PHASE 1 - create plan
$create = http_post_local($base.'/admin/shift-plans', $adminToken, ['month'=>7,'year'=>2026]);
$result['phase1']['create_plan'] = $create;
$plan = json_decode($create['body'], true);
$planId = $plan['data']['id'] ?? $plan['id'] ?? null;
if (!$planId) {
    echo json_encode(['error'=>'Failed to create plan','create'=>$create], JSON_PRETTY_PRINT);
    exit(1);
}
// start polls
foreach (['start-leader-poll','start-scout-poll','start-paramedic-poll'] as $ep) {
    $r = http_post_local($base."/admin/shift-plans/{$planId}/{$ep}", $adminToken, null);
    $result['phase1']['polls_started'][$ep] = $r;
}
// list polls
$polls = DB::select('SELECT id,user_id,role,status FROM shift_polls WHERE shift_plan_id=?', [$planId]);
$result['phase1']['polls_db'] = $polls;
// submit first pending poll per role
$roleFirst = [];
foreach ($polls as $p) {
    if ($p->status !== 'pending') continue;
    if (!isset($roleFirst[$p->role])) $roleFirst[$p->role] = $p->id;
}
$result['phase1']['submit_polls'] = [];
foreach ($roleFirst as $role=>$pollId) {
    // map role to token
    $token = null;
    if ($role === 'paramedic') $token = $tokenMap[5] ?? null;
    if ($role === 'scout') $token = $tokenMap[9] ?? null;
    if ($role === 'leader') $token = $tokenMap[11] ?? null;
    if (!$token) { $result['phase1']['submit_polls'][$role] = ['error'=>'no token']; continue; }
    $r = http_post_local($base.'/shift-polls/'.$pollId.'/submit', $token, ['preferred_days'=>[], 'unavailable_days'=>[]]);
    $result['phase1']['submit_polls'][$role] = $r;
}
// build schedule
$build = http_post_local($base.'/admin/shift-plans/'.$planId.'/build', $adminToken, null);
$result['phase1']['build'] = $build;
// assignments
$assignments = DB::select('SELECT sa.id, sa.user_id, u.name, sa.role, s.date, s.type, sa.team_number FROM shift_assignments sa JOIN shifts s ON s.id=sa.shift_id JOIN users u ON u.id=sa.user_id WHERE s.shift_plan_id=?', [$planId]);
$result['phase1']['assignments'] = $assignments;
// publish
$pub = http_post_local($base.'/admin/shift-plans/'.$planId.'/publish', $adminToken, null);
$result['phase1']['publish'] = $pub;
// final plan row
$planRow = DB::select('SELECT id,month,year,status,published_at FROM shift_plans WHERE id=?', [$planId]);
$result['phase1']['plan_final'] = $planRow;

// PHASE 2 - swap tests
$tests = [
    'A'=>['requester'=>1,'target'=>2,'expect'=>'PASS','desc'=>'Paramedic <-> Paramedic'],
    'B'=>['requester'=>3,'target'=>4,'expect'=>'PASS','desc'=>'Scout <-> Scout'],
    'C'=>['requester'=>5,'target'=>6,'expect'=>'PASS','desc'=>'Leader <-> Leader'],
    'D'=>['requester'=>1,'target'=>3,'expect'=>'FAIL','desc'=>'Paramedic <-> Scout'],
    'E'=>['requester'=>3,'target'=>5,'expect'=>'FAIL','desc'=>'Scout <-> Leader'],
];
foreach ($tests as $k=>$t) {
    $rId=$t['requester']; $sId=$t['target'];
    $before = DB::select('SELECT * FROM shift_assignments WHERE id IN (?,?)', [$rId,$sId]);
    $result['phase2'][$k]['before'] = $before;
    $ra = DB::select('SELECT user_id, role FROM shift_assignments WHERE id=?', [$rId])[0];
    $ta = DB::select('SELECT user_id, role FROM shift_assignments WHERE id=?', [$sId])[0];
    $result['phase2'][$k]['roles'] = ['requester'=>$ra->role,'target'=>$ta->role];
    $reqUser = $ra->user_id; $tgtUser = $ta->user_id;
    $reqToken = $tokenMap[$reqUser] ?? null;
    $tgtToken = $tokenMap[$tgtUser] ?? null;
    $create = http_post_local($base.'/shift-requests', $reqToken, ['requester_assignment_id'=>$rId,'target_assignment_id'=>$sId,'reason'=>'E2E '.$k]);
    $result['phase2'][$k]['create'] = $create;
    $createdId = null;
    if ($create['http_code']==201) {
        $cbody = json_decode($create['body'], true);
        $createdId = $cbody['data']['id'] ?? $cbody['id'] ?? null;
    }
    if ($createdId) {
        $accept = http_post_local($base.'/shift-requests/'.$createdId.'/accept', $tgtToken, null);
        $approve = http_post_local($base.'/admin/shift-requests/'.$createdId.'/approve', $adminToken, ['vehicle_id'=>null]);
        $result['phase2'][$k]['accept'] = $accept;
        $result['phase2'][$k]['approve'] = $approve;
    }
    $after = DB::select('SELECT * FROM shift_assignments WHERE id IN (?,?)', [$rId,$sId]);
    $result['phase2'][$k]['after'] = $after;
    // swap check
    $swap_ok = null; $dup_ok = null;
    if ($createdId && isset($result['phase2'][$k]['approve']) && $result['phase2'][$k]['approve']['http_code']==200) {
        $u_before_req = $before[0]->user_id; $u_before_tgt = $before[1]->user_id;
        $a_map = []; foreach ($after as $ar) $a_map[$ar->id]=$ar->user_id;
        if (isset($a_map[$rId]) && isset($a_map[$sId])) $swap_ok = ($a_map[$rId]==$u_before_tgt && $a_map[$sId]==$u_before_req);
        $dup_rows = DB::select('SELECT user_id, date, count(*) as cnt FROM shift_assignments sa JOIN shifts s ON s.id=sa.shift_id WHERE sa.user_id IN (?,?) GROUP BY user_id, date HAVING cnt>1', [$u_before_req,$u_before_tgt]);
        $dup_ok = count($dup_rows)==0;
    }
    $result['phase2'][$k]['swap_ok']=$swap_ok;
    $result['phase2'][$k]['dup_ok']=$dup_ok;
}

// Output JSON
file_put_contents('tools/e2e_run_result.json', json_encode($result, JSON_PRETTY_PRINT));
echo json_encode(['status'=>'done','file'=>'tools/e2e_run_result.json']);
