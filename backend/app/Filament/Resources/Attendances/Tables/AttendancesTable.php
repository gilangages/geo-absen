<?php

namespace App\Filament\Resources\Attendances\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class AttendancesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('user.name')
                    ->label('Karyawan')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('date')
                    ->label('Tanggal')
                    ->date()
                    ->sortable(),
                TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'present' => 'success',
                        'late' => 'danger',
                        default => 'gray',
                    }),
                TextColumn::make('check_in_time')
                    ->label('Masuk')
                    ->time()
                    ->sortable(),
                ImageColumn::make('check_in_foto')
                    ->label('Foto Masuk')
                    ->disk('public') // Explicitly use public disk
                    ->circular(),
                TextColumn::make('check_out_time')
                    ->label('Pulang')
                    ->time()
                    ->sortable()
                    ->placeholder('-'),
                ImageColumn::make('check_out_foto')
                    ->label('Foto Pulang')
                    ->disk('public') // Explicitly use public disk
                    ->circular(),
                TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('user_id')
                    ->label('Filter Karyawan')
                    ->relationship('user', 'name'),
                SelectFilter::make('status')
                    ->options([
                        'present' => 'Hadir',
                        'late' => 'Terlambat',
                    ]),
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
