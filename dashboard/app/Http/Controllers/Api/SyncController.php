<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PDV;
use App\Models\Visite;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class SyncController extends Controller
{
    /**
     * Vérifier l'état de synchronisation
     */
    public function check(Request $request): JsonResponse
    {
        $user = $request->user();
        $lastSync = $request->get('last_sync', '1970-01-01 00:00:00');
        
        $changes = [
            'pdvs' => [
                'created' => PDV::where('created_at', '>', $lastSync)->count(),
                'updated' => PDV::where('updated_at', '>', $lastSync)->count(),
                'deleted' => 0, // Gérer la logique de suppression
            ],
            'visites' => [
                'created' => Visite::where('created_at', '>', $lastSync)->count(),
                'updated' => Visite::where('updated_at', '>', $lastSync)->count(),
                'deleted' => 0,
            ],
            'users' => [
                'created' => User::where('created_at', '>', $lastSync)->count(),
                'updated' => User::where('updated_at', '>', $lastSync)->count(),
                'deleted' => 0,
            ],
        ];

        return response()->json([
            'has_changes' => array_sum(array_map('array_sum', $changes)) > 0,
            'changes' => $changes,
            'server_time' => now(),
            'recommended_sync' => $this->shouldSync($changes),
        ]);
    }

    /**
     * Télécharger les données mises à jour
     */
    public function download(Request $request): JsonResponse
    {
        $user = $request->user();
        $lastSync = $request->get('last_sync', '1970-01-01 00:00:00');
        $dataTypes = $request->get('data_types', ['pdvs', 'visites', 'users']);

        $data = [];

        if (in_array('pdvs', $dataTypes)) {
            $data['pdvs'] = PDV::with(['commercial'])
                ->where(function ($query) use ($lastSync) {
                    $query->where('created_at', '>', $lastSync)
                          ->orWhere('updated_at', '>', $lastSync);
                })
                ->get();
        }

        if (in_array('visites', $dataTypes)) {
            $data['visites'] = Visite::with(['pdv', 'commercial'])
                ->where(function ($query) use ($lastSync) {
                    $query->where('created_at', '>', $lastSync)
                          ->orWhere('updated_at', '>', $lastSync);
                })
                ->get();
        }

        if (in_array('users', $dataTypes)) {
            $data['users'] = User::with('roles')
                ->where(function ($query) use ($lastSync) {
                    $query->where('created_at', '>', $lastSync)
                          ->orWhere('updated_at', '>', $lastSync);
                })
                ->get();
        }

        return response()->json([
            'data' => $data,
            'sync_timestamp' => now(),
            'data_count' => array_sum(array_map('count', $data)),
        ]);
    }

    /**
     * Upload des données créées/modifiées hors ligne
     */
    public function upload(Request $request): JsonResponse
    {
        $user = $request->user();
        $request->validate([
            'data' => 'required|array',
            'data.pdvs' => 'nullable|array',
            'data.visites' => 'nullable|array',
            'data.users' => 'nullable|array',
            'device_id' => 'required|string',
            'sync_timestamp' => 'required|date',
        ]);

        $results = [
            'success' => [],
            'errors' => [],
            'conflicts' => [],
        ];

        DB::beginTransaction();
        try {
            // Traiter les PDV
            if (!empty($request->data['pdvs'])) {
                foreach ($request->data['pdvs'] as $pdvData) {
                    $result = $this->processPDV($pdvData, $user);
                    $this->categorizeResult($result, $results);
                }
            }

            // Traiter les visites
            if (!empty($request->data['visites'])) {
                foreach ($request->data['visites'] as $visiteData) {
                    $result = $this->processVisite($visiteData, $user);
                    $this->categorizeResult($result, $results);
                }
            }

            // Traiter les utilisateurs
            if (!empty($request->data['users'])) {
                foreach ($request->data['users'] as $userData) {
                    $result = $this->processUser($userData, $user);
                    $this->categorizeResult($result, $results);
                }
            }

            DB::commit();

            return response()->json([
                'message' => 'Synchronisation réussie',
                'results' => $results,
                'sync_timestamp' => now(),
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Erreur de synchronisation', [
                'user_id' => $user->id,
                'error' => $e->getMessage(),
                'data' => $request->data,
            ]);

            return response()->json([
                'message' => 'Erreur lors de la synchronisation',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Résoudre les conflits de synchronisation
     */
    public function resolveConflict(Request $request): JsonResponse
    {
        $request->validate([
            'entity_type' => 'required|string|in:pdv,visite,user',
            'entity_id' => 'required',
            'resolution' => 'required|string|in:server,client,merge',
            'client_data' => 'nullable|array',
            'server_data' => 'nullable|array',
        ]);

        $entityType = $request->entity_type;
        $entityId = $request->entity_id;
        $resolution = $request->resolution;

        try {
            switch ($entityType) {
                case 'pdv':
                    $entity = PDV::findOrFail($entityId);
                    break;
                case 'visite':
                    $entity = Visite::findOrFail($entityId);
                    break;
                case 'user':
                    $entity = User::findOrFail($entityId);
                    break;
                default:
                    throw new \Exception('Type d\'entité non supporté');
            }

            switch ($resolution) {
                case 'server':
                    // Garder les données du serveur
                    break;
                case 'client':
                    // Appliquer les données du client
                    if ($request->client_data) {
                        $entity->update($request->client_data);
                    }
                    break;
                case 'merge':
                    // Fusionner intelligemment les données
                    if ($request->client_data && $request->server_data) {
                        $mergedData = $this->mergeData($request->server_data, $request->client_data);
                        $entity->update($mergedData);
                    }
                    break;
            }

            return response()->json([
                'message' => 'Conflit résolu avec succès',
                'entity' => $entity,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erreur lors de la résolution du conflit',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Traiter un PDV
     */
    private function processPDV(array $pdvData, User $user): array
    {
        try {
            if (isset($pdvData['id']) && PDV::find($pdvData['id'])) {
                // Mise à jour
                $pdv = PDV::find($pdvData['id']);
                $pdv->update($pdvData);
                return ['success' => true, 'action' => 'updated', 'id' => $pdv->id];
            } else {
                // Création
                $pdv = PDV::create($pdvData);
                return ['success' => true, 'action' => 'created', 'id' => $pdv->id];
            }
        } catch (\Exception $e) {
            return ['success' => false, 'error' => $e->getMessage(), 'data' => $pdvData];
        }
    }

    /**
     * Traiter une visite
     */
    private function processVisite(array $visiteData, User $user): array
    {
        try {
            if (isset($visiteData['id']) && Visite::find($visiteData['id'])) {
                // Mise à jour
                $visite = Visite::find($visiteData['id']);
                $visite->update($visiteData);
                return ['success' => true, 'action' => 'updated', 'id' => $visite->id];
            } else {
                // Création
                $visite = Visite::create($visiteData);
                return ['success' => true, 'action' => 'created', 'id' => $visite->id];
            }
        } catch (\Exception $e) {
            return ['success' => false, 'error' => $e->getMessage(), 'data' => $visiteData];
        }
    }

    /**
     * Traiter un utilisateur
     */
    private function processUser(array $userData, User $user): array
    {
        try {
            if (isset($userData['id']) && User::find($userData['id'])) {
                // Mise à jour
                $userModel = User::find($userData['id']);
                $userModel->update($userData);
                return ['success' => true, 'action' => 'updated', 'id' => $userModel->id];
            } else {
                // Création
                $userModel = User::create($userData);
                return ['success' => true, 'action' => 'created', 'id' => $userModel->id];
            }
        } catch (\Exception $e) {
            return ['success' => false, 'error' => $e->getMessage(), 'data' => $userData];
        }
    }

    /**
     * Catégoriser le résultat
     */
    private function categorizeResult(array $result, array &$results): void
    {
        if ($result['success']) {
            $results['success'][] = $result;
        } else {
            $results['errors'][] = $result;
        }
    }

    /**
     * Déterminer si une synchronisation est recommandée
     */
    private function shouldSync(array $changes): bool
    {
        $totalChanges = array_sum(array_map('array_sum', $changes));
        return $totalChanges > 10; // Synchroniser si plus de 10 changements
    }

    /**
     * Fusionner intelligemment les données
     */
    private function mergeData(array $serverData, array $clientData): array
    {
        // Logique de fusion basée sur la priorité et la fraîcheur des données
        $merged = $serverData;
        
        foreach ($clientData as $key => $value) {
            if (!isset($merged[$key]) || $this->isClientDataNewer($key, $value, $merged[$key])) {
                $merged[$key] = $value;
            }
        }
        
        return $merged;
    }

    /**
     * Vérifier si les données client sont plus récentes
     */
    private function isClientDataNewer(string $key, $clientValue, $serverValue): bool
    {
        // Logique pour déterminer quelle donnée est plus récente
        // À adapter selon vos besoins
        return true;
    }
} 