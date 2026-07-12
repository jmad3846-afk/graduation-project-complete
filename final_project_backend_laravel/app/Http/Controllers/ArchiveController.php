<?php

namespace App\Http\Controllers;

use App\Models\Archive;
use App\Models\EmsCase;
use Illuminate\Http\Request;

class ArchiveController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'case_id' => 'required|exists:cases,id',
            'disclaimer_image' => 'required|image|mimes:jpeg,png,jpg,gif|max:5120'
        ]);

        $case = EmsCase::findOrFail($validated['case_id']);
        
        if ($case->status !== 'closed') {
             return response()->json(['message' => 'Cannot archive an unclosed case'], 422);
        }

        $path = $request->file('disclaimer_image')->store('archive', 'public');
        
        $archive = Archive::create([
            'case_id' => $case->id,
            'disclaimer_image' => 'storage/' . $path,
            'archived_at' => now(),
            'printed' => false
        ]);

        return response()->json(['message' => 'Archive stored successfully', 'archive' => $archive]);
    }

    public function index()
    {
        $archives = Archive::with(['emsCase.patient', 'emsCase.center'])
            ->orderBy('archived_at', 'desc')
            ->get();

        return response()->json(['archives' => $archives]);
    }

    public function markPrinted(int $id)
    {
        $archive = Archive::findOrFail($id);
        $archive->printed = true;
        $archive->save();

        return response()->json(['message' => 'Archive marked as printed', 'archive' => $archive]);
    }
}
