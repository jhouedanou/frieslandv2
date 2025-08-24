<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class ProductController extends Controller
{
    /**
     * Liste des produits Friesland
     */
    public function index(Request $request): JsonResponse
    {
        // Données statiques des produits Friesland
        $products = [
            [
                'id' => 1,
                'name' => 'Peak Milk Powder',
                'category' => 'Dairy',
                'brand' => 'Peak',
                'sku' => 'PEAK_MP_400G',
                'size' => '400g',
                'unit_price' => 850,
                'active' => true,
            ],
            [
                'id' => 2,
                'name' => 'Three Crowns Milk',
                'category' => 'Dairy',
                'brand' => 'Three Crowns',
                'sku' => 'TC_MILK_400G',
                'size' => '400g',
                'unit_price' => 800,
                'active' => true,
            ],
            [
                'id' => 3,
                'name' => 'Completa Milk',
                'category' => 'Dairy',
                'brand' => 'Completa',
                'sku' => 'COMP_MILK_400G',
                'size' => '400g',
                'unit_price' => 750,
                'active' => true,
            ],
            [
                'id' => 4,
                'name' => 'Friso Growing Up Milk',
                'category' => 'Baby Formula',
                'brand' => 'Friso',
                'sku' => 'FRISO_GUM_400G',
                'size' => '400g',
                'unit_price' => 1200,
                'active' => true,
            ],
            [
                'id' => 5,
                'name' => 'Friso Gold Formula',
                'category' => 'Baby Formula',
                'brand' => 'Friso',
                'sku' => 'FRISO_GOLD_400G',
                'size' => '400g',
                'unit_price' => 1500,
                'active' => true,
            ],
        ];

        // Filtres
        if ($request->has('category')) {
            $products = array_filter($products, function ($product) use ($request) {
                return strtolower($product['category']) === strtolower($request->category);
            });
        }

        if ($request->has('brand')) {
            $products = array_filter($products, function ($product) use ($request) {
                return strtolower($product['brand']) === strtolower($request->brand);
            });
        }

        if ($request->has('active')) {
            $isActive = filter_var($request->active, FILTER_VALIDATE_BOOLEAN);
            $products = array_filter($products, function ($product) use ($isActive) {
                return $product['active'] === $isActive;
            });
        }

        return response()->json([
            'products' => array_values($products),
            'total' => count($products),
        ]);
    }

    /**
     * Liste des catégories de produits
     */
    public function categories(Request $request): JsonResponse
    {
        $categories = [
            [
                'id' => 1,
                'name' => 'Dairy',
                'description' => 'Produits laitiers',
                'active' => true,
            ],
            [
                'id' => 2,
                'name' => 'Baby Formula',
                'description' => 'Laits infantiles',
                'active' => true,
            ],
            [
                'id' => 3,
                'name' => 'Beverages',
                'description' => 'Boissons',
                'active' => true,
            ],
        ];

        return response()->json([
            'categories' => $categories,
            'total' => count($categories),
        ]);
    }

    /**
     * Vérifier la présence d'un produit
     */
    public function verify(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'visite_id' => 'required|exists:visites,id',
            'product_id' => 'required|integer',
            'present' => 'required|boolean',
            'price' => 'nullable|numeric',
            'stock_level' => 'nullable|integer|min:0',
            'notes' => 'nullable|string',
        ]);

        // En réalité, ceci serait sauvegardé dans une table de vérification de produits
        // Pour l'instant, on retourne juste un succès

        return response()->json([
            'message' => 'Vérification de produit enregistrée',
            'data' => [
                'visite_id' => $validated['visite_id'],
                'product_id' => $validated['product_id'],
                'present' => $validated['present'],
                'price' => $validated['price'] ?? null,
                'stock_level' => $validated['stock_level'] ?? null,
                'verified_at' => now(),
            ],
        ]);
    }

    /**
     * Obtenir les produits pour une visite
     */
    public function getForVisit(Request $request, int $visiteId): JsonResponse
    {
        // Vérifier que la visite existe
        $visite = \App\Models\Visite::findOrFail($visiteId);

        // Vérifier que l'utilisateur est autorisé
        if ($visite->commercial_id !== $request->user()->id && !$request->user()->hasRole('admin')) {
            return response()->json([
                'message' => 'Non autorisé pour cette visite'
            ], 403);
        }

        // Retourner les produits avec leur statut de vérification pour cette visite
        $products = $this->index($request)->getData()->products;

        // En réalité, on joinderait avec les vérifications existantes
        foreach ($products as &$product) {
            $product->verification_status = null; // Non vérifié
            $product->verified_price = null;
            $product->stock_level = null;
        }

        return response()->json([
            'visite_id' => $visiteId,
            'products' => $products,
            'total' => count($products),
        ]);
    }
} 