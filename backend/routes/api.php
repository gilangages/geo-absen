<?php

use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\LeaveController;
use Illuminate\Support\Facades\Route;

// Public routes
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // User / Auth
    Route::delete('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/users/current', [AuthController::class, 'current']);
    Route::patch('/users/current', [AuthController::class, 'updateProfile']);

    // Attendances
    Route::get('/attendances', [AttendanceController::class, 'index']);
    Route::post('/attendances', [AttendanceController::class, 'store']);
    Route::get('/attendances/today', [AttendanceController::class, 'today']);

    // Leaves
    Route::get('/leaves', [LeaveController::class, 'index']);
    Route::post('/leaves', [LeaveController::class, 'store']);
});
