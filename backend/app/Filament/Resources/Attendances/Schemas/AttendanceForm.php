<?php

namespace App\Filament\Resources\Attendances\Schemas;

use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\TimePicker;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class AttendanceForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Karyawan & Tanggal')
                    ->schema([
                        Select::make('user_id')
                            ->relationship('user', 'name')
                            ->searchable()
                            ->preload()
                            ->required(),
                        DatePicker::make('date')
                            ->default(now())
                            ->required(),
                        Select::make('status')
                            ->options([
                                'present' => 'Hadir',
                                'late' => 'Terlambat',
                            ])
                            ->required(),
                    ])->columns(3),

                Section::make('Check-In')
                    ->schema([
                        TimePicker::make('check_in_time')
                            ->required(),
                        TextInput::make('check_in_latitude')
                            ->required(),
                        TextInput::make('check_in_longitude')
                            ->required(),
                        FileUpload::make('check_in_foto')
                            ->image()
                            ->disk('public') // Explicitly use public disk
                            ->directory('attendances')
                            ->required(),
                    ])->columns(2),

                Section::make('Check-Out')
                    ->schema([
                        TimePicker::make('check_out_time'),
                        TextInput::make('check_out_latitude'),
                        TextInput::make('check_out_longitude'),
                        FileUpload::make('check_out_foto')
                            ->image()
                            ->disk('public') // Explicitly use public disk
                            ->directory('attendances'),
                    ])->columns(2),
            ]);
    }
}
