<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PDV;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class PDVController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): JsonResponse
    {
        $query = PDV::query();

        // Filtres
        if ($request->has('secteur')) {
            $query->where('secteur', $request->secteur);
        }

        if ($request->has('type_pdv')) {
            $query->where('type_pdv', $request->type_pdv);
        }

        if ($request->has('statut')) {
            $query->where('statut', $request->statut);
        }

        if ($request->has('commercial_id')) {
            $query->where('commercial_id', $request->commercial_id);
        }

        // Recherche
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('nom', 'ilike', "%{$search}%")
                  ->orWhere('ville', 'ilike', "%{$search}%")
                  ->orWhere('adresse', 'ilike', "%{$search}%");
            });
        }

        $pdvs = $query->with('commercial')->paginate($request->get('per_page', 15));

        return response()->json($pdvs);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'nom' => 'required|string|max:255',
            'adresse' => 'required|string',
            'ville' => 'required|string|max:100',
            'code_postal' => 'required|string|max:10',
            'pays' => 'required|string|max:100',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'type_pdv' => 'required|string',
            'secteur' => 'required|string',
            'commercial_id' => 'nullable|exists:users,id',
            'statut' => 'required|string',
            'notes' => 'nullable|string',
        ]);

        $pdv = PDV::create($validated);

        return response()->json($pdv->load('commercial'), 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(PDV $pdv): JsonResponse
    {
        return response()->json($pdv->load(['commercial', 'visites']));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, PDV $pdv): JsonResponse
    {
        $validated = $request->validate([
            'nom' => 'sometimes|string|max:255',
            'adresse' => 'sometimes|string',
            'ville' => 'sometimes|string|max:100',
            'code_postal' => 'sometimes|string|max:10',
            'pays' => 'sometimes|string|max:100',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'type_pdv' => 'sometimes|string',
            'secteur' => 'sometimes|string',
            'commercial_id' => 'nullable|exists:users,id',
            'statut' => 'sometimes|string',
            'notes' => 'nullable|string',
        ]);

        $pdv->update($validated);

        return response()->json($pdv->load('commercial'));
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(PDV $pdv): JsonResponse
    {
        $pdv->delete();

        return response()->json(null, 204);
    }

    /**
     * Get PDVs near a specific location
     */
    public function nearby(Request $request): JsonResponse
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'radius' => 'required|numeric|min:0.1|max:50', // km
        ]);

        $latitude = $request->latitude;
        $longitude = $request->longitude;
        $radius = $request->radius * 1000; // Convertir en mètres

        $pdvs = PDV::where('statut', 'actif')
            ->get()
            ->filter(function ($pdv) use ($latitude, $longitude, $radius) {
                $distance = $pdv->getDistanceFrom($latitude, $longitude);
                return $distance <= $radius;
            })
            ->sortBy(function ($pdv) use ($latitude, $longitude) {
                return $pdv->getDistanceFrom($latitude, $longitude);
            })
            ->values();

        return response()->json($pdvs);
    }
} 