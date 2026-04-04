<?php

namespace App\Filament\Resources\Leaves\Schemas;

use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class LeaveInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Informasi Karyawan')
                    ->schema([
                        Grid::make(3)
                            ->schema([
                                TextEntry::make('user.name')
                                    ->label('Nama Karyawan')
                                    ->weight('bold'),
                                TextEntry::make('type')
                                    ->label('Jenis Izin')
                                    ->badge()
                                    ->color(fn (string $state): string => match ($state) {
                                        'sakit' => 'danger',
                                        'izin' => 'warning',
                                        'cuti' => 'info',
                                        default => 'gray',
                                    }),
                                TextEntry::make('status')
                                    ->label('Status Persetujuan')
                                    ->badge()
                                    ->color(fn (string $state): string => match ($state) {
                                        'pending' => 'warning',
                                        'approved' => 'success',
                                        'rejected' => 'danger',
                                        default => 'gray',
                                    }),
                            ]),
                    ]),

                Section::make('Detail Waktu & Alasan')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                TextEntry::make('start_date')
                                    ->label('Tanggal Mulai')
                                    ->date(),
                                TextEntry::make('end_date')
                                    ->label('Tanggal Selesai')
                                    ->date(),
                                TextEntry::make('reason')
                                    ->label('Alasan Pengajuan')
                                    ->columnSpanFull(),
                            ]),
                    ]),

                Section::make('Foto Bukti')
                    ->schema([
                        ImageEntry::make('image_proof')
                            ->label('')
                            ->disk('public')
                            ->width('100%')
                            ->extraImgAttributes([
                                'style' => 'width: 100%; height: auto; border-radius: 12px; border: 1px solid #ddd;',
                            ]),
                    ]),

                Section::make('Catatan Admin')
                    ->visible(fn ($record) => $record->note_admin !== null || $record->status !== 'pending')
                    ->schema([
                        TextEntry::make('note_admin')
                            ->label('Komentar/Catatan HR')
                            ->placeholder('Tidak ada catatan.')
                            ->columnSpanFull(),
                    ]),
            ]);
    }
}
