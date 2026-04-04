<?php

namespace Tests\Feature\Api;

use App\Models\Office;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class GeofencingTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Buat Kantor di Monas, Jakarta
        Office::create([
            'name' => 'Kantor Pusat Monas',
            'latitude' => '-6.175392',
            'longitude' => '106.827153',
            'radius' => 100, // 100 meter
        ]);

        $this->user = User::factory()->create();
        Sanctum::actingAs($this->user);
    }

    /**
     * Test absen berhasil jika user ada di dalam radius.
     */
    public function test_attendance_success_within_radius(): void
    {
        // Koordinat sangat dekat dengan Monas (sekitar 10 meter)
        $response = $this->postJson('/api/attendances', [
            'type' => 'in',
            'latitude' => '-6.175400',
            'longitude' => '106.827160',
            'foto_selfie' => UploadedFile::fake()->image('selfie.jpg'),
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('attendances', ['user_id' => $this->user->id]);
    }

    /**
     * Test absen gagal jika user ada di luar radius.
     */
    public function test_attendance_fails_outside_radius(): void
    {
        // Koordinat jauh dari Monas (misal di Bandung)
        $response = $this->postJson('/api/attendances', [
            'type' => 'in',
            'latitude' => '-6.917464',
            'longitude' => '107.619123',
            'foto_selfie' => UploadedFile::fake()->image('selfie.jpg'),
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['attendance']);
        
        $this->assertDatabaseEmpty('attendances');
    }
}
