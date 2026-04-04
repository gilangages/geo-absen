<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Leave\StoreLeaveRequest;
use App\Services\LeaveService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LeaveController extends Controller
{
    public function __construct(protected LeaveService $leaveService)
    {
    }

    /**
     * Menampilkan daftar riwayat izin user.
     */
    public function index(Request $request): JsonResponse
    {
        $data = $this->leaveService->getHistory($request->user());

        return response()->json([
            'success' => true,
            'message' => 'Riwayat izin berhasil diambil.',
            'data' => $data,
        ]);
    }

    /**
     * Mengirim pengajuan izin baru.
     */
    public function store(StoreLeaveRequest $request): JsonResponse
    {
        $leave = $this->leaveService->store($request->user(), $request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan izin berhasil dikirim.',
            'data' => [
                'id' => $leave->id,
                'status' => $leave->status,
            ],
        ], 201);
    }
}
