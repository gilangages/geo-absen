<?php

namespace App\Services;

use App\Models\Office;

class OfficeService
{
    /**
     * Ambil data kantor (untuk sekarang diasumsikan hanya ada 1 kantor pusat).
     */
    public function getOffice(): ?Office
    {
        return Office::first();
    }

    /**
     * Update atau buat data kantor baru.
     */
    public function updateOrCreate(array $data): Office
    {
        return Office::updateOrCreate(
            ['id' => 1], // Mengunci ke ID 1 agar hanya ada 1 settingan kantor pusat
            $data
        );
    }

    /**
     * Cek apakah koordinat user berada di dalam radius kantor.
     * Menggunakan rumus Haversine.
     */
    public function isWithinRadius(string $userLat, string $userLong): bool
    {
        $office = $this->getOffice();

        // Jika data kantor belum diset oleh Admin, kita izinkan absen (fallback)
        if (! $office) {
            return true;
        }

        $distance = $this->calculateDistance(
            (float) $userLat,
            (float) $userLong,
            (float) $office->latitude,
            (float) $office->longitude
        );

        return $distance <= $office->radius;
    }

    /**
     * Menghitung jarak antara dua titik koordinat (dalam satuan Meter).
     */
    private function calculateDistance(float $lat1, float $lon1, float $lat2, float $lon2): float
    {
        $earthRadius = 6371000; // Radius bumi dalam meter

        $latFrom = deg2rad($lat1);
        $lonFrom = deg2rad($lon1);
        $latTo = deg2rad($lat2);
        $lonTo = deg2rad($lon2);

        $latDelta = $latTo - $latFrom;
        $lonDelta = $lonTo - $lonFrom;

        $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) +
            cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));

        return $angle * $earthRadius;
    }
}
