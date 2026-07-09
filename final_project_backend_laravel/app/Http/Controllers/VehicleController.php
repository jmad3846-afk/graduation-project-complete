<?php

namespace App\Http\Controllers;

use App\Models\Vehicle;
use Illuminate\Http\Request;

class VehicleController extends Controller
{
    public function index()
    {
        return response()->json(Vehicle::all());
    }

    public function updateLocation(Request $request, $id)
    {
        $request->validate(['lat' => 'required|numeric', 'lng' => 'required|numeric']);
        $vehicle = Vehicle::findOrFail($id);
        $vehicle->update(['current_lat' => $request->lat, 'current_lng' => $request->lng]);
        return response()->json(['message' => 'Location updated', 'vehicle' => $vehicle]);
    }

    public function changeStatus(Request $request, $id)
    {
        $request->validate(['status' => 'required|in:available,on_mission,out_of_service']);
        $vehicle = Vehicle::findOrFail($id);
        $vehicle->update(['status' => $request->status]);
        return response()->json(['message' => 'Status updated', 'vehicle' => $vehicle]);
    }
}
