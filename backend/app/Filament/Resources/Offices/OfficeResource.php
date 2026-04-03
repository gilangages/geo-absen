<?php

namespace App\Filament\Resources\Offices;

use App\Filament\Resources\Offices\Pages\CreateOffice;
use App\Filament\Resources\Offices\Pages\EditOffice;
use App\Filament\Resources\Offices\Pages\ListOffices;
use App\Filament\Resources\Offices\Pages\ViewOffice;
use App\Filament\Resources\Offices\Schemas\OfficeForm;
use App\Filament\Resources\Offices\Schemas\OfficeInfolist;
use App\Filament\Resources\Offices\Tables\OfficesTable;
use App\Models\Office;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class OfficeResource extends Resource
{
    protected static ?string $model = Office::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedMapPin;

    protected static ?string $modelLabel = 'Lokasi Kantor';

    protected static ?string $pluralModelLabel = 'Lokasi Kantor';

    protected static UnitEnum|string|null $navigationGroup = 'Monitoring Kehadiran';

    public static function form(Schema $schema): Schema
    {
        return OfficeForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return OfficeInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return OfficesTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListOffices::route('/'),
            'create' => CreateOffice::route('/create'),
            'view' => ViewOffice::route('/{record}'),
            'edit' => EditOffice::route('/{record}/edit'),
        ];
    }
}
