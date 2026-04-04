<?php

namespace App\Filament\Resources\Attendances\Schemas;

use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class AttendanceInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                // BARIS 1: Informasi Karyawan
                Section::make('Informasi Karyawan')
                    ->schema([
                        Grid::make([
                            'default' => 1,
                            'sm' => 3,
                        ])
                            ->schema([
                                TextEntry::make('user.name')
                                    ->label('Nama Karyawan')
                                    ->weight('bold'),
                                TextEntry::make('date')
                                    ->label('Tanggal Absensi')
                                    ->date(),
                                TextEntry::make('status')
                                    ->label('Status Kehadiran')
                                    ->badge()
                                    ->color(fn (string $state): string => match ($state) {
                                        'present' => 'success',
                                        'late' => 'danger',
                                        default => 'gray',
                                    }),
                            ]),
                    ]),

                // BARIS 2: Responsive Grid (1 kolom di HP, 2 kolom di Laptop/LG)
                Grid::make([
                    'default' => 1,
                    'lg' => 2,
                ])
                    ->schema([
                        // Kolom: Check-In
                        Section::make('Data Absen Masuk')
                            ->schema([
                                TextEntry::make('check_in_time')->label('Waktu Masuk')->time()->icon('heroicon-m-clock'),
                                TextEntry::make('check_in_latitude')->label('Latitude')->icon('heroicon-m-map-pin'),
                                TextEntry::make('check_in_longitude')->label('Longitude')->icon('heroicon-m-map-pin'),
                                
                                ImageEntry::make('check_in_foto')
                                    ->label('Foto Selfie Masuk')
                                    ->disk('public')
                                    ->width('100%') 
                                    ->extraImgAttributes([
                                        'style' => 'width: 100%; height: auto; border-radius: 8px; border: 1px solid #ddd;',
                                    ]),
                            ]),

                        // Kolom: Check-Out
                        Section::make('Data Absen Pulang')
                            ->schema([
                                TextEntry::make('check_out_time')->label('Waktu Pulang')->time()->placeholder('Belum Pulang')->icon('heroicon-m-clock'),
                                TextEntry::make('check_out_latitude')->label('Latitude')->placeholder('-')->icon('heroicon-m-map-pin'),
                                TextEntry::make('check_out_longitude')->label('Longitude')->placeholder('-')->icon('heroicon-m-map-pin'),

                                ImageEntry::make('check_out_foto')
                                    ->label('Foto Selfie Pulang')
                                    ->disk('public')
                                    ->width('100%')
                                    ->placeholder('Belum ada foto')
                                    ->extraImgAttributes([
                                        'style' => 'width: 100%; height: auto; border-radius: 8px; border: 1px solid #ddd;',
                                    ]),
                            ]),
                    ]),
            ]);
    }
}
