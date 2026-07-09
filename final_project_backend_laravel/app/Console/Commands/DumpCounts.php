<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class DumpCounts extends Command
{
    protected $signature = 'sc:counts';
    protected $description = 'Dump counts for centers, shifts, shift_assignments, vehicles';

    public function handle()
    {
        $db = app('db');

        $centers = $db->table('centers')->count();
        $shifts = $db->table('shifts')->count();
        $assignments = $db->table('shift_assignments')->count();
        $vehicles = $db->table('vehicles')->count();

        $this->line("SELECT COUNT(*) FROM centers; --> $centers");
        $this->line("SELECT COUNT(*) FROM shifts; --> $shifts");
        $this->line("SELECT COUNT(*) FROM shift_assignments; --> $assignments");
        $this->line("SELECT COUNT(*) FROM vehicles; --> $vehicles");

        return 0;
    }
}
