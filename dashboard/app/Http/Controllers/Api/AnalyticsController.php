<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PDV;
use App\Models\Visite;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class AnalyticsController extends Controller
{
    /**
     * Get dashboard analytics
     */
    public function dashboard(): JsonResponse
    {
        $today = Carbon::today();
        $thisWeek = Carbon::now()->startOfWeek();
        $thisMonth = Carbon::now()->startOfMonth();

        $stats = [
            'pdvs' => [
                'total' => PDV::count(),
                'actifs' => PDV::where('statut', 'actif')->count(),
                'par_secteur' => PDV::select('secteur', DB::raw('count(*) as total'))
                    ->groupBy('secteur')
                    ->get(),
                'par_type' => PDV::select('type_pdv', DB::raw('count(*) as total'))
                    ->groupBy('type_pdv')
                    ->get(),
            ],
            'visites' => [
                'aujourd_hui' => Visite::aujourdhui()->count(),
                'cette_semaine' => Visite::cetteSemaine()->count(),
                'ce_mois' => Visite::ceMois()->count(),
                'par_statut' => Visite::select('statut', DB::raw('count(*) as total'))
                    ->groupBy('statut')
                    ->get(),
            ],
            'commerciaux' => [
                'total' => User::where('is_active', true)->count(),
                'actifs' => User::where('is_active', true)
                    ->whereHas('visites', function ($query) use ($thisMonth) {
                        $query->where('date_visite', '>=', $thisMonth);
                    })
                    ->count(),
            ],
            'performance' => [
                'visites_par_jour' => $this->getVisitesParJour(),
                'top_commerciaux' => $this->getTopCommerciaux(),
                'pdvs_plus_visites' => $this->getPDVsPlusVisites(),
            ],
        ];

        return response()->json($stats);
    }

    /**
     * Get visit analytics
     */
    public function visites(): JsonResponse
    {
        $request = request();
        $period = $request->get('period', 'month');
        $startDate = $this->getStartDate($period);

        $visites = Visite::where('date_visite', '>=', $startDate)
            ->select(
                DB::raw('DATE(date_visite) as date'),
                DB::raw('count(*) as total'),
                DB::raw('count(CASE WHEN statut = "terminee" THEN 1 END) as terminees'),
                DB::raw('count(CASE WHEN statut = "en_cours" THEN 1 END) as en_cours'),
                DB::raw('count(CASE WHEN statut = "annulee" THEN 1 END) as annulees')
            )
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        $stats = [
            'period' => $period,
            'start_date' => $startDate,
            'total_visites' => Visite::where('date_visite', '>=', $startDate)->count(),
            'visites_par_jour' => $visites,
            'moyenne_duree' => Visite::where('date_visite', '>=', $startDate)
                ->whereNotNull('heure_debut')
                ->whereNotNull('heure_fin')
                ->get()
                ->avg(function ($visite) {
                    return $visite->duree_visite;
                }),
        ];

        return response()->json($stats);
    }

    /**
     * Get PDV analytics
     */
    public function pdvs(): JsonResponse
    {
        $pdvs = PDV::withCount('visites')
            ->with(['commercial'])
            ->orderBy('visites_count', 'desc')
            ->limit(20)
            ->get();

        $stats = [
            'total_pdvs' => PDV::count(),
            'pdvs_avec_visites' => PDV::has('visites')->count(),
            'pdvs_sans_visites' => PDV::doesntHave('visites')->count(),
            'top_pdvs' => $pdvs,
            'repartition_secteurs' => PDV::select('secteur', DB::raw('count(*) as total'))
                ->groupBy('secteur')
                ->get(),
            'repartition_types' => PDV::select('type_pdv', DB::raw('count(*) as total'))
                ->groupBy('type_pdv')
                ->get(),
        ];

        return response()->json($stats);
    }

    /**
     * Get start date based on period
     */
    private function getStartDate(string $period): Carbon
    {
        return match ($period) {
            'week' => Carbon::now()->startOfWeek(),
            'month' => Carbon::now()->startOfMonth(),
            'quarter' => Carbon::now()->startOfQuarter(),
            'year' => Carbon::now()->startOfYear(),
            default => Carbon::now()->startOfMonth(),
        };
    }

    /**
     * Get visits per day for the last 30 days
     */
    private function getVisitesParJour(): array
    {
        $dates = collect();
        for ($i = 29; $i >= 0; $i--) {
            $dates->push(Carbon::now()->subDays($i)->format('Y-m-d'));
        }

        $visites = Visite::select(
            DB::raw('DATE(date_visite) as date'),
            DB::raw('count(*) as total')
        )
            ->where('date_visite', '>=', Carbon::now()->subDays(30))
            ->groupBy('date')
            ->pluck('total', 'date')
            ->toArray();

        return $dates->map(function ($date) use ($visites) {
            return [
                'date' => $date,
                'total' => $visites[$date] ?? 0,
            ];
        })->toArray();
    }

    /**
     * Get top performing commercial users
     */
    private function getTopCommerciaux(): array
    {
        return User::select('id', 'name')
            ->withCount(['visites' => function ($query) {
                $query->where('date_visite', '>=', Carbon::now()->startOfMonth());
            }])
            ->orderBy('visites_count', 'desc')
            ->limit(10)
            ->get()
            ->toArray();
    }

    /**
     * Get most visited PDVs
     */
    private function getPDVsPlusVisites(): array
    {
        return PDV::select('id', 'nom', 'ville')
            ->withCount(['visites' => function ($query) {
                $query->where('date_visite', '>=', Carbon::now()->startOfMonth());
            }])
            ->orderBy('visites_count', 'desc')
            ->limit(10)
            ->get()
            ->toArray();
    }
} 