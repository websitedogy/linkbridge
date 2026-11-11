<?php

namespace App\Features\Assistant\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class AssistantRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'message' => ['required', 'string', 'max:500'],
        ];
    }
}
