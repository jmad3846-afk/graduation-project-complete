<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreShiftRequestRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) $this->user();
    }

    public function rules(): array
    {
        return [
            'requester_assignment_id' => ['required','integer','exists:shift_assignments,id'],
            'target_assignment_id' => ['required','integer','exists:shift_assignments,id'],
            'reason' => ['nullable','string','max:2000'],
        ];
    }
}
