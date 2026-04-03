<?php

namespace Tests\Unit\Services;

use App\Models\Office;
use App\Models\User;
use App\Services\AttendanceService;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class AttendanceServiceTest extends TestCase
{
    use RefreshDatabase;

    protected AttendanceService $service;

    protected User $user;

    protected function setUp(): void
    {
        parent::setUp();
        // Gunakan Service Container agar OfficeService otomatis ter-inject
        $this->service = app(AttendanceService::class);
        $this->user = User::factory()->create();
        Storage::fake('public');

        // Buat data kantor dummy untuk bypass geofencing di unit test ini
        Office::create([
            'name' => 'Kantor Test',
            'latitude' => '0',
            'longitude' => '0',
            'radius' => 1000, // Radius besar agar koordinat 0,0 selalu masuk
        ]);
    }

    /**
     * Test status is 'present' when check-in before 08:00.
     */
    public function test_status_is_present_before_eight_am(): void
    {
        Carbon::setTestNow(Carbon::parse('2026-04-02 07:59:59'));

        $data = [
            'type' => 'in',
            'latitude' => '0',
            'longitude' => '0',
            'foto_selfie' => UploadedFile::fake()->image('selfie.jpg'),
        ];

        $this->service->store($this->user, $data);

        $this->assertDatabaseHas('attendances', [
            'user_id' => $this->user->id,
            'status' => 'present',
        ]);
    }

    /**
     * Test status is 'late' when check-in after 08:00.
     */
    public function test_status_is_late_after_eight_am(): void
    {
        Carbon::setTestNow(Carbon::parse('2026-04-02 08:00:01'));

        $data = [
            'type' => 'in',
            'latitude' => '0',
            'longitude' => '0',
            'foto_selfie' => UploadedFile::fake()->image('selfie.jpg'),
        ];

        $this->service->store($this->user, $data);

        $this->assertDatabaseHas('attendances', [
            'user_id' => $this->user->id,
            'status' => 'late',
        ]);
    }
}
