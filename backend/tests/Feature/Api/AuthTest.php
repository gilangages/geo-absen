<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
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
        $user = User::factory()->create([
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
     * Test user can update profile name and email.
     */
    public function test_user_can_update_profile_info(): void
    {
        $user = User::factory()->create(['name' => 'Old Name']);
        Sanctum::actingAs($user);

        $response = $this->patchJson('/api/users/current', [
            'name' => 'New Name',
            'email' => 'newemail@example.com',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('data.name', 'New Name')
            ->assertJsonPath('data.email', 'newemail@example.com');

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'name' => 'New Name',
        ]);
    }

    /**
     * Test user can update avatar.
     */
    public function test_user_can_update_avatar(): void
    {
        Storage::fake('public');
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $file = UploadedFile::fake()->image('new_avatar.jpg');

        $response = $this->patchJson('/api/users/current', [
            'name' => $user->name,
            'email' => $user->email,
            'avatar' => $file,
        ]);

        $response->assertStatus(200);

        $user->refresh();
        $this->assertNotNull($user->avatar);
        Storage::disk('public')->assertExists($user->avatar);
    }

    /**
     * Test user can update password.
     */
    public function test_user_can_update_password(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $response = $this->patchJson('/api/users/current', [
            'name' => $user->name,
            'email' => $user->email,
            'password' => 'newpassword123',
            'password_confirmation' => 'newpassword123',
        ]);

        $response->assertStatus(200);

        $user->refresh();
        $this->assertTrue(Hash::check('newpassword123', $user->password));
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
