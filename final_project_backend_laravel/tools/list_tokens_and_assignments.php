<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();
use Illuminate\Support\Facades\DB;
// List tokens with user info
$tokens = DB::select("SELECT t.id, t.name, t.token, t.tokenable_id as user_id, u.name as user_name, u.role as role FROM personal_access_tokens t JOIN users u ON u.id = t.tokenable_id ORDER BY t.id DESC LIMIT 20");
echo "Tokens:\n";
foreach ($tokens as $t) {
    echo "id={$t->id} user_id={$t->user_id} user_name={$t->user_name} role={$t->role} token=".substr($t->token,0,16)."...\n";
}
// List sample assignments grouped by role
$roles = ['paramedic','scout','leader'];
foreach ($roles as $r) {
    echo "\nAssignments for role: $r\n";
    $rows = DB::select("SELECT sa.id as assignment_id, sa.user_id, u.name as user_name, sa.shift_id, s.date, s.type, sa.team_number FROM shift_assignments sa JOIN users u ON u.id = sa.user_id JOIN shifts s ON s.id = sa.shift_id WHERE sa.role = ? LIMIT 10", [$r]);
    foreach ($rows as $row) {
        echo json_encode($row) . "\n";
    }
}
