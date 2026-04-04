<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Membuat Akun Admin Utama
        User::updateOrCreate(
            ['email' => env('ADMIN_EMAIL', 'admin@gmail.com')],
            [
                'name' => 'Admin Utama',
                'password' => Hash::make(env('ADMIN_PASS', 'password')),
                'position' => 'Administrator',
                'email_verified_at' => now(),
            ]
        );

        // Jika ingin membuat beberapa user dummy untuk testing, bisa aktifkan baris bawah ini:
        // User::factory(5)->create();
    }
}
