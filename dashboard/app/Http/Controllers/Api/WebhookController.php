<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

class WebhookController extends Controller
{
    /**
     * Webhook pour les événements de géofence
     */
    public function geofence(Request $request): JsonResponse
    {
        $request->validate([
            'event_type' => 'required|string|in:enter,exit',
            'pdv_id' => 'required|exists:pdvs,id',
            'user_id' => 'required|exists:users,id',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'timestamp' => 'required|date',
            'device_id' => 'nullable|string',
        ]);

        $eventType = $request->event_type;
        $pdvId = $request->pdv_id;
        $userId = $request->user_id;

        // Traiter l'événement de géofence
        Log::info("Événement de géofence: {$eventType}", [
            'pdv_id' => $pdvId,
            'user_id' => $userId,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'timestamp' => $request->timestamp,
            'device_id' => $request->device_id,
        ]);

        // Ici, vous pourriez déclencher des actions automatiques
        // Par exemple, créer automatiquement une visite si l'utilisateur entre dans la zone

        if ($eventType === 'enter') {
            // Logique pour l'entrée dans la zone
            $this->handleZoneEntry($request);
        } else {
            // Logique pour la sortie de la zone
            $this->handleZoneExit($request);
        }

        return response()->json([
            'message' => "Événement de géofence traité: {$eventType}",
            'timestamp' => now(),
        ]);
    }

    /**
     * Webhook pour la fin de visite
     */
    public function visitComplete(Request $request): JsonResponse
    {
        $request->validate([
            'visite_id' => 'required|exists:visites,id',
            'completion_data' => 'required|array',
            'timestamp' => 'required|date',
        ]);

        $visiteId = $request->visite_id;
        $completionData = $request->completion_data;

        // Traiter la fin de visite
        Log::info('Fin de visite webhook', [
            'visite_id' => $visiteId,
            'completion_data' => $completionData,
            'timestamp' => $request->timestamp,
        ]);

        // Ici, vous pourriez déclencher des actions automatiques
        // Par exemple, envoyer des notifications, mettre à jour des statistiques, etc.

        $this->processVisitCompletion($visiteId, $completionData);

        return response()->json([
            'message' => 'Fin de visite traitée',
            'visite_id' => $visiteId,
            'timestamp' => now(),
        ]);
    }

    /**
     * Traiter l'entrée dans une zone
     */
    private function handleZoneEntry(Request $request): void
    {
        // Logique pour gérer l'entrée dans une zone
        // Par exemple, créer automatiquement une visite
        // ou envoyer une notification
        
        Log::info('Traitement de l\'entrée dans la zone', [
            'pdv_id' => $request->pdv_id,
            'user_id' => $request->user_id,
        ]);
    }

    /**
     * Traiter la sortie d'une zone
     */
    private function handleZoneExit(Request $request): void
    {
        // Logique pour gérer la sortie d'une zone
        // Par exemple, finaliser une visite en cours
        // ou calculer la durée de présence
        
        Log::info('Traitement de la sortie de la zone', [
            'pdv_id' => $request->pdv_id,
            'user_id' => $request->user_id,
        ]);
    }

    /**
     * Traiter la fin de visite
     */
    private function processVisitCompletion(int $visiteId, array $completionData): void
    {
        // Logique pour traiter la fin de visite
        // Par exemple, mettre à jour les statistiques
        // ou déclencher des workflows
        
        Log::info('Traitement de la fin de visite', [
            'visite_id' => $visiteId,
            'completion_data' => $completionData,
        ]);
    }
} 