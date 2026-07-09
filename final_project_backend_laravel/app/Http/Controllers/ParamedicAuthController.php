<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class ParamedicAuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'phone' => 'required|string',
            'password' => 'required|string',
        ]);

        $user = User::where('phone', $request->phone)->first();

        if (! $user || $user->role !== 'paramedic' || ! Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'phone' => ['The provided credentials are incorrect.'],
            ]);
        }

        $token = $user->createToken('paramedic_mobile')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'role' => $user->role,
                'rank' => $user->rank,
                'center_id' => $user->center_id,
            ],
        ]);
    }

    public function logout(Request $request)
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        $token = $request->bearerToken();
        if ($token && $request->user()->currentAccessToken()) {
            $request->user()->currentAccessToken()->delete();
        } else {
            // As a fallback, delete all tokens for this user (mobile logout)
            $request->user()->tokens()->delete();
        }

        return response()->json(['message' => 'Logged out']);
    }
}
