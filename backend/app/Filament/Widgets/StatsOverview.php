<?php

namespace App\Filament\Widgets;

use App\Models\Attendance;
use App\Models\User;
use Carbon\Carbon;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends StatsOverviewWidget
{
    protected function getStats(): array
    {
        $today = Carbon::today()->toDateString();
        
        return [
            Stat::make('Total Karyawan', User::count())
                ->description('Total karyawan terdaftar')
                ->descriptionIcon('heroicon-m-users')
                ->color('info'),

            Stat::make('Hadir Hari Ini', Attendance::where('date', $today)->count())
                ->description('Jumlah karyawan yang sudah absen')
                ->descriptionIcon('heroicon-m-check-circle')
                ->color('success'),

            Stat::make('Terlambat Hari Ini', Attendance::where('date', $today)->where('status', 'late')->count())
                ->description('Karyawan yang masuk setelah jam 08:00')
                ->descriptionIcon('heroicon-m-clock')
                ->color('danger'),
        ];
    }
}
