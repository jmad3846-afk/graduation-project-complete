<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreCaseRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            // Required fields for minimal report submission
            'caller_name' => 'required|string',
            'relation' => 'required|string', // maps from relation_to_patient
            'caller_phone' => 'required|string', // maps from relation_number
            'report_time' => 'required|string',
            'report_date' => 'required|string',
            // Optional fields – accepted as nullable so they can be omitted
            'triage_code' => 'nullable|string',
            'transfer_type' => 'nullable|string',
            'symptoms' => 'nullable|string',
            'breathing_rate' => 'nullable|integer|min:0',
            'medical_aid_given' => 'nullable|string',
            'operations_officer' => 'nullable|string',
            'sector_commander' => 'nullable|string',
            'patient_name' => 'nullable|string',
            'age' => 'nullable|integer|min:0',
            'weight' => 'nullable|numeric|min:0',
            'medical_history' => 'nullable|string',
            'oxygen_level' => 'nullable|numeric|min:0|max:100',
            'blood_pressure' => 'nullable|string',
            'blood_sugar' => 'nullable|numeric|min:0',
            'oxygen_before' => 'nullable|numeric|min:0|max:100',
            'oxygen_after' => 'nullable|numeric|min:0|max:100',
            'has_tube' => 'nullable|boolean',
            'conscious' => 'nullable|boolean',
        ];
    }
}
