<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$k = $app->make(Illuminate\Contracts\Console\Kernel::class);
$k->bootstrap();
use Illuminate\Support\Facades\DB;

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

$base='http://127.0.0.1:8000';
$adminToken='3fa7b3f7e916ae1852c94757cd6d5010e6b21232586e0d8b857f9a1f699d497b';
$tokenMap = [
    5 => 'b5d8099c64cb657fbc38f389e8aaabdcb88eae8d1ca298b312c46ade2d4f9e8e', // Paramedic User
    8 => '0da863eaf2a7a735f8adbd93c300ff8c3e0354874fdce25e3c00d9e2aff7bec7', // Paramedic Two
    9 => '38fce0c103e3c9cce67894e08f5835172c5850664aef66d7c0ff6f9c30a39400', // Scout One
    10 => '3871d60cac899052c425d9af8021b8f19b4d2b06053c831aae801d596b354d44', // Scout Two
    11 => 'd1e9172ac57e013b63ad0f2d5042ead8122d575b4387af56f776119b2e8426bc', // Leader One
    12 => 'd714edd8ff6d720f89293d5e747f1f48c96e46366fa17625f094d54f14315dbc', // Leader Two
];

$tests = [
    'A'=>['requester'=>1,'target'=>2,'expect'=>'PASS','desc'=>'Paramedic <-> Paramedic'],
    'B'=>['requester'=>3,'target'=>4,'expect'=>'PASS','desc'=>'Scout <-> Scout'],
    'C'=>['requester'=>5,'target'=>6,'expect'=>'PASS','desc'=>'Leader <-> Leader'],
    'D'=>['requester'=>1,'target'=>3,'expect'=>'FAIL','desc'=>'Paramedic <-> Scout'],
    'E'=>['requester'=>3,'target'=>5,'expect'=>'FAIL','desc'=>'Scout <-> Leader'],
];

$results = [];
foreach ($tests as $key=>$t) {
    $rId = $t['requester']; $sId = $t['target'];
    $before = DB::select('SELECT * FROM shift_assignments WHERE id IN (?,?)', [$rId,$sId]);
    $results[$key]['before'] = $before;
    // Get requester user_id to pick token
    $ra = DB::select('SELECT user_id, role FROM shift_assignments WHERE id=?', [$rId])[0];
    $ta = DB::select('SELECT user_id, role FROM shift_assignments WHERE id=?', [$sId])[0];
    $results[$key]['roles'] = ['requester_role'=>$ra->role,'target_role'=>$ta->role];
    $reqUser = $ra->user_id; $tgtUser = $ta->user_id;
    $reqToken = $tokenMap[$reqUser] ?? null;
    $tgtToken = $tokenMap[$tgtUser] ?? null;
    // Create request
    $create = http_post($base.'/api/shift-requests', $reqToken, ['requester_assignment_id'=>$rId,'target_assignment_id'=>$sId,'reason'=>'E2E test '.$key]);
    $results[$key]['create'] = $create;
    $createdId = null;
    if ($create['http_code']==201) {
        $body = json_decode($create['body'], true);
        $createdId = $body['data']['id'] ?? null;
    }
    // If created, target accept
    $accept=null; $approve=null;
    if ($createdId) {
        $accept = http_post($base.'/api/shift-requests/'.$createdId.'/accept', $tgtToken, null);
        $results[$key]['accept'] = $accept;
        // Admin approve
        $approve = http_post($base.'/api/admin/shift-requests/'.$createdId.'/approve', $adminToken, ['vehicle_id'=>null]);
        $results[$key]['approve'] = $approve;
    }
    // After state
    $after = DB::select('SELECT * FROM shift_assignments WHERE id IN (?,?)', [$rId,$sId]);
    $results[$key]['after'] = $after;
    // Determine pass/fail for swap user IDs if expect PASS
    $swap_ok = null; $dup_ok = true;
    if ($createdId && isset($results[$key]['approve']) && $results[$key]['approve']['http_code']==200) {
        // compare user_id swapped
        $u_before_req = $before[0]->user_id;
        $u_before_tgt = $before[1]->user_id;
        // find corresponding after rows by id
        $a_map = [];
        foreach ($after as $ar) $a_map[$ar->id] = $ar->user_id;
        if (isset($a_map[$rId]) && isset($a_map[$sId])) {
            $swap_ok = ($a_map[$rId]==$u_before_tgt && $a_map[$sId]==$u_before_req);
        }
        // duplicate check: ensure no duplicate assignments for same user on same shift
        $dup_rows = DB::select('SELECT user_id, date, count(*) as cnt FROM shift_assignments sa JOIN shifts s ON s.id=sa.shift_id WHERE sa.user_id IN (?,?) GROUP BY user_id, date HAVING cnt>1', [$u_before_req,$u_before_tgt]);
        $dup_ok = count($dup_rows)==0;
    }
    $results[$key]['swap_ok'] = $swap_ok;
    $results[$key]['dup_ok'] = $dup_ok;
}
file_put_contents('tools/e2e_phase2_results.json', json_encode($results, JSON_PRETTY_PRINT));
echo "Phase2 complete, results saved to tools/e2e_phase2_results.json\n";
