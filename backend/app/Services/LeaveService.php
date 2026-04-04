<?php

namespace App\Services;

use App\Models\Leave;
use App\Models\User;
use Carbon\Carbon;

class LeaveService
{
    /**
     * Mengajukan izin/cuti baru.
     */
    public function store(User $user, array $data): Leave
    {
        $path = $data['image_proof']->store('leaves', 'public');

        return Leave::create([
            'user_id' => $user->id,
            'type' => $data['type'],
            'start_date' => $data['start_date'],
            'end_date' => $data['end_date'],
            'reason' => $data['reason'],
            'image_proof' => $path,
            'status' => 'pending',
        ]);
    }

    /**
     * Mengambil riwayat izin user.
     */
    public function getHistory(User $user)
    {
        return Leave::where('user_id', $user->id)
            ->latest()
            ->get()
            ->map(function ($item) {
                return [
                    'id' => $item->id,
                    'type' => $item->type,
                    'start_date' => $item->start_date,
                    'end_date' => $item->end_date,
                    'reason' => $item->reason,
                    'status' => $item->status,
                    'image_proof_url' => asset('storage/'.$item->image_proof),
                    'note_admin' => $item->note_admin,
                    'created_at' => $item->created_at->format('Y-m-d H:i:s'),
                ];
            });
    }

    /**
     * Cek apakah user sedang dalam masa izin yang sudah disetujui (Approved) hari ini.
     */
    public function isCurrentlyOnLeave(User $user): ?Leave
    {
        $today = Carbon::today()->toDateString();

        return Leave::where('user_id', $user->id)
            ->where('status', 'approved')
            ->where('start_date', '<=', $today)
            ->where('end_date', '>=', $today)
            ->first();
    }
}
