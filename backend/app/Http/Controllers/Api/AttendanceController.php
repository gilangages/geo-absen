<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Attendance\StoreAttendanceRequest;
use App\Services\AttendanceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AttendanceController extends Controller
{
    public function __construct(protected AttendanceService $attendanceService) {}

    /**
     * Get attendance history.
     */
    public function index(Request $request): JsonResponse
    {
        $data = $this->attendanceService->getHistory(
            $request->user(),
            $request->query('month'),
            $request->query('year')
        );

        return response()->json([
            'success' => true,
            'message' => 'Riwayat absensi berhasil diambil.',
            'data' => $data,
        ]);
    }

    /**
     * Store new attendance (Check-in/out).
     */
    public function store(StoreAttendanceRequest $request): JsonResponse
    {
        $data = $this->attendanceService->store($request->user(), $request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Absensi berhasil dicatat.',
            'data' => $data,
        ], 201);
    }

    /**
     * Check today's status.
     */
    public function today(Request $request): JsonResponse
    {
        $data = $this->attendanceService->getTodayStatus($request->user());

        return response()->json([
            'success' => true,
            'message' => 'Status absensi hari ini berhasil diambil.',
            'data' => $data,
        ]);
    }
}
