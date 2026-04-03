<?php

namespace App\Filament\Resources\Users\RelationManagers;

use Filament\Actions\AssociateAction;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\CreateAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\DissociateAction;
use Filament\Actions\DissociateBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\TimePicker;
use Filament\Infolists\Components\TextEntry;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class AttendancesRelationManager extends RelationManager
{
    protected static string $relationship = 'attendances';

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                DatePicker::make('date')
                    ->required(),
                TimePicker::make('check_in_time')
                    ->required(),
                TextInput::make('check_in_latitude')
                    ->required(),
                TextInput::make('check_in_longitude')
                    ->required(),
                TextInput::make('check_in_foto')
                    ->required(),
                TimePicker::make('check_out_time'),
                TextInput::make('check_out_latitude'),
                TextInput::make('check_out_longitude'),
                TextInput::make('check_out_foto'),
                TextInput::make('status')
                    ->required(),
            ]);
    }

    public function infolist(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('date')
                    ->date(),
                TextEntry::make('check_in_time')
                    ->time(),
                TextEntry::make('check_in_latitude'),
                TextEntry::make('check_in_longitude'),
                TextEntry::make('check_in_foto'),
                TextEntry::make('check_out_time')
                    ->time()
                    ->placeholder('-'),
                TextEntry::make('check_out_latitude')
                    ->placeholder('-'),
                TextEntry::make('check_out_longitude')
                    ->placeholder('-'),
                TextEntry::make('check_out_foto')
                    ->placeholder('-'),
                TextEntry::make('status'),
                TextEntry::make('created_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('updated_at')
                    ->dateTime()
                    ->placeholder('-'),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('date')
            ->columns([
                TextColumn::make('date')
                    ->date()
                    ->sortable(),
                TextColumn::make('check_in_time')
                    ->time()
                    ->sortable(),
                TextColumn::make('check_in_latitude')
                    ->searchable(),
                TextColumn::make('check_in_longitude')
                    ->searchable(),
                TextColumn::make('check_in_foto')
                    ->searchable(),
                TextColumn::make('check_out_time')
                    ->time()
                    ->sortable(),
                TextColumn::make('check_out_latitude')
                    ->searchable(),
                TextColumn::make('check_out_longitude')
                    ->searchable(),
                TextColumn::make('check_out_foto')
                    ->searchable(),
                TextColumn::make('status')
                    ->searchable(),
                TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('updated_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                //
            ])
            ->headerActions([
                CreateAction::make(),
                AssociateAction::make(),
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
                DissociateAction::make(),
                DeleteAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DissociateBulkAction::make(),
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
