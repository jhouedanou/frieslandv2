<?php

namespace App\Filament\Widgets;

use App\Models\Visite;
use App\Models\PDV;
use App\Models\Commercial;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Illuminate\Support\Facades\DB;

class StatsOverviewWidget extends BaseWidget
{
    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        // KPIs principaux selon CLAUDE.md
        $totalVisites = Visite::count();
        $visitesCeMois = Visite::ceMois()->count();
        $croissanceMensuelle = $this->calculateMonthlyGrowth();
        
        // Taux présence produits selon CLAUDE.md
        $tauxEvap = $this->calculateProductPresenceRate('evap');
        $tauxImp = $this->calculateProductPresenceRate('imp'); 
        $tauxScm = $this->calculateProductPresenceRate('scm');
        $tauxUht = $this->calculateProductPresenceRate('uht');
        $tauxYaourt = $this->calculateProductPresenceRate('yaourt');
        
        // Taux respect prix selon CLAUDE.md
        $tauxPrixEvap = $this->calculatePriceComplianceRate('evap');
        $tauxPrixImp = $this->calculatePriceComplianceRate('imp');
        $tauxPrixScm = $this->calculatePriceComplianceRate('scm');

        return [
            Stat::make('Total Visites', $totalVisites)
                ->description($croissanceMensuelle >= 0 ? "+{$croissanceMensuelle}% ce mois" : "{$croissanceMensuelle}% ce mois")
                ->descriptionIcon($croissanceMensuelle >= 0 ? 'heroicon-m-arrow-trending-up' : 'heroicon-m-arrow-trending-down')
                ->color($croissanceMensuelle >= 0 ? 'success' : 'danger'),
                
            Stat::make('PDV Actifs', PDV::count())
                ->description('Points de vente')
                ->descriptionIcon('heroicon-m-map-pin')
                ->color('info'),
                
            Stat::make('% EVAP Présent', $tauxEvap . '%')
                ->description('Taux présence EVAP')
                ->descriptionIcon('heroicon-m-check-circle')
                ->color($tauxEvap >= 80 ? 'success' : ($tauxEvap >= 60 ? 'warning' : 'danger')),
                
            Stat::make('% IMP Présent', $tauxImp . '%')
                ->description('Taux présence IMP')
                ->descriptionIcon('heroicon-m-check-circle')
                ->color($tauxImp >= 80 ? 'success' : ($tauxImp >= 60 ? 'warning' : 'danger')),
                
            Stat::make('% SCM Présent', $tauxScm . '%')
                ->description('Taux présence SCM')
                ->descriptionIcon('heroicon-m-check-circle')
                ->color($tauxScm >= 80 ? 'success' : ($tauxScm >= 60 ? 'warning' : 'danger')),
                
            Stat::make('Prix Respectés', $tauxPrixEvap . '%')
                ->description('Moyenne générale')
                ->descriptionIcon('heroicon-m-currency-dollar')
                ->color($tauxPrixEvap >= 80 ? 'success' : ($tauxPrixEvap >= 60 ? 'warning' : 'danger')),
                
            Stat::make('Commerciaux', Commercial::count())
                ->description('Merchandisers actifs')
                ->descriptionIcon('heroicon-m-users')
                ->color('info'),
                
            Stat::make('Alertes', $this->countAlerts())
                ->description('Nécessitent attention')
                ->descriptionIcon('heroicon-m-exclamation-triangle')
                ->color('warning'),
        ];
    }
    
    private function calculateMonthlyGrowth(): float
    {
        $currentMonth = Visite::ceMois()->count();
        $previousMonth = Visite::whereMonth('date_visite', now()->subMonth()->month)->count();
        
        if ($previousMonth === 0) {
            return $currentMonth > 0 ? 100 : 0;
        }
        
        return round((($currentMonth - $previousMonth) / $previousMonth) * 100, 1);
    }
    
    private function calculateProductPresenceRate(string $product): float
    {
        $total = Visite::count();
        if ($total === 0) return 0;
        
        $withProduct = Visite::whereJsonContains("produits->{$product}->present", true)->count();
        return round(($withProduct / $total) * 100, 1);
    }
    
    private function calculatePriceComplianceRate(string $product): float
    {
        $withProduct = Visite::whereJsonContains("produits->{$product}->present", true)->count();
        if ($withProduct === 0) return 0;
        
        $withCorrectPrice = Visite::where(function($query) use ($product) {
            $query->whereJsonContains("produits->{$product}->present", true)
                  ->whereJsonContains("produits->{$product}->prix_respectes", true);
        })->count();
        
        return round(($withCorrectPrice / $withProduct) * 100, 1);
    }
    
    private function countAlerts(): int
    {
        // Alertes selon CLAUDE.md : échecs sync, géofencing non validé, etc.
        return Visite::where('sync_status', 'failed')->count() +
               Visite::where('geofence_validated', false)->count();
    }
}