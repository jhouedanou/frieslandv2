<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class ProductController extends Controller
{
    /**
     * Liste des produits Friesland depuis la base de données
     */
    public function index(Request $request): JsonResponse
    {
        $query = Product::query();

        // Filtres
        if ($request->has('category')) {
            $query->where('category', $request->category);
        }

        if ($request->has('active')) {
            $isActive = filter_var($request->active, FILTER_VALIDATE_BOOLEAN);
            $query->where('is_active', $isActive);
        } else {
            // Par défaut, ne montrer que les produits actifs
            $query->where('is_active', true);
        }

        // Tri par catégorie puis par nom
        $query->orderBy('category')->orderBy('name');

        $products = $query->get()->map(function ($product) {
            return [
                'id' => $product->id,
                'code' => $product->code,
                'name' => $product->name,
                'category' => $product->category,
                'price' => $product->price,
                'unit_price' => $product->price, // Alias pour compatibilité
                'stock_quantity' => $product->stock_quantity,
                'unit' => $product->unit,
                'description' => $product->description,
                'is_active' => $product->is_active,
                'active' => $product->is_active, // Alias pour compatibilité
                'created_at' => $product->created_at,
                'updated_at' => $product->updated_at,
            ];
        });

        return response()->json([
            'products' => $products,
            'total' => $products->count(),
            'categories' => Product::getCategories(),
        ]);
    }

    /**
     * Liste des catégories de produits depuis la base de données
     */
    public function categories(Request $request): JsonResponse
    {
        $categories = collect(Product::getCategories())->map(function ($label, $key) {
            return [
                'id' => $key,
                'name' => $key,
                'description' => $label,
                'display_name' => $label,
                'active' => true,
            ];
        })->values();

        return response()->json([
            'categories' => $categories,
            'total' => $categories->count(),
        ]);
    }

    /**
     * Obtenir les produits par catégorie
     */
    public function byCategory(Request $request): JsonResponse
    {
        $query = Product::where('is_active', true);

        $productsByCategory = $query->get()
            ->groupBy('category')
            ->map(function ($products, $category) {
                return [
                    'category' => $category,
                    'display_name' => Product::getCategories()[$category] ?? $category,
                    'products' => $products->map(function ($product) {
                        return [
                            'id' => $product->id,
                            'code' => $product->code,
                            'name' => $product->name,
                            'price' => $product->price,
                            'unit' => $product->unit,
                            'stock_quantity' => $product->stock_quantity,
                            'description' => $product->description,
                        ];
                    })->values(),
                ];
            })
            ->values();

        return response()->json([
            'categories' => $productsByCategory,
            'total_categories' => $productsByCategory->count(),
            'total_products' => $query->count(),
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