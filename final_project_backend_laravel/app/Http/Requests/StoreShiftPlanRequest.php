<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreShiftPlanRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() && in_array($this->user()->role, ['admin','manager']);
    }

    public function rules(): array
    {
        return [
            'month' => ['required','integer','between:1,12'],
            'year' => ['required','integer','min:2000'],
        ];
    }
}
