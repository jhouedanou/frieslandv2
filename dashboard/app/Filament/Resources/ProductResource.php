<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ProductResource\Pages;
use App\Filament\Resources\ProductResource\RelationManagers;
use App\Models\Product;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use Filament\Support\Colors\Color;
use Filament\Tables\Filters\SelectFilter;

class ProductResource extends Resource
{
    protected static ?string $model = Product::class;

    protected static ?string $navigationIcon = 'heroicon-o-cube';
    
    protected static ?string $navigationGroup = 'Gestion Commerciale';
    
    protected static ?string $modelLabel = 'Produit';
    
    protected static ?string $pluralModelLabel = 'Produits';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informations produit')
                    ->schema([
                        Forms\Components\TextInput::make('code')
                            ->label('Code produit')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(255)
                            ->live(onBlur: true)
                            ->afterStateUpdated(fn (string $context, $state, callable $set) => $context === 'create' ? $set('code', strtoupper($state)) : null),
                            
                        Forms\Components\TextInput::make('name')
                            ->label('Nom produit')
                            ->required()
                            ->maxLength(255),
                            
                        Forms\Components\Select::make('category')
                            ->label('Catégorie')
                            ->required()
                            ->options(Product::getCategories())
                            ->searchable(),
                    ])
                    ->columns(3),
                    
                Forms\Components\Section::make('Pricing & Stock')
                    ->schema([
                        Forms\Components\TextInput::make('price')
                            ->label('Prix (FCFA)')
                            ->required()
                            ->numeric()
                            ->prefix('FCFA')
                            ->step(0.01),
                            
                        Forms\Components\TextInput::make('stock_quantity')
                            ->label('Quantité en stock')
                            ->required()
                            ->numeric()
                            ->default(0)
                            ->minValue(0),
                            
                        Forms\Components\TextInput::make('unit')
                            ->label('Unité')
                            ->required()
                            ->maxLength(50)
                            ->placeholder('boîte, sachet, pot...'),
                    ])
                    ->columns(3),
                    
                Forms\Components\Section::make('Détails')
                    ->schema([
                        Forms\Components\Textarea::make('description')
                            ->label('Description')
                            ->maxLength(500)
                            ->rows(3),
                            
                        Forms\Components\Toggle::make('is_active')
                            ->label('Produit actif')
                            ->default(true)
                            ->helperText('Décochez pour désactiver le produit'),
                    ])
                    ->columns(1),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('code')
                    ->label('Code')
                    ->searchable()
                    ->sortable()
                    ->copyable()
                    ->badge()
                    ->color('primary'),
                    
                Tables\Columns\TextColumn::make('name')
                    ->label('Nom produit')
                    ->searchable()
                    ->sortable()
                    ->limit(30)
                    ->tooltip(fn ($record) => $record->name),
                    
                Tables\Columns\TextColumn::make('category')
                    ->label('Catégorie')
                    ->badge()
                    ->color(fn ($state) => match ($state) {
                        'EVAP' => 'warning',
                        'IMP' => 'success', 
                        'SCM' => 'info',
                        'UHT' => 'danger',
                        'YAOURT' => 'purple',
                        default => 'gray',
                    })
                    ->searchable()
                    ->sortable(),
                    
                Tables\Columns\TextColumn::make('price')
                    ->label('Prix')
                    ->money('FCFA', locale: 'fr')
                    ->sortable(),
                    
                Tables\Columns\TextColumn::make('stock_quantity')
                    ->label('Stock')
                    ->numeric()
                    ->sortable()
                    ->badge()
                    ->color(fn ($state) => match (true) {
                        $state <= 10 => 'danger',
                        $state <= 50 => 'warning',
                        default => 'success',
                    }),
                    
                Tables\Columns\TextColumn::make('unit')
                    ->label('Unité')
                    ->badge()
                    ->color('gray'),
                    
                Tables\Columns\ToggleColumn::make('is_active')
                    ->label('Actif')
                    ->onColor('success')
                    ->offColor('gray'),
                    
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('category')
                    ->label('Catégorie')
                    ->options(Product::getCategories()),
                    
                SelectFilter::make('is_active')
                    ->label('Statut')
                    ->options([
                        1 => 'Actif',
                        0 => 'Inactif',
                    ]),
                    
                Tables\Filters\Filter::make('low_stock')
                    ->label('Stock faible (≤ 10)')
                    ->query(fn (Builder $query) => $query->where('stock_quantity', '<=', 10)),
            ])
            ->actions([
                Tables\Actions\EditAction::make()
                    ->color('warning'),
                Tables\Actions\DeleteAction::make()
                    ->color('danger'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\BulkAction::make('activate')
                        ->label('Activer sélectionnés')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->action(fn ($records) => $records->each(fn ($record) => $record->update(['is_active' => true]))),
                    Tables\Actions\BulkAction::make('deactivate')
                        ->label('Désactiver sélectionnés')
                        ->icon('heroicon-o-x-circle')
                        ->color('danger')
                        ->action(fn ($records) => $records->each(fn ($record) => $record->update(['is_active' => false]))),
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
}
