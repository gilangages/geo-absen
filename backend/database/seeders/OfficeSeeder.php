<?php

namespace Database\Seeders;

use App\Models\Office;
use Illuminate\Database\Seeder;

class OfficeSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Office::updateOrCreate(
            ['id' => 1],
            [
                'name' => 'Kantor Demo Pusat',
                'latitude' => '-6.175392', // Monas, Jakarta
                'longitude' => '106.827153',
                'radius' => 20000000, // 20.000 KM (Mencakup seluruh dunia agar demo lancar)
                'work_start' => '08:00:00',
                'work_end' => '17:00:00',
            ]
        );
    }
}
