<?php

namespace Tests\Unit\Services;

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
        $this->service = new AttendanceService();
        $this->user = User::factory()->create();
        Storage::fake('public');
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

        $result = $this->service->store($this->user, $data);

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

        $result = $this->service->store($this->user, $data);

        $this->assertDatabaseHas('attendances', [
            'user_id' => $this->user->id,
            'status' => 'late',
        ]);
    }
}
