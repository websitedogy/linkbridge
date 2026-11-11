<?php

namespace App\Features\Auth\Services;

use App\Features\Auth\Mail\OtpMail;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Mail;
use Illuminate\Validation\ValidationException;

class OtpService
{
    private const TTL_MINUTES = 10;

    private const MAX_ATTEMPTS = 5;

    public function issue(string $email): string
    {
        $code = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        $email = $this->normalize($email);

        Cache::put($this->key($email), [
            'hash' => $this->hash($code),
            'attempts' => 0,
        ], now()->addMinutes(self::TTL_MINUTES));

        return $code;
    }

    public function send(string $email, string $name): string
    {
        $code = $this->issue($email);
        $this->deliver($email, $name, $code);

        return $code;
    }

    public function deliver(string $email, string $name, string $code): void
    {
        try {
            Mail::to($this->normalize($email))->send(new OtpMail($name, $code));
        } catch (\Throwable $exception) {
            report($exception);
        }
    }

    public function verify(string $email, string $code): void
    {
        $email = $this->normalize($email);
        $payload = Cache::get($this->key($email));

        if (! is_array($payload) || empty($payload['hash'])) {
            throw ValidationException::withMessages([
                'otp' => ['This OTP has expired. Please request a new one.'],
            ]);
        }

        $attempts = (int) ($payload['attempts'] ?? 0);
        if ($attempts >= self::MAX_ATTEMPTS) {
            Cache::forget($this->key($email));

            throw ValidationException::withMessages([
                'otp' => ['Too many attempts. Please request a new OTP.'],
            ]);
        }

        if (! hash_equals((string) $payload['hash'], $this->hash($code))) {
            $payload['attempts'] = $attempts + 1;
            Cache::put($this->key($email), $payload, now()->addMinutes(self::TTL_MINUTES));

            throw ValidationException::withMessages([
                'otp' => ['The OTP is incorrect.'],
            ]);
        }

        Cache::forget($this->key($email));
    }

    private function key(string $email): string
    {
        return 'otp:'.$email;
    }

    private function hash(string $code): string
    {
        return hash_hmac('sha256', $code, (string) config('app.key'));
    }

    private function normalize(string $email): string
    {
        return strtolower(trim($email));
    }
}
