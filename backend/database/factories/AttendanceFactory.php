<?php

namespace Database\Factories;

use App\Models\Attendance;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Attendance>
 */
class AttendanceFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'date' => Carbon::today()->toDateString(),
            'check_in_time' => '07:30:00',
            'check_in_latitude' => fake()->latitude(),
            'check_in_longitude' => fake()->longitude(),
            'check_in_foto' => 'attendances/fake_in.jpg',
            'status' => 'present',
        ];
    }
}
