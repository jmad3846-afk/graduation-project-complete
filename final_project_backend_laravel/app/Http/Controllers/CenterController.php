<?php

namespace App\Http\Controllers;

use App\Models\Center;
use Illuminate\Http\Request;

class CenterController extends Controller
{
    public function index()
    {
        // Load center resources for Sector Leaders
        $centers = Center::with('vehicles')->get();
        return response()->json($centers);
    }
}
