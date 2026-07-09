<?php

namespace App\Http\Controllers;

use App\Events\VehicleLocationUpdated;
use App\Http\Requests\StoreGpsRequest;
use App\Models\GpsLog;
use App\Models\Vehicle;
use Illuminate\Http\Request;

class GpsController extends Controller
{
    public function store(StoreGpsRequest $request)
    {
        $log = GpsLog::create([
            'vehicle_id' => $request->vehicle_id,
            'latitude' => $request->lat,
            'longitude' => $request->lng,
        ]);

        $vehicle = Vehicle::findOrFail($request->vehicle_id);
        $vehicle->update(['current_lat' => $request->lat, 'current_lng' => $request->lng]);
        
        event(new VehicleLocationUpdated($vehicle));

        return response()->json(['message' => 'GPS logged', 'log' => $log], 201);
    }

    public function liveLocation($vehicle_id)
    {
        $vehicle = Vehicle::findOrFail($vehicle_id);
        return response()->json([
            'vehicle_id' => $vehicle->id,
            'lat' => $vehicle->current_lat,
            'lng' => $vehicle->current_lng,
            'last_update' => $vehicle->updated_at
        ]);
    }
}
