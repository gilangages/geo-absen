<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test successful registration.
     */
    public function test_user_can_register(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'name' => 'Karyawan Demo',
            'email' => 'karyawan@demo.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'position' => 'Staff Marketing',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.email', 'karyawan@demo.com');

        $this->assertDatabaseHas('users', [
            'email' => 'karyawan@demo.com',
            'position' => 'Staff Marketing',
        ]);
    }

    /**
     * Test registration failure with existing email.
     */
    public function test_user_cannot_register_with_existing_email(): void
    {
        User::factory()->create(['email' => 'karyawan@demo.com']);

        $response = $this->postJson('/api/auth/register', [
            'name' => 'Karyawan Demo',
            'email' => 'karyawan@demo.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'position' => 'Staff Marketing',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }

    /**
     * Test successful login.
     */
    public function test_user_can_login_with_valid_credentials(): void
    {
        $user = User::factory()->create([
            'email' => 'budi@kantor.com',
            'password' => Hash::make('password123'),
            'position' => 'Staff IT',
        ]);

        $response = $this->postJson('/api/auth/login', [
            'email' => 'budi@kantor.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'token',
                    'user' => ['id', 'name', 'email', 'position'],
                ],
            ])
            ->assertJsonPath('data.user.email', 'budi@kantor.com');
    }

    /**
     * Test login failure with invalid credentials.
     */
    public function test_user_cannot_login_with_invalid_credentials(): void
    {
        User::factory()->create([
            'email' => 'budi@kantor.com',
            'password' => Hash::make('password123'),
        ]);

        $response = $this->postJson('/api/auth/login', [
            'email' => 'budi@kantor.com',
            'password' => 'wrongpassword',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['credentials']);
    }

    /**
     * Test login failure with non-existent email.
     */
    public function test_user_cannot_login_with_non_existent_email(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'nonexistent@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['credentials']);
    }

    /**
     * Test accessing protected route without token.
     */
    public function test_cannot_access_protected_route_without_token(): void
    {
        $response = $this->getJson('/api/users/current');

        $response->assertStatus(401);
    }

    /**
     * Test getting current user profile.
     */
    public function test_user_can_get_current_profile(): void
    {
        $user = User::factory()->create([
            'position' => 'Staff IT',
        ]);

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/users/current');

        $response->assertStatus(200)
            ->assertJsonPath('data.email', $user->email)
            ->assertJsonPath('data.position', 'Staff IT');
    }

    /**
     * Test logout.
     */
    public function test_user_can_logout(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $response = $this->deleteJson('/api/auth/logout');

        $response->assertStatus(200)
            ->assertJsonPath('success', true);

        $this->assertCount(0, $user->tokens);
    }
}
