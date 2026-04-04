<?php

namespace Tests\Feature\Api;

use App\Models\Leave;
use App\Models\Office;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class LeaveTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
        Sanctum::actingAs($this->user);
        Storage::fake('public');

        // Buat kantor default
        Office::create([
            'name' => 'Kantor Test',
            'latitude' => '0',
            'longitude' => '0',
            'radius' => 100,
        ]);
    }

    /**
     * Test successful leave application.
     */
    public function test_user_can_apply_for_leave(): void
    {
        $file = UploadedFile::fake()->image('proof.jpg');

        $response = $this->postJson('/api/leaves', [
            'type' => 'sakit',
            'start_date' => Carbon::today()->toDateString(),
            'end_date' => Carbon::tomorrow()->toDateString(),
            'reason' => 'Demam tinggi',
            'image_proof' => $file,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.status', 'pending');

        $this->assertDatabaseHas('leaves', [
            'user_id' => $this->user->id,
            'reason' => 'Demam tinggi',
        ]);

        Storage::disk('public')->assertExists('leaves/'.$file->hashName());
    }

    /**
     * Test getting leave history.
     */
    public function test_user_can_get_leave_history(): void
    {
        Leave::factory()->create([
            'user_id' => $this->user->id,
            'type' => 'izin',
        ]);

        $response = $this->getJson('/api/leaves');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.type', 'izin');
    }

    /**
     * Test attendance is blocked when user is on approved leave today.
     */
    public function test_attendance_is_blocked_on_leave_day(): void
    {
        // Buat izin yang sudah approved untuk hari ini
        Leave::factory()->create([
            'user_id' => $this->user->id,
            'status' => 'approved',
            'start_date' => Carbon::today()->toDateString(),
            'end_date' => Carbon::today()->toDateString(),
        ]);

        $response = $this->postJson('/api/attendances', [
            'type' => 'in',
            'latitude' => '0',
            'longitude' => '0',
            'foto_selfie' => UploadedFile::fake()->image('selfie.jpg'),
        ]);

        $response->assertStatus(422)
            ->assertJsonFragment(['Anda sedang dalam masa izin/cuti. Absensi tidak diizinkan.']);
    }

    /**
     * Test today status includes leave information.
     */
    public function test_today_status_shows_leave_info(): void
    {
        Leave::factory()->create([
            'user_id' => $this->user->id,
            'status' => 'approved',
            'start_date' => Carbon::today()->toDateString(),
            'end_date' => Carbon::today()->toDateString(),
            'type' => 'cuti',
        ]);

        $response = $this->getJson('/api/attendances/today');

        $response->assertStatus(200)
            ->assertJsonPath('data.is_on_leave', true)
            ->assertJsonPath('data.leave_details.type', 'cuti');
    }
}
