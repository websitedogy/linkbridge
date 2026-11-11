<?php

namespace App\Features\Registry\Http\Requests;

use App\Features\Companies\Enums\CompanyType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreRegistrySubmissionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $cin = strtoupper((string) preg_replace('/\s+/', '', (string) $this->input('cin')));
        $contact = (string) preg_replace('/\D+/', '', (string) $this->input('director_contact'));

        $this->merge([
            'company_name' => trim((string) $this->input('company_name')),
            'cin' => $cin === '' ? null : $cin,
            'director_contact' => $contact,
            'director_email' => strtolower(trim((string) $this->input('director_email'))),
            'location' => trim((string) $this->input('location')),
        ]);
    }

    public function rules(): array
    {
        return [
            'company_type' => ['required', Rule::enum(CompanyType::class)],
            'company_name' => ['required', 'string', 'max:255'],
            'cin' => ['nullable', 'string', 'size:21', 'regex:/^[A-Z]{1}[0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}$/'],
            'director_contact' => ['required', 'string', 'regex:/^[6-9][0-9]{9}$/'],
            'director_email' => ['required', 'email', 'max:255'],
            'location' => ['required', 'string', 'max:500'],
            'latitude' => ['nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['nullable', 'numeric', 'between:-180,180'],
        ];
    }

    public function messages(): array
    {
        return [
            'company_type.required' => 'Select a company type.',
            'company_name.required' => 'Enter the company name.',
            'cin.size' => 'CIN must be 21 characters, or leave it blank.',
            'cin.regex' => 'Enter a valid 21-character CIN, or leave it blank.',
            'director_contact.required' => 'Enter the director contact number.',
            'director_contact.regex' => 'Enter a valid 10-digit mobile number.',
            'director_email.required' => 'Enter the director mail id.',
            'director_email.email' => 'Enter a valid director mail id.',
            'location.required' => 'Current location is required.',
        ];
    }
}
