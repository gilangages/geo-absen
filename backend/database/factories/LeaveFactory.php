<?php

namespace Database\Factories;

use App\Models\Leave;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Leave>
 */
class LeaveFactory extends Factory
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
            'type' => 'izin',
            'start_date' => Carbon::today()->toDateString(),
            'end_date' => Carbon::tomorrow()->toDateString(),
            'reason' => fake()->sentence(),
            'image_proof' => 'leaves/fake_proof.jpg',
            'status' => 'pending',
        ];
    }
}
