<?php

namespace App\Filament\Widgets;

use App\Models\Visite;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\BadgeColumn;

class LatestVisits extends BaseWidget
{
    protected static ?int $sort = 2;
    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Visite::query()
                    ->with(['pdv', 'commercial'])
                    ->latest('date_visite')
                    ->limit(10)
            )
            ->columns([
                TextColumn::make('pdv.nom')
                    ->label('PDV')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('commercial.name')
                    ->label('Commercial')
                    ->searchable(),
                TextColumn::make('date_visite')
                    ->label('Date')
                    ->date('d/m/Y')
                    ->sortable(),
                TextColumn::make('heure_debut')
                    ->label('Début')
                    ->time('H:i'),
                TextColumn::make('heure_fin')
                    ->label('Fin')
                    ->time('H:i'),
                TextColumn::make('duree_visite')
                    ->label('Durée')
                    ->badge()
                    ->color('info'),
                BadgeColumn::make('statut')
                    ->label('Statut')
                    ->colors([
                        'success' => 'terminee',
                        'warning' => 'en_cours',
                        'danger' => 'annulee',
                    ]),
            ])
            ->paginated(false);
    }
} 