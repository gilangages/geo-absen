<?php

namespace Tests\Feature\Api;

use App\Models\Attendance;
use App\Models\Office;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AttendanceTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Buat data kantor agar geofencing lolos saat testing
        Office::create([
            'name' => 'Kantor Test',
            'latitude' => '-6.200000',
            'longitude' => '106.816666',
            'radius' => 100,
        ]);

        $this->user = User::factory()->create();
        Sanctum::actingAs($this->user);
        Storage::fake('public');
    }

    /**
     * Test successful check-in.
     */
    public function test_user_can_check_in(): void
    {
        $file = UploadedFile::fake()->image('selfie_in.jpg');

        $response = $this->postJson('/api/attendances', [
            'type' => 'in',
            'latitude' => '-6.200000',
            'longitude' => '106.816666',
            'foto_selfie' => $file,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.type', 'in');

        $this->assertDatabaseHas('attendances', [
            'user_id' => $this->user->id,
            'date' => Carbon::today()->toDateString(),
        ]);

        Storage::disk('public')->assertExists('attendances/'.$file->hashName());
    }

    /**
     * Test successful check-out.
     */
    public function test_user_can_check_out(): void
    {
        // Pre-create check-in for today
        Attendance::factory()->create([
            'user_id' => $this->user->id,
            'date' => Carbon::today()->toDateString(),
            'check_out_time' => null,
        ]);

        $file = UploadedFile::fake()->image('selfie_out.jpg');

        $response = $this->postJson('/api/attendances', [
            'type' => 'out',
            'latitude' => '-6.200000',
            'longitude' => '106.816666',
            'foto_selfie' => $file,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.type', 'out');

        $attendance = Attendance::where('user_id', $this->user->id)
            ->where('date', Carbon::today()->toDateString())
            ->first();

        $this->assertNotNull($attendance->check_out_time);
        Storage::disk('public')->assertExists('attendances/'.$file->hashName());
    }

    /**
     * Test cannot check-in twice.
     */
    public function test_user_cannot_check_in_twice(): void
    {
        Attendance::factory()->create([
            'user_id' => $this->user->id,
            'date' => Carbon::today()->toDateString(),
        ]);

        $file = UploadedFile::fake()->image('selfie_in.jpg');

        $response = $this->postJson('/api/attendances', [
            'type' => 'in',
            'latitude' => '-6.200000',
            'longitude' => '106.816666',
            'foto_selfie' => $file,
        ]);

        $response->assertStatus(422)
            ->assertJsonFragment(['Anda sudah melakukan check-in hari ini.']);
    }

    /**
     * Test cannot check-out before check-in.
     */
    public function test_user_cannot_check_out_without_check_in(): void
    {
        $file = UploadedFile::fake()->image('selfie_out.jpg');

        $response = $this->postJson('/api/attendances', [
            'type' => 'out',
            'latitude' => '-6.200000',
            'longitude' => '106.816666',
            'foto_selfie' => $file,
        ]);

        $response->assertStatus(422)
            ->assertJsonFragment(['Silakan lakukan check-in terlebih dahulu.']);
    }

    /**
     * Test get today status.
     */
    public function test_user_can_get_today_status(): void
    {
        Attendance::factory()->create([
            'user_id' => $this->user->id,
            'date' => Carbon::today()->toDateString(),
            'check_in_time' => '08:00:00',
            'check_out_time' => null,
        ]);

        $response = $this->getJson('/api/attendances/today');

        $response->assertStatus(200)
            ->assertJsonPath('data.is_checked_in', true)
            ->assertJsonPath('data.is_checked_out', false);
    }

    /**
     * Test get history with filters.
     */
    public function test_user_can_get_history(): void
    {
        Attendance::factory()->create([
            'user_id' => $this->user->id,
            'date' => '2026-04-01',
        ]);

        $response = $this->getJson('/api/attendances?month=04&year=2026');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data');
    }

    /**
     * Test validation error for missing fields.
     */
    public function test_attendance_requires_all_fields(): void
    {
        $response = $this->postJson('/api/attendances', []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['type', 'latitude', 'longitude', 'foto_selfie']);
    }

    /**
     * Test validation error for invalid attendance type.
     */
    public function test_attendance_requires_valid_type(): void
    {
        $response = $this->postJson('/api/attendances', [
            'type' => 'invalid_type',
            'latitude' => '-6.2',
            'longitude' => '106.8',
            'foto_selfie' => UploadedFile::fake()->image('selfie.jpg'),
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['type']);
    }

    /**
     * Test validation error for invalid file type.
     */
    public function test_attendance_requires_image_file(): void
    {
        $file = UploadedFile::fake()->create('document.pdf', 100);

        $response = $this->postJson('/api/attendances', [
            'type' => 'in',
            'latitude' => '-6.2',
            'longitude' => '106.8',
            'foto_selfie' => $file,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['foto_selfie']);
    }
}
