<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PDVResource\Pages;
use App\Models\PDV;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\Filter;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Grid;
use Filament\Tables\Actions\Action;
use Filament\Tables\Actions\EditAction;
use Filament\Tables\Actions\DeleteAction;
use Filament\Tables\Actions\ViewAction;

class PDVResource extends Resource
{
    protected static ?string $model = PDV::class;

    protected static ?string $navigationIcon = 'heroicon-o-building-storefront';

    protected static ?string $navigationGroup = 'Gestion Commerciale';

    protected static ?string $navigationLabel = 'Points de Vente';

    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Section::make('Informations Générales')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                TextInput::make('nom')
                                    ->label('Nom du PDV')
                                    ->required()
                                    ->maxLength(255),
                                Select::make('type_pdv')
                                    ->label('Type de PDV')
                                    ->options([
                                        'supermarché' => 'Supermarché',
                                        'hypermarché' => 'Hypermarché',
                                        'convenience' => 'Convenience Store',
                                        'boulangerie' => 'Boulangerie',
                                        'pharmacie' => 'Pharmacie',
                                        'autre' => 'Autre',
                                    ])
                                    ->required(),
                            ]),
                        Grid::make(3)
                            ->schema([
                                TextInput::make('adresse')
                                    ->label('Adresse')
                                    ->required()
                                    ->maxLength(255),
                                TextInput::make('ville')
                                    ->label('Ville')
                                    ->required()
                                    ->maxLength(100),
                                TextInput::make('code_postal')
                                    ->label('Code Postal')
                                    ->required()
                                    ->maxLength(10),
                            ]),
                        TextInput::make('pays')
                            ->label('Pays')
                            ->default('France')
                            ->required()
                            ->maxLength(100),
                    ]),

                Section::make('Géolocalisation')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                TextInput::make('latitude')
                                    ->label('Latitude')
                                    ->numeric()
                                    ->step(0.000001)
                                    ->suffix('°'),
                                TextInput::make('longitude')
                                    ->label('Longitude')
                                    ->numeric()
                                    ->step(0.000001)
                                    ->suffix('°'),
                            ]),
                    ]),

                Section::make('Affectation')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                Select::make('secteur')
                                    ->label('Secteur')
                                    ->options([
                                        'nord' => 'Nord',
                                        'sud' => 'Sud',
                                        'est' => 'Est',
                                        'ouest' => 'Ouest',
                                        'centre' => 'Centre',
                                    ])
                                    ->required(),
                                Select::make('commercial_id')
                                    ->label('Commercial Assigné')
                                    ->relationship('commercial', 'name')
                                    ->searchable()
                                    ->preload(),
                            ]),
                        Select::make('statut')
                            ->label('Statut')
                            ->options([
                                'actif' => 'Actif',
                                'inactif' => 'Inactif',
                                'en_renovation' => 'En Rénovation',
                                'ferme' => 'Fermé',
                            ])
                            ->default('actif')
                            ->required(),
                    ]),

                Section::make('Notes')
                    ->schema([
                        Textarea::make('notes')
                            ->label('Notes')
                            ->rows(3)
                            ->maxLength(1000),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('nom')
                    ->label('Nom')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('type_pdv')
                    ->label('Type')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'supermarché' => 'success',
                        'hypermarché' => 'primary',
                        'convenience' => 'warning',
                        default => 'gray',
                    }),
                TextColumn::make('ville')
                    ->label('Ville')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('secteur')
                    ->label('Secteur')
                    ->badge(),
                TextColumn::make('commercial.name')
                    ->label('Commercial')
                    ->searchable(),
                TextColumn::make('statut')
                    ->label('Statut')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'actif' => 'success',
                        'inactif' => 'gray',
                        'en_renovation' => 'warning',
                        'ferme' => 'danger',
                    }),
                TextColumn::make('derniere_visite')
                    ->label('Dernière Visite')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
                TextColumn::make('visites_count')
                    ->label('Visites')
                    ->counts('visites')
                    ->sortable(),
            ])
            ->filters([
                SelectFilter::make('type_pdv')
                    ->label('Type de PDV')
                    ->options([
                        'supermarché' => 'Supermarché',
                        'hypermarché' => 'Hypermarché',
                        'convenience' => 'Convenience Store',
                        'boulangerie' => 'Boulangerie',
                        'pharmacie' => 'Pharmacie',
                        'autre' => 'Autre',
                    ]),
                SelectFilter::make('secteur')
                    ->label('Secteur'),
                SelectFilter::make('statut')
                    ->label('Statut'),
                Filter::make('derniere_visite')
                    ->form([
                        Forms\Components\DatePicker::make('derniere_visite_from')
                            ->label('Depuis le'),
                        Forms\Components\DatePicker::make('derniere_visite_until')
                            ->label('Jusqu\'au'),
                    ])
                    ->query(function ($query, array $data) {
                        return $query
                            ->when(
                                $data['derniere_visite_from'],
                                fn ($query, $date) => $query->whereDate('derniere_visite', '>=', $date),
                            )
                            ->when(
                                $data['derniere_visite_until'],
                                fn ($query, $date) => $query->whereDate('derniere_visite', '<=', $date),
                            );
                    }),
            ])
            ->actions([
                ViewAction::make(),
                EditAction::make(),
                DeleteAction::make(),
                Action::make('map')
                    ->label('Carte')
                    ->icon('heroicon-o-map')
                    ->url(fn (PDV $record): string => "https://maps.google.com/?q={$record->latitude},{$record->longitude}")
                    ->openUrlInNewTab(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('nom');
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
            'index' => Pages\ListPDVs::route('/'),
            'create' => Pages\CreatePDV::route('/create'),
            'edit' => Pages\EditPDV::route('/{record}/edit'),
            'view' => Pages\ViewPDV::route('/{record}'),
        ];
    }
} 