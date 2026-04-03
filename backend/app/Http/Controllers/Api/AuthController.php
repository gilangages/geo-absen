<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Services\AuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    public function __construct(protected AuthService $authService) {}

    /**
     * Handle user login.
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $data = $this->authService->login($request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil.',
            'data' => $data,
        ]);
    }

    /**
     * Handle user logout.
     */
    public function logout(Request $request): JsonResponse
    {
        $this->authService->logout($request->user());

        return response()->json([
            'success' => true,
            'message' => 'Berhasil logout.',
            'data' => null,
        ]);
    }

    /**
     * Get current user profile.
     */
    public function current(Request $request): JsonResponse
    {
        $data = $this->authService->getCurrentUser($request->user());

        return response()->json([
            'success' => true,
            'message' => 'Data profil berhasil diambil.',
            'data' => $data,
        ]);
    }
}
