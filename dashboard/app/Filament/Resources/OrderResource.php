<?php

namespace App\Filament\Resources;

use App\Filament\Resources\OrderResource\Pages;
use App\Models\Order;
use App\Models\PDV;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class OrderResource extends Resource
{
    protected static ?string $model = Order::class;

    protected static ?string $navigationIcon = 'heroicon-o-shopping-cart';

    protected static ?string $navigationGroup = 'Gestion des Stocks';

    protected static ?string $modelLabel = 'Commande';

    protected static ?string $pluralModelLabel = 'Commandes';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informations de la commande')
                    ->schema([
                        Forms\Components\TextInput::make('order_number')
                            ->label('Numéro de commande')
                            ->disabled()
                            ->dehydrated(false),

                        Forms\Components\Select::make('pdv_id')
                            ->label('PDV')
                            ->relationship('pdv', 'nom')
                            ->required()
                            ->searchable()
                            ->preload(),

                        Forms\Components\Select::make('status')
                            ->label('Statut')
                            ->required()
                            ->options(Order::getStatuses())
                            ->default('DRAFT'),

                        Forms\Components\Select::make('payment_status')
                            ->label('Statut de paiement')
                            ->required()
                            ->options(Order::getPaymentStatuses())
                            ->default('PENDING'),
                    ])->columns(2),

                Forms\Components\Section::make('Dates')
                    ->schema([
                        Forms\Components\DateTimePicker::make('order_date')
                            ->label('Date de commande')
                            ->required()
                            ->default(now()),

                        Forms\Components\DateTimePicker::make('delivery_date')
                            ->label('Date de livraison'),

                        Forms\Components\Select::make('delivery_type')
                            ->label('Type de livraison')
                            ->required()
                            ->options(Order::getDeliveryTypes())
                            ->default('IMMEDIATE'),
                    ])->columns(3),

                Forms\Components\Section::make('Montants')
                    ->schema([
                        Forms\Components\TextInput::make('total_amount')
                            ->label('Total livré (FCFA)')
                            ->numeric()
                            ->default(0)
                            ->suffix('FCFA'),

                        Forms\Components\TextInput::make('total_pre_order')
                            ->label('Total pré-commande (FCFA)')
                            ->numeric()
                            ->default(0)
                            ->suffix('FCFA'),

                        Forms\Components\TextInput::make('grand_total')
                            ->label('Grand total (FCFA)')
                            ->numeric()
                            ->default(0)
                            ->suffix('FCFA'),
                    ])->columns(3),

                Forms\Components\Section::make('Notes et signature')
                    ->schema([
                        Forms\Components\Textarea::make('notes')
                            ->label('Notes')
                            ->maxLength(1000)
                            ->rows(3),

                        Forms\Components\Textarea::make('signature')
                            ->label('Signature')
                            ->maxLength(1000)
                            ->rows(2),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('order_number')
                    ->label('N° Commande')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('pdv.nom')
                    ->label('PDV')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\BadgeColumn::make('status')
                    ->label('Statut')
                    ->colors([
                        'secondary' => 'DRAFT',
                        'warning' => 'PENDING',
                        'primary' => 'CONFIRMED',
                        'info' => 'SHIPPED',
                        'success' => 'DELIVERED',
                        'danger' => 'CANCELLED',
                    ])
                    ->sortable(),

                Tables\Columns\BadgeColumn::make('payment_status')
                    ->label('Paiement')
                    ->colors([
                        'warning' => 'PENDING',
                        'success' => 'PAID',
                        'info' => 'PARTIALLY_PAID',
                        'danger' => 'UNPAID',
                    ])
                    ->sortable(),

                Tables\Columns\TextColumn::make('grand_total')
                    ->label('Total')
                    ->money('XOF', locale: 'fr_FR')
                    ->sortable(),

                Tables\Columns\TextColumn::make('order_date')
                    ->label('Date commande')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),

                Tables\Columns\TextColumn::make('delivery_date')
                    ->label('Date livraison')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->placeholder('Non planifiée'),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('Statut')
                    ->options(Order::getStatuses()),

                Tables\Filters\SelectFilter::make('payment_status')
                    ->label('Statut paiement')
                    ->options(Order::getPaymentStatuses()),

                Tables\Filters\SelectFilter::make('pdv_id')
                    ->label('PDV')
                    ->relationship('pdv', 'nom')
                    ->searchable()
                    ->preload(),

                Tables\Filters\Filter::make('order_date')
                    ->form([
                        Forms\Components\DatePicker::make('from')
                            ->label('Du'),
                        Forms\Components\DatePicker::make('until')
                            ->label('Au'),
                    ])
                    ->query(function ($query, array $data) {
                        return $query
                            ->when(
                                $data['from'],
                                fn ($query, $date) => $query->whereDate('order_date', '>=', $date),
                            )
                            ->when(
                                $data['until'],
                                fn ($query, $date) => $query->whereDate('order_date', '<=', $date),
                            );
                    }),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
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
            'index' => Pages\ListOrders::route('/'),
            'create' => Pages\CreateOrder::route('/create'),
            'view' => Pages\ViewOrder::route('/{record}'),
            'edit' => Pages\EditOrder::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('status', 'PENDING')->count() ?: null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return static::getNavigationBadge() > 0 ? 'warning' : null;
    }
}
