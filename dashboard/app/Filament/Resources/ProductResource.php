<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ProductResource\Pages;
use App\Models\Product;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class ProductResource extends Resource
{
    protected static ?string $model = Product::class;

    protected static ?string $navigationIcon = 'heroicon-o-cube';

    protected static ?string $navigationGroup = 'Gestion des Stocks';

    protected static ?string $modelLabel = 'Produit';

    protected static ?string $pluralModelLabel = 'Produits';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informations du produit')
                    ->schema([
                        Forms\Components\TextInput::make('code')
                            ->label('Code produit')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(50),

                        Forms\Components\TextInput::make('name')
                            ->label('Nom du produit')
                            ->required()
                            ->maxLength(255),

                        Forms\Components\Select::make('category')
                            ->label('Catégorie')
                            ->required()
                            ->options(Product::getCategories())
                            ->searchable(),

                        Forms\Components\TextInput::make('unit')
                            ->label('Unité')
                            ->required()
                            ->maxLength(50)
                            ->default('unité'),
                    ])->columns(2),

                Forms\Components\Section::make('Prix et stock')
                    ->schema([
                        Forms\Components\TextInput::make('price')
                            ->label('Prix (FCFA)')
                            ->required()
                            ->numeric()
                            ->minValue(0)
                            ->suffix('FCFA'),

                        Forms\Components\TextInput::make('stock_quantity')
                            ->label('Quantité en stock')
                            ->required()
                            ->numeric()
                            ->minValue(0)
                            ->default(0),

                        Forms\Components\Toggle::make('is_active')
                            ->label('Actif')
                            ->default(true),
                    ])->columns(3),

                Forms\Components\Section::make('Description')
                    ->schema([
                        Forms\Components\Textarea::make('description')
                            ->label('Description')
                            ->maxLength(1000)
                            ->rows(3),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('code')
                    ->label('Code')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('name')
                    ->label('Nom')
                    ->searchable()
                    ->sortable()
                    ->limit(50),

                Tables\Columns\BadgeColumn::make('category')
                    ->label('Catégorie')
                    ->colors([
                        'primary' => 'EVAP',
                        'success' => 'SCM',
                        'warning' => 'IMP',
                        'danger' => 'UHT',
                        'secondary' => 'YAOURT',
                        'info' => 'CÉRÉALES AU LAIT',
                    ])
                    ->sortable(),

                Tables\Columns\TextColumn::make('price')
                    ->label('Prix')
                    ->money('XOF', locale: 'fr_FR')
                    ->sortable(),

                Tables\Columns\TextColumn::make('stock_quantity')
                    ->label('Stock')
                    ->numeric()
                    ->sortable()
                    ->color(fn ($state) => $state <= 10 ? 'danger' : ($state <= 50 ? 'warning' : 'success')),

                Tables\Columns\TextColumn::make('unit')
                    ->label('Unité')
                    ->sortable(),

                Tables\Columns\ToggleColumn::make('is_active')
                    ->label('Actif')
                    ->sortable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('category')
                    ->label('Catégorie')
                    ->options(Product::getCategories()),

                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Statut')
                    ->boolean()
                    ->trueLabel('Actifs seulement')
                    ->falseLabel('Inactifs seulement')
                    ->native(false),

                Tables\Filters\Filter::make('low_stock')
                    ->label('Stock faible')
                    ->query(fn ($query) => $query->where('stock_quantity', '<=', 10)),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\BulkAction::make('toggle_active')
                        ->label('Activer/Désactiver')
                        ->icon('heroicon-o-eye')
                        ->action(function ($records) {
                            foreach ($records as $record) {
                                $record->update(['is_active' => !$record->is_active]);
                            }
                        })
                        ->deselectRecordsAfterCompletion(),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
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
            'index' => Pages\ListProducts::route('/'),
            'create' => Pages\CreateProduct::route('/create'),
            'edit' => Pages\EditProduct::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('stock_quantity', '<=', 10)->count() ?: null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return static::getNavigationBadge() > 0 ? 'warning' : null;
    }
}
