<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Visite;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class VisiteController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Visite::query();

        // Filtres
        if ($request->has('pdv_id')) {
            $query->where('pdv_id', $request->pdv_id);
        }

        if ($request->has('commercial_id')) {
            $query->where('commercial_id', $request->commercial_id);
        }

        if ($request->has('statut')) {
            $query->where('statut', $request->statut);
        }

        if ($request->has('date_from')) {
            $query->whereDate('date_visite', '>=', $request->date_from);
        }

        if ($request->has('date_to')) {
            $query->whereDate('date_visite', '<=', $request->date_to);
        }

        // Recherche
        if ($request->has('search')) {
            $search = $request->search;
            $query->whereHas('pdv', function ($q) use ($search) {
                $q->where('nom', 'ilike', "%{$search}%");
            });
        }

        $visites = $query->with(['pdv', 'commercial'])
            ->orderBy('date_visite', 'desc')
            ->paginate($request->get('per_page', 15));

        return response()->json($visites);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'pdv_id' => 'required|exists:pdvs,id',
            'commercial_id' => 'required|exists:users,id',
            'date_visite' => 'required|date',
            'heure_debut' => 'nullable|date',
            'heure_fin' => 'nullable|date|after:heure_debut',
            'latitude_debut' => 'nullable|numeric',
            'longitude_debut' => 'nullable|numeric',
            'latitude_fin' => 'nullable|numeric',
            'longitude_fin' => 'nullable|numeric',
            'statut' => 'required|string',
            'notes' => 'nullable|string',
            'produits_verifies' => 'nullable|array',
            'prix_verifies' => 'nullable|array',
            'photos' => 'nullable|array',
            'signature' => 'nullable|string',
        ]);

        $visite = Visite::create($validated);

        // Mettre à jour la dernière visite du PDV
        $visite->pdv->update(['derniere_visite' => now()]);

        return response()->json($visite->load(['pdv', 'commercial']), 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Visite $visite): JsonResponse
    {
        return response()->json($visite->load(['pdv', 'commercial']));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Visite $visite): JsonResponse
    {
        $validated = $request->validate([
            'heure_debut' => 'nullable|date',
            'heure_fin' => 'nullable|date|after:heure_debut',
            'latitude_debut' => 'nullable|numeric',
            'longitude_debut' => 'nullable|numeric',
            'latitude_fin' => 'nullable|numeric',
            'longitude_fin' => 'nullable|numeric',
            'statut' => 'sometimes|string',
            'notes' => 'nullable|string',
            'produits_verifies' => 'nullable|array',
            'prix_verifies' => 'nullable|array',
            'photos' => 'nullable|array',
            'signature' => 'nullable|string',
        ]);

        $visite->update($validated);

        return response()->json($visite->load(['pdv', 'commercial']));
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Visite $visite): JsonResponse
    {
        $visite->delete();

        return response()->json(null, 204);
    }

    /**
     * Get statistics for visits
     */
    public function statistics(Request $request): JsonResponse
    {
        $request->validate([
            'period' => 'required|in:today,week,month,year',
        ]);

        $period = $request->period;
        $query = Visite::query();

        switch ($period) {
            case 'today':
                $query->whereDate('date_visite', now()->toDateString());
                break;
            case 'week':
                $query->whereBetween('date_visite', [
                    now()->startOfWeek(),
                    now()->endOfWeek()
                ]);
                break;
            case 'month':
                $query->whereMonth('date_visite', now()->month)
                      ->whereYear('date_visite', now()->year);
                break;
            case 'year':
                $query->whereYear('date_visite', now()->year);
                break;
        }

        $stats = [
            'total' => $query->count(),
            'terminees' => (clone $query)->where('statut', 'terminee')->count(),
            'en_cours' => (clone $query)->where('statut', 'en_cours')->count(),
            'annulees' => (clone $query)->where('statut', 'annulee')->count(),
            'moyenne_duree' => $query->get()->avg(function ($visite) {
                if ($visite->heure_debut && $visite->heure_fin) {
                    return $visite->heure_debut->diffInMinutes($visite->heure_fin);
                }
                return 0;
            }),
        ];

        return response()->json($stats);
    }

    /**
     * Start a visit
     */
    public function startVisit(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'visite_id' => 'required|exists:visites,id',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'timestamp' => 'required|date',
        ]);

        $visite = Visite::findOrFail($validated['visite_id']);

        // Vérifier que l'utilisateur est autorisé
        if ($visite->commercial_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Non autorisé pour cette visite'
            ], 403);
        }

        // Vérifier que la visite n'est pas déjà commencée
        if ($visite->statut === 'en_cours' || $visite->statut === 'terminee') {
            return response()->json([
                'message' => 'La visite est déjà commencée ou terminée'
            ], 400);
        }

        $visite->update([
            'statut' => 'en_cours',
            'heure_debut' => $validated['timestamp'],
            'latitude_debut' => $validated['latitude'],
            'longitude_debut' => $validated['longitude'],
        ]);

        return response()->json([
            'message' => 'Visite démarrée avec succès',
            'visite' => $visite->load(['pdv', 'commercial'])
        ]);
    }

    /**
     * End a visit
     */
    public function endVisit(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'visite_id' => 'required|exists:visites,id',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'timestamp' => 'required|date',
            'notes' => 'nullable|string',
            'produits_verifies' => 'nullable|array',
            'prix_verifies' => 'nullable|array',
        ]);

        $visite = Visite::findOrFail($validated['visite_id']);

        // Vérifier que l'utilisateur est autorisé
        if ($visite->commercial_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Non autorisé pour cette visite'
            ], 403);
        }

        // Vérifier que la visite est en cours
        if ($visite->statut !== 'en_cours') {
            return response()->json([
                'message' => 'La visite doit être en cours pour être terminée'
            ], 400);
        }

        $updateData = [
            'statut' => 'terminee',
            'heure_fin' => $validated['timestamp'],
            'latitude_fin' => $validated['latitude'],
            'longitude_fin' => $validated['longitude'],
        ];

        if (isset($validated['notes'])) {
            $updateData['notes'] = $validated['notes'];
        }
        if (isset($validated['produits_verifies'])) {
            $updateData['produits_verifies'] = $validated['produits_verifies'];
        }
        if (isset($validated['prix_verifies'])) {
            $updateData['prix_verifies'] = $validated['prix_verifies'];
        }

        $visite->update($updateData);

        // Mettre à jour la dernière visite du PDV
        $visite->pdv->update(['derniere_visite' => $validated['timestamp']]);

        return response()->json([
            'message' => 'Visite terminée avec succès',
            'visite' => $visite->load(['pdv', 'commercial'])
        ]);
    }

    /**
     * Upload photo for a visit
     */
    public function uploadPhoto(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'visite_id' => 'required|exists:visites,id',
            'photo' => 'required|image|mimes:jpeg,png,jpg|max:5120', // 5MB max
            'type' => 'required|string|in:avant,apres,produit,signature',
            'description' => 'nullable|string',
        ]);

        $visite = Visite::findOrFail($validated['visite_id']);

        // Vérifier que l'utilisateur est autorisé
        if ($visite->commercial_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Non autorisé pour cette visite'
            ], 403);
        }

        // Traitement du fichier photo
        $photo = $request->file('photo');
        $filename = time() . '_' . $visite->id . '_' . $validated['type'] . '.' . $photo->extension();
        $path = $photo->storeAs('visites/photos', $filename, 'public');

        // Ajouter la photo au tableau des photos existantes
        $photos = $visite->photos ?? [];
        $photos[] = [
            'filename' => $filename,
            'path' => $path,
            'type' => $validated['type'],
            'description' => $validated['description'] ?? '',
            'uploaded_at' => now()->toISOString(),
        ];

        $visite->update(['photos' => $photos]);

        return response()->json([
            'message' => 'Photo uploadée avec succès',
            'photo' => [
                'filename' => $filename,
                'path' => $path,
                'url' => asset('storage/' . $path),
                'type' => $validated['type'],
            ]
        ]);
    }

    /**
     * Upload signature for a visit
     */
    public function uploadSignature(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'visite_id' => 'required|exists:visites,id',
            'signature' => 'required|string', // Base64 encoded signature
            'signer_name' => 'nullable|string',
        ]);

        $visite = Visite::findOrFail($validated['visite_id']);

        // Vérifier que l'utilisateur est autorisé
        if ($visite->commercial_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Non autorisé pour cette visite'
            ], 403);
        }

        // Traitement de la signature (base64)
        $signatureData = $validated['signature'];
        if (preg_match('/^data:image\/(\w+);base64,/', $signatureData, $type)) {
            $signatureData = substr($signatureData, strpos($signatureData, ',') + 1);
            $signatureData = base64_decode($signatureData);
            
            $filename = 'signature_' . time() . '_' . $visite->id . '.png';
            $path = 'visites/signatures/' . $filename;
            
            // Sauvegarder le fichier
            file_put_contents(storage_path('app/public/' . $path), $signatureData);
            
            $visite->update([
                'signature' => [
                    'filename' => $filename,
                    'path' => $path,
                    'signer_name' => $validated['signer_name'] ?? '',
                    'signed_at' => now()->toISOString(),
                ]
            ]);

            return response()->json([
                'message' => 'Signature enregistrée avec succès',
                'signature' => [
                    'filename' => $filename,
                    'path' => $path,
                    'url' => asset('storage/' . $path),
                ]
            ]);
        }

        return response()->json([
            'message' => 'Format de signature invalide'
        ], 400);
    }
} 