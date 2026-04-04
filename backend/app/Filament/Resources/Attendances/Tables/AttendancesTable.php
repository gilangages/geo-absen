<?php

namespace App\Filament\Resources\Attendances\Tables;

use Filament\Actions\Action;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\ViewAction;
use Filament\Infolists\Components\ImageEntry;
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
                    ->disk('public')
                    ->circular()
                    ->action(
                        Action::make('preview_in')
                            ->modalHeading('Preview Foto Masuk')
                            ->modalSubmitAction(false)
                            ->modalCancelActionLabel('Tutup')
                            ->schema([
                                ImageEntry::make('check_in_foto')
                                    ->label('')
                                    ->disk('public')
                                    ->width('100%')
                                    ->height('auto') // Biar tingginya mengikuti asli
                                    ->extraImgAttributes([
                                        'style' => 'object-fit: contain; max-height: 80vh; width: 100%;',
                                    ]), // object-fit: contain agar tidak kepotong
                            ])
                    ),
                TextColumn::make('check_out_time')
                    ->label('Pulang')
                    ->time()
                    ->sortable()
                    ->placeholder('-'),
                ImageColumn::make('check_out_foto')
                    ->label('Foto Pulang')
                    ->disk('public')
                    ->circular()
                    ->action(
                        Action::make('preview_out')
                            ->modalHeading('Preview Foto Pulang')
                            ->modalSubmitAction(false)
                            ->modalCancelActionLabel('Tutup')
                            ->schema([
                                ImageEntry::make('check_out_foto')
                                    ->label('')
                                    ->disk('public')
                                    ->width('100%')
                                    ->height('auto')
                                    ->extraImgAttributes([
                                        'style' => 'object-fit: contain; max-height: 80vh; width: 100%;',
                                    ]),
                            ])
                    ),
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
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
