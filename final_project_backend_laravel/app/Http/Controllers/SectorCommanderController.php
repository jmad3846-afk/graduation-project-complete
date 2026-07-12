<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\SectorCommanderService;
use App\Http\Resources\CaseResource;
use App\Http\Resources\TeamResource;
use App\Http\Resources\CenterResource;

class SectorCommanderController extends Controller
{
    protected $service;

    public function __construct(SectorCommanderService $service)
    {
        $this->service = $service;
    }

    public function dashboardResponse(Request $request)
    {
        $pending = $this->service->getPendingTasks();
        $active = $this->service->getActiveTasks();
        $teams = $this->service->getTeams();
        $centers = $this->service->getCentersWithCounts();

        return response()->json([
            'active_tasks' => CaseResource::collection($active),
            'pending_tasks' => CaseResource::collection($pending),
            'teams' => TeamResource::collection(collect($teams)),
            'centers' => CenterResource::collection($centers),
        ]);
    }

    public function teamStatus(int $centerId)
    {
        return response()->json([
            'team_status' => $this->service->getTeamStatusForCenter($centerId),
        ]);
    }
}
