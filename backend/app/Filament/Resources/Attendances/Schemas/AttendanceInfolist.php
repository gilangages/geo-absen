<?php

namespace App\Filament\Resources\Attendances\Schemas;

use Filament\Infolists\Components\Grid;
use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\Section;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class AttendanceInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Informasi Dasar')
                    ->schema([
                        Grid::make(3)
                            ->schema([
                                TextEntry::make('user.name')
                                    ->label('Nama Karyawan'),
                                TextEntry::make('date')
                                    ->label('Tanggal')
                                    ->date(),
                                TextEntry::make('status')
                                    ->label('Status')
                                    ->badge()
                                    ->color(fn (string $state): string => match ($state) {
                                        'present' => 'success',
                                        'late' => 'danger',
                                        default => 'gray',
                                    }),
                            ]),
                    ]),

                Section::make('Detail Kehadiran')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                // Group Check-In
                                Section::make('Check-In')
                                    ->schema([
                                        TextEntry::make('check_in_time')
                                            ->label('Waktu Masuk')
                                            ->time(),
                                        TextEntry::make('check_in_latitude')
                                            ->label('Latitude'),
                                        TextEntry::make('check_in_longitude')
                                            ->label('Longitude'),
                                        ImageEntry::make('check_in_foto')
                                            ->label('Foto Selfie Masuk')
                                            ->size(200),
                                    ])->columnSpan(1),

                                // Group Check-Out
                                Section::make('Check-Out')
                                    ->schema([
                                        TextEntry::make('check_out_time')
                                            ->label('Waktu Pulang')
                                            ->time()
                                            ->placeholder('Belum Absen Pulang'),
                                        TextEntry::make('check_out_latitude')
                                            ->label('Latitude')
                                            ->placeholder('-'),
                                        TextEntry::make('check_out_longitude')
                                            ->label('Longitude')
                                            ->placeholder('-'),
                                        ImageEntry::make('check_out_foto')
                                            ->label('Foto Selfie Pulang')
                                            ->size(200)
                                            ->placeholder('Belum ada foto'),
                                    ])->columnSpan(1),
                            ]),
                    ]),
            ]);
    }
}
