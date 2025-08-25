<?php

namespace App\Filament\Resources;

use App\Filament\Resources\VisiteResource\Pages;
use App\Models\Visite;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class VisiteResource extends Resource
{
    protected static ?string $model = Visite::class;
    protected static ?string $navigationIcon = 'heroicon-o-map-pin';
    protected static ?string $navigationLabel = 'Visites';
    protected static ?string $pluralModelLabel = 'Visites';
    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informations Générales')
                    ->schema([
                        Forms\Components\TextInput::make('visite_id')
                            ->label('ID Visite')
                            ->disabled(),
                        Forms\Components\TextInput::make('pdv_id')
                            ->label('ID PDV')
                            ->required(),
                        Forms\Components\TextInput::make('commercial')
                            ->label('Commercial')
                            ->required(),
                        Forms\Components\DateTimePicker::make('date_visite')
                            ->label('Date de Visite')
                            ->required(),
                    ])->columns(2),
                    
                Forms\Components\Section::make('Géolocalisation')
                    ->schema([
                        Forms\Components\KeyValue::make('geolocation')
                            ->label('Position GPS')
                            ->keyLabel('Coordonnée')
                            ->valueLabel('Valeur'),
                        Forms\Components\Toggle::make('geofence_validated')
                            ->label('Géofencing Validé'),
                        Forms\Components\TextInput::make('precision_gps')
                            ->label('Précision GPS (m)')
                            ->numeric(),
                    ])->columns(2),
                    
                Forms\Components\Section::make('Produits')
                    ->schema([
                        Forms\Components\KeyValue::make('produits')
                            ->label('Données Produits (JSON)')
                            ->keyLabel('Catégorie')
                            ->valueLabel('Données'),
                    ]),
                    
                Forms\Components\Section::make('Concurrence & Visibilité')
                    ->schema([
                        Forms\Components\KeyValue::make('concurrence')
                            ->label('Données Concurrence (JSON)'),
                        Forms\Components\KeyValue::make('visibilite')
                            ->label('Données Visibilité (JSON)'),
                    ])->columns(2),
                    
                Forms\Components\Section::make('Actions & Images')
                    ->schema([
                        Forms\Components\KeyValue::make('actions')
                            ->label('Actions Réalisées (JSON)'),
                        Forms\Components\TagsInput::make('images')
                            ->label('Photos'),
                        Forms\Components\Select::make('sync_status')
                            ->label('Statut Sync')
                            ->options([
                                'pending' => 'En attente',
                                'synced' => 'Synchronisé', 
                                'failed' => 'Échec',
                            ])
                            ->default('pending'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('visite_id')
                    ->label('ID')
                    ->limit(8)
                    ->tooltip(fn($record) => $record->visite_id),
                Tables\Columns\TextColumn::make('commercial')
                    ->label('Commercial')
                    ->sortable()
                    ->searchable(),
                Tables\Columns\TextColumn::make('pdv.nom_pdv')
                    ->label('PDV')
                    ->sortable()
                    ->searchable(),
                Tables\Columns\TextColumn::make('date_visite')
                    ->label('Date')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
                Tables\Columns\IconColumn::make('geofence_validated')
                    ->label('Géofencing')
                    ->boolean(),
                // KPIs selon CLAUDE.md
                Tables\Columns\IconColumn::make('evap_present')
                    ->label('EVAP')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-circle')
                    ->falseIcon('heroicon-o-x-circle'),
                Tables\Columns\IconColumn::make('imp_present')
                    ->label('IMP')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-circle')
                    ->falseIcon('heroicon-o-x-circle'),
                Tables\Columns\IconColumn::make('scm_present')
                    ->label('SCM')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-circle')
                    ->falseIcon('heroicon-o-x-circle'),
                Tables\Columns\IconColumn::make('uht_present')
                    ->label('UHT')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-circle')
                    ->falseIcon('heroicon-o-x-circle'),
                Tables\Columns\BadgeColumn::make('sync_status')
                    ->label('Sync')
                    ->colors([
                        'warning' => 'pending',
                        'success' => 'synced',
                        'danger' => 'failed',
                    ]),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('commercial')
                    ->label('Commercial')
                    ->options(function () {
                        return Visite::query()
                            ->select('commercial')
                            ->distinct()
                            ->pluck('commercial', 'commercial')
                            ->toArray();
                    }),
                Tables\Filters\Filter::make('date_range')
                    ->label('Période')
                    ->form([
                        Forms\Components\DatePicker::make('date_from')
                            ->label('Du'),
                        Forms\Components\DatePicker::make('date_to')  
                            ->label('Au'),
                    ])
                    ->query(function ($query, array $data) {
                        return $query
                            ->when(
                                $data['date_from'],
                                fn($query, $date) => $query->whereDate('date_visite', '>=', $date)
                            )
                            ->when(
                                $data['date_to'],
                                fn($query, $date) => $query->whereDate('date_visite', '<=', $date)
                            );
                    }),
                Tables\Filters\SelectFilter::make('sync_status')
                    ->label('Statut Sync')
                    ->options([
                        'pending' => 'En attente',
                        'synced' => 'Synchronisé',
                        'failed' => 'Échec',
                    ]),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\BulkAction::make('export_excel')
                        ->label('Export Excel')
                        ->icon('heroicon-o-document-arrow-down')
                        ->action(fn($records) => static::exportExcel($records)),
                ]),
            ])
            ->defaultSort('date_visite', 'desc');
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
            'index' => Pages\ListVisites::route('/'),
            'create' => Pages\CreateVisite::route('/create'),
            'view' => Pages\ViewVisite::route('/{record}'),
            'edit' => Pages\EditVisite::route('/{record}/edit'),
        ];
    }

    // Export Excel selon CLAUDE.md - format compatible Google Sheets
    protected static function exportExcel($records)
    {
        // TODO: Implémenter export Excel avec même structure que Google Sheets
        // Format exact selon CLAUDE.md pour migration progressive
    }
}