<?php

namespace App\Filament\Resources\Offices\Schemas;

use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class OfficeForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Konfigurasi Lokasi Kantor')
                    ->description('Tentukan koordinat pusat kantor dan radius jangkauan absensi.')
                    ->schema([
                        TextInput::make('name')
                            ->label('Nama Kantor')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('Contoh: Kantor Pusat Jakarta'),

                        TextInput::make('latitude')
                            ->label('Latitude')
                            ->required()
                            ->placeholder('Contoh: -6.175392'),

                        TextInput::make('longitude')
                            ->label('Longitude')
                            ->required()
                            ->placeholder('Contoh: 106.827153'),

                        TextInput::make('radius')
                            ->label('Radius Jarak')
                            ->numeric()
                            ->required()
                            ->suffix('Meter')
                            ->helperText('Karyawan hanya bisa absen jika berada dalam radius ini dari kantor.')
                            ->default(100),
                    ])->columns(2),
            ]);
    }
}
