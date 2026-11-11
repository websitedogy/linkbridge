<?php

namespace App\Features\Auth\Services;

use App\Features\Auth\Enums\UserRole;
use App\Features\Auth\Enums\UserStatus;
use App\Features\Auth\Enums\VerificationStatus;
use App\Features\Auth\Models\User;
use App\Features\Core\Services\AuditLogger;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AuthService
{
    public function __construct(
        private readonly AuditLogger $audit,
        private readonly OtpService $otp,
    ) {}

    public function register(array $data): array
    {
        $role = UserRole::from($data['role'] ?? UserRole::Buyer->value);

        if (! $role->isPublic()) {
            throw ValidationException::withMessages([
                'role' => ['This role cannot be registered publicly.'],
            ]);
        }

        $email = strtolower(trim((string) $data['email']));
        $mobile = trim((string) $data['mobile']);
        $name = trim((string) $data['name']);

        $existing = User::query()->whereRaw('lower(email) = ?', [$email])->first();
        if ($existing !== null && $existing->status === UserStatus::Active) {
            throw ValidationException::withMessages([
                'email' => ['This account already exists. Please login.'],
            ]);
        }

        $otherMobile = User::query()
            ->where('mobile', $mobile)
            ->when($existing, fn ($query) => $query->where('id', '!=', $existing->id))
            ->first();
        if ($otherMobile !== null) {
            throw ValidationException::withMessages([
                'mobile' => ['This account already exists. Please login.'],
            ]);
        }

        $user = DB::transaction(function () use ($data, $role, $email, $mobile, $name, $existing) {
            if ($existing !== null) {
                $existing->name = $name;
                $existing->mobile = $mobile;
                $existing->role = $role;
                $existing->save();

                return $existing->load(['profile', 'buyerProfile', 'sellerProfile']);
            }

            $user = User::query()->create([
                'name' => $name,
                'email' => $email,
                'mobile' => $mobile,
                'password' => $data['password'] ?? Str::password(32),
                'role' => $role,
                'status' => UserStatus::PendingVerification,
            ]);

            $user->assignRole($role->value);
            $user->profile()->create([
                'profile_type' => $role->value,
                'display_name' => $name,
            ]);

            if ($role === UserRole::Buyer) {
                $user->buyerProfile()->create([
                    'investor_type' => 'individual',
                    'verification_status' => VerificationStatus::Pending,
                ]);
            }

            if ($role === UserRole::Seller) {
                $user->sellerProfile()->create([
                    'seller_type' => 'owner',
                    'verification_status' => VerificationStatus::Pending,
                ]);
            }

            $this->audit->log('auth.registered', $user, $user, ['role' => $role->value]);

            return $user->load(['profile', 'buyerProfile', 'sellerProfile']);
        });

        return $this->challenge($user);
    }

    public function requestLoginOtp(string $email): array
    {
        $user = User::query()->whereRaw('lower(email) = ?', [strtolower(trim($email))])->first();

        if ($user === null) {
            throw ValidationException::withMessages([
                'email' => ['No account found. Please sign up.'],
            ]);
        }

        if ($user->status === UserStatus::Suspended) {
            throw ValidationException::withMessages([
                'email' => ['This account is suspended.'],
            ]);
        }

        return $this->challenge($user);
    }

    public function verifyOtp(string $email, string $code): array
    {
        $this->otp->verify($email, $code);

        $user = User::query()->whereRaw('lower(email) = ?', [strtolower(trim($email))])->first();
        if ($user === null) {
            throw ValidationException::withMessages([
                'email' => ['No account found. Please sign up.'],
            ]);
        }

        if ($user->status === UserStatus::Suspended) {
            throw ValidationException::withMessages([
                'email' => ['This account is suspended.'],
            ]);
        }

        if ($user->status !== UserStatus::Active) {
            $user->status = UserStatus::Active;
            $user->email_verified_at = now();
            $user->save();
        }

        $token = $user->createToken('api')->plainTextToken;
        $this->audit->log('auth.login', $user, $user);

        return [$user->load(['profile', 'buyerProfile', 'sellerProfile']), $token];
    }

    public function updateProfile(User $user, array $data): User
    {
        if (! empty($data['password'])) {
            if (empty($data['current_password']) || ! Hash::check($data['current_password'], $user->password)) {
                throw ValidationException::withMessages([
                    'current_password' => ['Current password is incorrect.'],
                ]);
            }

            $user->password = $data['password'];
        }

        $user->name = $data['name'];
        $user->email = filled($data['email'] ?? null) ? $data['email'] : null;
        $user->mobile = filled($data['mobile'] ?? null) ? $data['mobile'] : null;

        if ($user->email === null && $user->mobile === null) {
            throw ValidationException::withMessages([
                'email' => ['Enter an email or mobile number.'],
            ]);
        }

        $user->save();
        $user->profile?->update(['display_name' => $user->name]);
        $this->audit->log('auth.profile_updated', $user, $user);

        return $user->load(['profile', 'buyerProfile', 'sellerProfile']);
    }

    private function challenge(User $user): array
    {
        $email = (string) $user->email;
        $name = $user->name;
        $code = $this->otp->issue($email);

        dispatch(function () use ($email, $name, $code) {
            app(OtpService::class)->deliver($email, $name, $code);
        })->afterResponse();

        $payload = ['email' => $email];

        if (app()->runningUnitTests()) {
            $payload['otp'] = $code;
        }

        return $payload;
    }
}
