<?php

namespace App\Filament\Widgets;

use App\Models\PDV;
use App\Models\Visite;
use App\Models\User;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Illuminate\Support\Carbon;

class StatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        $aujourdhui = Carbon::today();
        $ceMois = Carbon::now()->startOfMonth();
        $cetteSemaine = Carbon::now()->startOfWeek();

        return [
            Stat::make('Total PDV', PDV::count())
                ->description('Points de vente actifs')
                ->descriptionIcon('heroicon-m-building-storefront')
                ->color('primary')
                ->chart([7, 2, 10, 3, 15, 4, 17]),

            Stat::make('PDV Actifs', PDV::where('statut', 'actif')->count())
                ->description('En activité')
                ->descriptionIcon('heroicon-m-check-circle')
                ->color('success')
                ->chart([17, 16, 14, 15, 14, 13, 12]),

            Stat::make('Visites Aujourd\'hui', Visite::aujourdhui()->count())
                ->description('Visites du jour')
                ->descriptionIcon('heroicon-m-calendar-days')
                ->color('warning')
                ->chart([3, 4, 3, 5, 4, 3, 4]),

            Stat::make('Visites Cette Semaine', Visite::cetteSemaine()->count())
                ->description('Visites de la semaine')
                ->descriptionIcon('heroicon-m-calendar')
                ->color('info')
                ->chart([15, 4, 10, 2, 12, 4, 14]),

            Stat::make('Visites Ce Mois', Visite::ceMois()->count())
                ->description('Visites du mois')
                ->descriptionIcon('heroicon-m-calendar')
                ->color('success')
                ->chart([65, 59, 80, 81, 56, 55, 40]),

            Stat::make('Commerciaux Actifs', User::where('is_active', true)->count())
                ->description('Équipe commerciale')
                ->descriptionIcon('heroicon-m-users')
                ->color('primary')
                ->chart([12, 13, 14, 15, 14, 13, 12]),
        ];
    }
} 