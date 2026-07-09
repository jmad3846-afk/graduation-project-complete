<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Services\SectorCommanderService;

class DumpSectorCommanderDashboard extends Command
{
    protected $signature = 'sc:dump-dashboard';
    protected $description = 'Dump Sector Commander dashboard JSON to console';

    public function handle(SectorCommanderService $service)
    {
        $pending = $service->getPendingTasks();
        $active = $service->getActiveTasks();
        $teams = $service->getTeams();
        $centers = $service->getCentersWithCounts();

        $payload = [
            'active_tasks' => \App\Http\Resources\CaseResource::collection($active),
            'pending_tasks' => \App\Http\Resources\CaseResource::collection($pending),
            'teams' => $teams,
            'centers' => \App\Http\Resources\CenterResource::collection($centers),
        ];

        $this->line(json_encode($payload, JSON_PRETTY_PRINT));
        return 0;
    }
}
