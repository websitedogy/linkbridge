<?php

namespace App\Features\Registry\Filament\Resources\RegistrySubmissions;

use App\Features\Companies\Enums\CompanyType;
use App\Features\Registry\Enums\RegistrySubmissionStatus;
use App\Features\Registry\Filament\Resources\RegistrySubmissions\Pages\ListRegistrySubmissions;
use App\Features\Registry\Filament\Resources\RegistrySubmissions\Pages\ViewRegistrySubmission;
use App\Features\Registry\Models\RegistrySubmission;
use BackedEnum;
use Filament\Actions\ViewAction;
use Filament\Infolists\Components\TextEntry;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class RegistrySubmissionResource extends Resource
{
    protected static ?string $model = RegistrySubmission::class;

    protected static ?string $recordTitleAttribute = 'company_name';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedIdentification;

    protected static ?string $navigationLabel = 'Registry CIN';

    protected static ?string $modelLabel = 'Registry CIN';

    protected static ?string $pluralModelLabel = 'Registry CIN';

    protected static ?int $navigationSort = 2;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->with('user');
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit(Model $record): bool
    {
        return false;
    }

    public static function canDelete(Model $record): bool
    {
        return false;
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Submitted by')
                    ->schema([
                        TextEntry::make('user.name')->label('Name'),
                        TextEntry::make('user.email')->label('Email'),
                        TextEntry::make('user.mobile')->label('Mobile'),
                    ])
                    ->columns(3),
                Section::make('Company')
                    ->schema([
                        TextEntry::make('company_type')
                            ->label('Company Type')
                            ->formatStateUsing(fn (CompanyType $state): string => $state->label()),
                        TextEntry::make('company_name')->label('Company Name'),
                        TextEntry::make('cin')->label('CIN no.')->placeholder('Not provided'),
                        TextEntry::make('director_contact')->label('Director contact number'),
                        TextEntry::make('director_email')->label('Director mail id'),
                        TextEntry::make('location')->label('Current location'),
                        TextEntry::make('status')
                            ->label('Status')
                            ->badge()
                            ->formatStateUsing(fn (RegistrySubmissionStatus $state): string => $state->label())
                            ->color('warning'),
                        TextEntry::make('created_at')->label('Submitted at')->dateTime(),
                    ])
                    ->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('company_name')
                    ->label('Company Name')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('company_type')
                    ->label('Company Type')
                    ->formatStateUsing(fn (CompanyType $state): string => $state->label())
                    ->sortable(),
                TextColumn::make('cin')
                    ->label('CIN'),
                TextColumn::make('user.name')
                    ->label('Submitted by')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('user.email')
                    ->label('Submitter email')
                    ->searchable(),
                TextColumn::make('user.mobile')
                    ->label('Submitter mobile')
                    ->searchable(),
                TextColumn::make('status')
                    ->badge()
                    ->formatStateUsing(fn (RegistrySubmissionStatus $state): string => $state->label())
                    ->color('warning'),
                TextColumn::make('created_at')
                    ->label('Submitted')
                    ->dateTime()
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->recordActions([
                ViewAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListRegistrySubmissions::route('/'),
            'view' => ViewRegistrySubmission::route('/{record}'),
        ];
    }
}
