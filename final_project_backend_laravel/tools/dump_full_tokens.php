<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();
use Illuminate\Support\Facades\DB;
$rows = DB::select("SELECT t.id, t.name, t.token, t.tokenable_id as user_id, u.name as user_name, u.role as role FROM personal_access_tokens t JOIN users u ON u.id = t.tokenable_id ORDER BY t.id DESC LIMIT 20");
foreach ($rows as $r) {
    echo "id={$r->id} user_id={$r->user_id} user_name={$r->user_name} role={$r->role} token={$r->token}\n";
}
