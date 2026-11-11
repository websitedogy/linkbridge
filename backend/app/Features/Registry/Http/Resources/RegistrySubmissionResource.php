<?php

namespace App\Features\Registry\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RegistrySubmissionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'company_type' => $this->company_type?->value,
            'company_type_label' => $this->company_type?->label(),
            'company_name' => $this->company_name,
            'cin' => $this->cin,
            'director_contact' => $this->director_contact,
            'director_email' => $this->director_email,
            'location' => $this->location,
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'status' => strtoupper($this->status->value),
            'created_at' => $this->created_at,
            'submitted_by' => $this->whenLoaded('user', fn () => [
                'id' => $this->user?->id,
                'name' => $this->user?->name,
                'email' => $this->user?->email,
                'mobile' => $this->user?->mobile,
            ]),
        ];
    }
}
