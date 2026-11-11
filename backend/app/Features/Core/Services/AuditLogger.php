<?php

namespace App\Features\Core\Services;

use App\Features\Auth\Models\User;
use App\Features\Core\Models\AuditLog;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\Request;

class AuditLogger
{
    public function __construct(private readonly Request $request) {}

    public function log(string $action, ?Model $subject = null, ?User $actor = null, array $properties = []): void
    {
        AuditLog::query()->create([
            'actor_user_id' => $actor?->id ?? $this->request->user()?->id,
            'action' => $action,
            'subject_type' => $subject ? $subject::class : null,
            'subject_id' => $subject?->getKey(),
            'ip_address' => $this->request->ip(),
            'properties' => $properties === [] ? null : $properties,
            'created_at' => now(),
        ]);
    }
}
