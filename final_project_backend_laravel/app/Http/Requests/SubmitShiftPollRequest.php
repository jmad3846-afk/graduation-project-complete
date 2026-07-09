<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SubmitShiftPollRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) $this->user();
    }

    public function rules(): array
    {
        return [
            'preferred_shifts' => ['array'],
            'preferred_shifts.*.day' => ['required', 'integer', 'between:1,31'],
            'preferred_shifts.*.shift' => ['required', 'string', 'in:morning,evening,night'],
            'unavailable_shifts' => ['array'],
            'unavailable_shifts.*.day' => ['required', 'integer', 'between:1,31'],
            'unavailable_shifts.*.shift' => ['required', 'string', 'in:morning,evening,night'],
        ];
    }
}
