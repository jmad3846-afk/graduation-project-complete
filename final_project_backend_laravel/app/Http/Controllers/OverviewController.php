<?php

namespace App\Http\Controllers;

use App\Http\Resources\CaseResource;
use App\Services\OverviewService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class OverviewController extends Controller
{
    protected $service;

    public function __construct(OverviewService $service)
    {
        $this->service = $service;
    }

    public function dashboard(Request $request)
    {
        return response()->json([
            'active_tasks' => CaseResource::collection($this->service->getActiveTasks()),
            'centers' => $this->service->getCentersOverview(),
        ]);
    }

    public function statistics(Request $request)
    {
        $data = $request->validate([
            'center_id' => ['required', 'integer', 'exists:centers,id'],
            'period' => ['required', Rule::in(['day', 'week', 'month'])],
        ]);

        return response()->json(
            $this->service->getCenterStatistics((int) $data['center_id'], $data['period'])
        );
    }
}
