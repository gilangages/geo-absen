<?php

namespace App\Filament\Resources\Leaves\Schemas;

use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class LeaveForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Informasi Karyawan & Waktu')
                    ->schema([
                        Select::make('user_id')
                            ->relationship('user', 'name')
                            ->searchable()
                            ->preload()
                            ->required(),
                        Select::make('type')
                            ->label('Jenis Izin')
                            ->options([
                                'sakit' => 'Sakit',
                                'izin' => 'Izin',
                                'cuti' => 'Cuti',
                            ])
                            ->required(),
                        DatePicker::make('start_date')
                            ->label('Tanggal Mulai')
                            ->required(),
                        DatePicker::make('end_date')
                            ->label('Tanggal Selesai')
                            ->required(),
                    ])->columns(2),

                Section::make('Detail Pengajuan')
                    ->schema([
                        Textarea::make('reason')
                            ->label('Alasan')
                            ->required()
                            ->columnSpanFull(),
                        FileUpload::make('image_proof')
                            ->label('Foto Bukti (Surat Dokter/Tugas)')
                            ->disk('public')
                            ->directory('leaves')
                            ->image()
                            ->required()
                            ->columnSpanFull(),
                    ]),

                Section::make('Persetujuan Admin')
                    ->description('Bagian ini diisi oleh HR/Admin')
                    ->schema([
                        Select::make('status')
                            ->options([
                                'pending' => 'Pending',
                                'approved' => 'Disetujui',
                                'rejected' => 'Ditolak',
                            ])
                            ->default('pending')
                            ->required(),
                        Textarea::make('note_admin')
                            ->label('Catatan Admin')
                            ->placeholder('Alasan penolakan atau catatan tambahan...')
                            ->columnSpanFull(),
                    ]),
            ]);
    }
}
