<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreCaseRequest;
use App\Services\CaseService;
use Illuminate\Http\Request;

class CaseController extends Controller
{
    protected $caseService;

    public function __construct(CaseService $caseService)
    {
        $this->caseService = $caseService;
    }

    public function index()
    {
        return response()->json($this->caseService->getAllCases());
    }

    public function store(StoreCaseRequest $request)
    {
        $case = $this->caseService->createCase($request->validated());
        return response()->json(['message' => 'Case created', 'case' => $case], 201);
    }

    public function update(Request $request, $id)
    {
        $case = $this->caseService->updateCase($id, $request->all());
        return response()->json(['message' => 'Case updated', 'case' => $case]);
    }

    public function assignCenter(Request $request, $id)
    {
        $request->validate(['center_id' => 'required|exists:centers,id']);
        $case = $this->caseService->assignCenter($id, $request->center_id);
        return response()->json(['message' => 'Center assigned', 'case' => $case]);
    }

    public function changeStatus(Request $request, $id)
    {
        $request->validate(['status' => 'required|in:waiting,assigned,in_progress,at_hospital,closed']);
        $case = $this->caseService->changeStatus($id, $request->status);
        return response()->json(['message' => 'Status changed', 'case' => $case]);
    }
}
