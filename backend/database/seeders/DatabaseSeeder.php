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
        // 1. Membuat Akun Admin Utama (Ambil dari .env)
        User::updateOrCreate(
            ['email' => env('ADMIN_EMAIL', 'admin@admin.com')],
            [
                'name' => 'Admin Utama',
                'password' => Hash::make(env('ADMIN_PASS', 'password')),
                'position' => 'Administrator',
                'email_verified_at' => now(),
            ]
        );

        // 2. Membuat Akun Karyawan Demo (Siap Pakai untuk Portofolio)
        User::updateOrCreate(
            ['email' => 'karyawan@demo.com'],
            [
                'name' => 'Karyawan Demo',
                'password' => Hash::make('karyawan123'),
                'position' => 'Staff Marketing',
                'email_verified_at' => now(),
            ]
        );

        // 3. Membuat Data Lokasi Kantor Default (Radius Dunia)
        $this->call([
            OfficeSeeder::class,
        ]);
    }
}
