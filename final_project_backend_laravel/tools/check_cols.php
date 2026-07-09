<?php
require __DIR__.'/../bootstrap/app.php';
$k = app()->make(Illuminate\Contracts\Console\Kernel::class);
$k->bootstrap();

echo "shift_requests cols: \n";
print_r(Illuminate\Support\Facades\Schema::getColumnListing('shift_requests'));

echo "\nshift_assignments cols: \n";
print_r(Illuminate\Support\Facades\Schema::getColumnListing('shift_assignments'));

