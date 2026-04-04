<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;

class AuthService
{
    /**
     * Update profil user.
     */
    public function updateProfile(User $user, array $data): User
    {
        $updateData = [];

        // Update Nama jika ada
        if (isset($data['name'])) {
            $updateData['name'] = $data['name'];
        }

        // Update Email jika ada
        if (isset($data['email'])) {
            $updateData['email'] = $data['email'];
        }

        // 1. Logika Update Password
        if (! empty($data['password'])) {
            $updateData['password'] = Hash::make($data['password']);
        }

        // 2. Logika Update Avatar (Hapus yang lama jika ada)
        if (isset($data['avatar'])) {
            if ($user->avatar) {
                Storage::disk('public')->delete($user->avatar);
            }
            $updateData['avatar'] = $data['avatar']->store('avatars', 'public');
        }

        if (! empty($updateData)) {
            $user->update($updateData);
        }

        return $user;
    }

    /**
     * Daftarkan user baru (khusus untuk mode demo/portofolio).
     */
    public function register(array $data): User
    {
        return User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'position' => $data['position'],
        ]);
    }

    /**
     * Authenticate a user and return a token.
     *
     * @param  array<string, string>  $credentials
     * @return array<string, mixed>
     */
    public function login(array $credentials): array
    {
        $user = User::where('email', $credentials['email'])->first();

        if (! $user || ! Hash::check($credentials['password'], $user->password)) {
            throw \Illuminate\Validation\ValidationException::withMessages([
                'credentials' => ['Email atau password yang Anda masukkan salah.'],
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return [
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'position' => $user->position,
            ],
        ];
    }

    /**
     * Logout the current user and revoke their token.
     */
    public function logout(User $user): void
    {
        $user->currentAccessToken()->delete();
    }

    /**
     * Get the current user profile data.
     *
     * @return array<string, mixed>
     */
    public function getCurrentUser(User $user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'position' => $user->position,
            'avatar_url' => $user->avatar ? asset('storage/'.$user->avatar) : null,
        ];
    }
}
