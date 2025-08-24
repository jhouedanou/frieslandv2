<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\GeofenceZone;
use App\Models\PDV;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

class GeofenceController extends Controller
{
    /**
     * Lister toutes les zones de géofence
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        
        $geofences = GeofenceZone::with(['pdv'])
            ->when($user->hasRole('commercial'), function ($query) use ($user) {
                $query->whereHas('pdv', function ($q) use ($user) {
                    $q->where('commercial_id', $user->id);
                });
            })
            ->get();

        return response()->json([
            'geofences' => $geofences,
            'total' => $geofences->count(),
        ]);
    }

    /**
     * Vérifier si une position est dans une zone de géofence
     */
    public function checkLocation(Request $request): JsonResponse
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'pdv_id' => 'nullable|exists:pdvs,id',
        ]);

        $latitude = $request->latitude;
        $longitude = $request->longitude;
        $pdvId = $request->pdv_id;

        $nearbyZones = [];

        if ($pdvId) {
            // Vérifier les zones spécifiques au PDV
            $pdv = PDV::find($pdvId);
            if ($pdv) {
                $distance = $pdv->getDistanceFrom($latitude, $longitude);
                $nearbyZones[] = [
                    'pdv_id' => $pdv->id,
                    'pdv_name' => $pdv->nom,
                    'distance' => $distance,
                    'in_zone' => $distance <= 100, // 100 mètres
                    'zone_type' => 'pdv',
                ];
            }
        } else {
            // Vérifier toutes les zones à proximité
            $pdvs = PDV::where('statut', 'actif')->get();
            
            foreach ($pdvs as $pdv) {
                $distance = $pdv->getDistanceFrom($latitude, $longitude);
                if ($distance <= 500) { // 500 mètres
                    $nearbyZones[] = [
                        'pdv_id' => $pdv->id,
                        'pdv_name' => $pdv->nom,
                        'distance' => $distance,
                        'in_zone' => $distance <= 100,
                        'zone_type' => 'pdv',
                    ];
                }
            }
        }

        return response()->json([
            'location' => [
                'latitude' => $latitude,
                'longitude' => $longitude,
            ],
            'nearby_zones' => $nearbyZones,
            'total_nearby' => count($nearbyZones),
        ]);
    }

    /**
     * Enregistrer l'entrée dans une zone
     */
    public function enterZone(Request $request): JsonResponse
    {
        $request->validate([
            'pdv_id' => 'required|exists:pdvs,id',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'timestamp' => 'required|date',
        ]);

        $user = $request->user();
        $pdv = PDV::find($request->pdv_id);

        // Vérifier que l'utilisateur est autorisé pour ce PDV
        if (!$user->hasRole('admin') && $pdv->commercial_id !== $user->id) {
            return response()->json([
                'message' => 'Non autorisé pour ce PDV'
            ], 403);
        }

        // Enregistrer l'événement d'entrée
        Log::info('Entrée dans la zone de géofence', [
            'user_id' => $user->id,
            'pdv_id' => $pdv->id,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'timestamp' => $request->timestamp,
        ]);

        return response()->json([
            'message' => 'Entrée dans la zone enregistrée',
            'pdv' => $pdv->only(['id', 'nom', 'adresse']),
            'timestamp' => $request->timestamp,
        ]);
    }

    /**
     * Enregistrer la sortie d'une zone
     */
    public function exitZone(Request $request): JsonResponse
    {
        $request->validate([
            'pdv_id' => 'required|exists:pdvs,id',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'timestamp' => 'required|date',
            'duration' => 'nullable|integer', // Durée en secondes
        ]);

        $user = $request->user();
        $pdv = PDV::find($request->pdv_id);

        // Vérifier que l'utilisateur est autorisé pour ce PDV
        if (!$user->hasRole('admin') && $pdv->commercial_id !== $user->id) {
            return response()->json([
                'message' => 'Non autorisé pour ce PDV'
            ], 403);
        }

        // Enregistrer l'événement de sortie
        Log::info('Sortie de la zone de géofence', [
            'user_id' => $user->id,
            'pdv_id' => $pdv->id,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'timestamp' => $request->timestamp,
            'duration' => $request->duration,
        ]);

        return response()->json([
            'message' => 'Sortie de la zone enregistrée',
            'pdv' => $pdv->only(['id', 'nom', 'adresse']),
            'timestamp' => $request->timestamp,
            'duration' => $request->duration,
        ]);
    }

    /**
     * Obtenir les statistiques de géofence
     */
    public function statistics(Request $request): JsonResponse
    {
        $user = $request->user();
        $period = $request->get('period', 'month');

        $stats = [
            'total_entries' => 0,
            'total_exits' => 0,
            'average_duration' => 0,
            'most_visited_pdvs' => [],
        ];

        // Ces statistiques seraient normalement stockées dans une table dédiée
        // Pour l'instant, on retourne des données factices

        return response()->json([
            'period' => $period,
            'statistics' => $stats,
        ]);
    }
} 