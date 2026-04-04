<?php

namespace App\Services;

use App\Models\Attendance;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Validation\ValidationException;

class AttendanceService
{
    public function __construct(
        protected OfficeService $officeService,
        protected LeaveService $leaveService
    ) {
    }

    /**
     * Store a new attendance record (Check-In or Check-Out).
     *
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    public function store(User $user, array $data): array
    {
        $today = Carbon::today()->toDateString();
        $now = Carbon::now();
        $type = $data['type'];

        // Cek apakah sedang dalam masa izin/cuti
        if ($this->leaveService->isCurrentlyOnLeave($user)) {
            throw ValidationException::withMessages([
                'attendance' => ['Anda sedang dalam masa izin/cuti. Absensi tidak diizinkan.'],
            ]);
        }

        // Cek Geofencing (Radius Kantor)
        if (! $this->officeService->isWithinRadius($data['latitude'], $data['longitude'])) {
            throw ValidationException::withMessages([
                'attendance' => ['Anda berada di luar radius kantor yang diizinkan.'],
            ]);
        }

        // Ambil data kantor untuk cek jam kerja
        $office = $this->officeService->getOffice();

        // Get existing record for today
        $attendance = Attendance::where('user_id', $user->id)
            ->where('date', $today)
            ->first();

        if ($type === 'in') {
            if ($attendance) {
                throw ValidationException::withMessages([
                    'attendance' => ['Anda sudah melakukan check-in hari ini.'],
                ]);
            }

            $path = $data['foto_selfie']->store('attendances', 'public');

            // Logika penentuan status (terlambat jika lewat dari work_start)
            $status = 'present';
            if ($office && $now->toTimeString() > $office->work_start) {
                $status = 'late';
            }

            $attendance = Attendance::create([
                'user_id' => $user->id,
                'date' => $today,
                'check_in_time' => $now->toTimeString(),
                'check_in_latitude' => $data['latitude'],
                'check_in_longitude' => $data['longitude'],
                'check_in_foto' => $path,
                'status' => $status,
            ]);

            return $this->formatResponse($attendance, 'in');
        }

        if ($type === 'out') {
            if (! $attendance) {
                throw ValidationException::withMessages([
                    'attendance' => ['Silakan lakukan check-in terlebih dahulu.'],
                ]);
            }

            if ($attendance->check_out_time) {
                throw ValidationException::withMessages([
                    'attendance' => ['Anda sudah melakukan check-out hari ini.'],
                ]);
            }

            $path = $data['foto_selfie']->store('attendances', 'public');

            $attendance->update([
                'check_out_time' => $now->toTimeString(),
                'check_out_latitude' => $data['latitude'],
                'check_out_longitude' => $data['longitude'],
                'check_out_foto' => $path,
            ]);

            return $this->formatResponse($attendance, 'out');
        }

        throw ValidationException::withMessages([
            'type' => ['Jenis absen tidak valid.'],
        ]);
    }

    /**
     * Get attendance status for today.
     */
    public function getTodayStatus(User $user): array
    {
        $today = Carbon::today()->toDateString();
        $attendance = Attendance::where('user_id', $user->id)
            ->where('date', $today)
            ->first();

        $leave = $this->leaveService->isCurrentlyOnLeave($user);
        $office = $this->officeService->getOffice();

        return [
            'is_checked_in' => (bool) $attendance,
            'is_checked_out' => $attendance && (bool) $attendance->check_out_time,
            'check_in_time' => $attendance ? $attendance->check_in_time : null,
            'check_out_time' => ($attendance && $attendance->check_out_time) ? $attendance->check_out_time : null,
            'work_start' => $office ? $office->work_start : '08:00:00',
            'work_end' => $office ? $office->work_end : '17:00:00',
            'is_on_leave' => (bool) $leave,
            'leave_details' => $leave ? [
                'type' => $leave->type,
                'reason' => $leave->reason,
                'end_date' => $leave->end_date,
            ] : null,
        ];
    }

    /**
     * Get attendance history for the user.
     */
    public function getHistory(User $user, ?string $month = null, ?string $year = null): array
    {
        $query = Attendance::where('user_id', $user->id)->latest('date');

        if ($month) {
            $query->whereMonth('date', $month);
        } else {
            $query->whereMonth('date', Carbon::now()->month);
        }

        if ($year) {
            $query->whereYear('date', $year);
        } else {
            $query->whereYear('date', Carbon::now()->year);
        }

        return $query->get()->map(function ($item) {
            return [
                'id' => $item->id,
                'date' => $item->date,
                'check_in_time' => $item->check_in_time,
                'check_out_time' => $item->check_out_time,
                'status' => $item->status,
            ];
        })->toArray();
    }

    /**
     * Format response for store action.
     */
    private function formatResponse(Attendance $attendance, string $type): array
    {
        $isOut = $type === 'out';

        return [
            'id' => $attendance->id,
            'type' => $type,
            'time' => $attendance->date.' '.($isOut ? $attendance->check_out_time : $attendance->check_in_time),
            'latitude' => $isOut ? $attendance->check_out_latitude : $attendance->check_in_latitude,
            'longitude' => $isOut ? $attendance->check_out_longitude : $attendance->check_in_longitude,
            'foto_url' => asset('storage/'.($isOut ? $attendance->check_out_foto : $attendance->check_in_foto)),
        ];
    }
}
