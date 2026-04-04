<?php

namespace App\Filament\Resources\Leaves\Tables;

use Filament\Actions\Action;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\Textarea;
use Filament\Infolists\Components\ImageEntry;
use Filament\Notifications\Notification;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class LeavesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('user.name')
                    ->label('Karyawan')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('type')
                    ->label('Jenis Izin')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'sakit' => 'danger',
                        'izin' => 'warning',
                        'cuti' => 'info',
                        default => 'gray',
                    }),
                TextColumn::make('start_date')
                    ->label('Mulai')
                    ->date()
                    ->sortable(),
                TextColumn::make('end_date')
                    ->label('Selesai')
                    ->date()
                    ->sortable(),
                TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'warning',
                        'approved' => 'success',
                        'rejected' => 'danger',
                        default => 'gray',
                    }),
                ImageColumn::make('image_proof')
                    ->label('Bukti')
                    ->disk('public')
                    ->circular()
                    ->action(
                        Action::make('preview_proof')
                            ->modalHeading('Preview Foto Bukti')
                            ->modalSubmitAction(false)
                            ->modalCancelActionLabel('Tutup')
                            ->schema([
                                ImageEntry::make('image_proof')
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
                    ->label('Karyawan')
                    ->relationship('user', 'name'),
                SelectFilter::make('type')
                    ->options([
                        'sakit' => 'Sakit',
                        'izin' => 'Izin',
                        'cuti' => 'Cuti',
                    ]),
                SelectFilter::make('status')
                    ->options([
                        'pending' => 'Pending',
                        'approved' => 'Approved',
                        'rejected' => 'Rejected',
                    ]),
            ])
            ->recordActions([
                // TOMBOL APPROVE CEPAT
                Action::make('approve')
                    ->label('Setujui')
                    ->color('success')
                    ->icon('heroicon-m-check-circle')
                    ->visible(fn ($record) => $record->status === 'pending')
                    ->requiresConfirmation()
                    ->action(function ($record) {
                        $record->update(['status' => 'approved']);

                        Notification::make()
                            ->title('Izin Disetujui')
                            ->success()
                            ->send();
                    }),

                // TOMBOL REJECT CEPAT (DENGAN MODAL CATATAN)
                Action::make('reject')
                    ->label('Tolak')
                    ->color('danger')
                    ->icon('heroicon-m-x-circle')
                    ->visible(fn ($record) => $record->status === 'pending')
                    ->form([
                        Textarea::make('note_admin')
                            ->label('Alasan Penolakan')
                            ->required(),
                    ])
                    ->action(function ($record, array $data) {
                        $record->update([
                            'status' => 'rejected',
                            'note_admin' => $data['note_admin'],
                        ]);

                        Notification::make()
                            ->title('Izin Ditolak')
                            ->danger()
                            ->send();
                    }),

                ViewAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
