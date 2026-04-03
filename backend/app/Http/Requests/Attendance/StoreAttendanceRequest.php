<?php

namespace App\Http\Requests\Attendance;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreAttendanceRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'type' => ['required', Rule::in(['in', 'out'])],
            'latitude' => ['required', 'string'],
            'longitude' => ['required', 'string'],
            'foto_selfie' => [
                'required',
                'file',
                'image',
                'mimes:jpg,jpeg,png',
                'max:5120', // Max 5MB
            ],
        ];
    }
}
