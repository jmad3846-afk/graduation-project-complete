<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class StoreShiftRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'shift_plan_id' => 'required|exists:shift_plans,id',
            'date' => 'required|date',
            'center_id' => 'required|exists:centers,id',
            'type' => 'required|in:morning,evening,night'
        ];
    }
}
