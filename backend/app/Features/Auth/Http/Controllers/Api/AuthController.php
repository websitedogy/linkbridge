<?php

namespace App\Features\Auth\Http\Controllers\Api;

use App\Features\Auth\Http\Requests\LoginRequest;
use App\Features\Auth\Http\Requests\RegisterRequest;
use App\Features\Auth\Http\Requests\UpdateProfileRequest;
use App\Features\Auth\Http\Requests\VerifyOtpRequest;
use App\Features\Auth\Http\Resources\UserResource;
use App\Features\Auth\Services\AuthService;
use App\Features\Core\Services\AuditLogger;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    public function __construct(
        private readonly AuthService $auth,
        private readonly AuditLogger $audit,
    ) {}

    public function register(RegisterRequest $request)
    {
        $payload = $this->auth->register($request->validated());

        return ApiResponse::success($payload, 'OTP sent to your email.', 201);
    }

    public function login(LoginRequest $request)
    {
        $payload = $this->auth->requestLoginOtp($request->validated('email'));

        return ApiResponse::success($payload, 'OTP sent to your email.');
    }

    public function verifyOtp(VerifyOtpRequest $request)
    {
        [$user, $token] = $this->auth->verifyOtp(
            $request->validated('email'),
            $request->validated('otp'),
        );

        return ApiResponse::success([
            'token' => $token,
            'token_type' => 'Bearer',
            'user' => new UserResource($user),
        ], 'Logged in successfully.');
    }

    public function resendOtp(LoginRequest $request)
    {
        $payload = $this->auth->requestLoginOtp($request->validated('email'));

        return ApiResponse::success($payload, 'OTP sent to your email.');
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()?->delete();
        $this->audit->log('auth.logout', $request->user(), $request->user());

        return ApiResponse::success(null, 'Logged out successfully.');
    }

    public function update(UpdateProfileRequest $request)
    {
        $user = $this->auth->updateProfile($request->user(), $request->validated());

        return ApiResponse::success(
            new UserResource($user),
            'Profile updated successfully.',
        );
    }

    public function me(Request $request)
    {
        return ApiResponse::success(
            new UserResource($request->user()->load(['profile', 'buyerProfile', 'sellerProfile'])),
            'Profile retrieved successfully.',
        );
    }
}
