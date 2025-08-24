<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Visite;
use App\Models\PDV;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class ReportController extends Controller
{
    /**
     * Rapport des visites
     */
    public function visits(Request $request): JsonResponse
    {
        $request->validate([
            'date_from' => 'required|date',
            'date_to' => 'required|date|after:date_from',
            'commercial_id' => 'nullable|exists:users,id',
            'pdv_id' => 'nullable|exists:pdvs,id',
        ]);

        $query = Visite::with(['pdv', 'commercial'])
            ->whereBetween('date_visite', [$request->date_from, $request->date_to]);

        if ($request->commercial_id) {
            $query->where('commercial_id', $request->commercial_id);
        }

        if ($request->pdv_id) {
            $query->where('pdv_id', $request->pdv_id);
        }

        $visits = $query->get();

        $stats = [
            'total_visits' => $visits->count(),
            'completed_visits' => $visits->where('statut', 'terminee')->count(),
            'pending_visits' => $visits->where('statut', 'en_cours')->count(),
            'cancelled_visits' => $visits->where('statut', 'annulee')->count(),
            'average_duration' => $visits->where('statut', 'terminee')->avg('duree_visite'),
            'visits_by_status' => $visits->groupBy('statut')->map->count(),
            'visits_by_date' => $visits->groupBy(function ($visit) {
                return $visit->date_visite->format('Y-m-d');
            })->map->count(),
        ];

        return response()->json([
            'period' => [
                'from' => $request->date_from,
                'to' => $request->date_to,
            ],
            'statistics' => $stats,
            'visits' => $visits,
        ]);
    }

    /**
     * Rapport de performance
     */
    public function performance(Request $request): JsonResponse
    {
        $request->validate([
            'period' => 'required|in:week,month,quarter,year',
            'commercial_id' => 'nullable|exists:users,id',
        ]);

        $period = $request->period;
        $startDate = $this->getStartDate($period);

        $query = Visite::where('date_visite', '>=', $startDate);

        if ($request->commercial_id) {
            $query->where('commercial_id', $request->commercial_id);
        }

        $visits = $query->get();

        $performance = [
            'total_visits' => $visits->count(),
            'completion_rate' => $visits->count() > 0 ? 
                ($visits->where('statut', 'terminee')->count() / $visits->count()) * 100 : 0,
            'average_duration' => $visits->where('statut', 'terminee')->avg('duree_visite'),
            'visits_per_day' => $visits->count() / max(1, Carbon::now()->diffInDays($startDate)),
            'top_pdvs' => $visits->groupBy('pdv_id')
                ->map(function ($group) {
                    return [
                        'pdv_id' => $group->first()->pdv_id,
                        'pdv_name' => $group->first()->pdv->nom ?? 'N/A',
                        'visit_count' => $group->count(),
                    ];
                })
                ->sortByDesc('visit_count')
                ->take(5)
                ->values(),
        ];

        return response()->json([
            'period' => $period,
            'start_date' => $startDate,
            'performance' => $performance,
        ]);
    }

    /**
     * Exporter les données
     */
    public function export(Request $request): JsonResponse
    {
        $request->validate([
            'type' => 'required|in:visits,pdvs,performance',
            'format' => 'required|in:json,csv',
            'date_from' => 'nullable|date',
            'date_to' => 'nullable|date|after:date_from',
        ]);

        $type = $request->type;
        $format = $request->format;

        switch ($type) {
            case 'visits':
                $data = $this->exportVisits($request);
                break;
            case 'pdvs':
                $data = $this->exportPDVs($request);
                break;
            case 'performance':
                $data = $this->exportPerformance($request);
                break;
            default:
                $data = [];
        }

        if ($format === 'csv') {
            // Convertir en CSV (simulation)
            $csvData = $this->arrayToCsv($data);
            return response()->json([
                'format' => 'csv',
                'data' => $csvData,
                'filename' => "friesland_{$type}_" . now()->format('Y-m-d') . ".csv",
            ]);
        }

        return response()->json([
            'format' => 'json',
            'data' => $data,
            'exported_at' => now(),
        ]);
    }

    /**
     * Exporter les visites
     */
    private function exportVisits(Request $request): array
    {
        $query = Visite::with(['pdv', 'commercial']);

        if ($request->date_from && $request->date_to) {
            $query->whereBetween('date_visite', [$request->date_from, $request->date_to]);
        }

        return $query->get()->toArray();
    }

    /**
     * Exporter les PDV
     */
    private function exportPDVs(Request $request): array
    {
        return PDV::with(['commercial'])->get()->toArray();
    }

    /**
     * Exporter les performances
     */
    private function exportPerformance(Request $request): array
    {
        $period = $request->get('period', 'month');
        $startDate = $this->getStartDate($period);

        $visits = Visite::where('date_visite', '>=', $startDate)->get();

        return [
            'period' => $period,
            'start_date' => $startDate,
            'total_visits' => $visits->count(),
            'completion_rate' => $visits->count() > 0 ? 
                ($visits->where('statut', 'terminee')->count() / $visits->count()) * 100 : 0,
            'visits_by_status' => $visits->groupBy('statut')->map->count(),
        ];
    }

    /**
     * Convertir un tableau en CSV
     */
    private function arrayToCsv(array $data): string
    {
        if (empty($data)) {
            return '';
        }

        $headers = array_keys($data[0]);
        $csv = implode(',', $headers) . "\n";

        foreach ($data as $row) {
            $csv .= implode(',', array_map(function ($value) {
                return is_array($value) ? json_encode($value) : $value;
            }, $row)) . "\n";
        }

        return $csv;
    }

    /**
     * Obtenir la date de début selon la période
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
} 