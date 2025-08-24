<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class PriceController extends Controller
{
    /**
     * Vérifier un prix
     */
    public function verify(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'visite_id' => 'required|exists:visites,id',
            'product_id' => 'required|integer',
            'current_price' => 'required|numeric|min:0',
            'expected_price' => 'nullable|numeric|min:0',
            'currency' => 'required|string|in:XOF,EUR,USD',
            'notes' => 'nullable|string',
            'photo_url' => 'nullable|string',
        ]);

        // Enregistrer la vérification du prix
        // Dans une vraie application, ceci serait stocké en base

        $priceDifference = 0;
        $priceDifferencePercent = 0;
        
        if ($validated['expected_price']) {
            $priceDifference = $validated['current_price'] - $validated['expected_price'];
            $priceDifferencePercent = ($priceDifference / $validated['expected_price']) * 100;
        }

        // Déterminer le statut du prix
        $priceStatus = 'correct';
        if (abs($priceDifferencePercent) > 10) {
            $priceStatus = 'variance_high';
        } elseif (abs($priceDifferencePercent) > 5) {
            $priceStatus = 'variance_medium';
        }

        return response()->json([
            'message' => 'Vérification du prix enregistrée',
            'verification' => [
                'visite_id' => $validated['visite_id'],
                'product_id' => $validated['product_id'],
                'current_price' => $validated['current_price'],
                'expected_price' => $validated['expected_price'],
                'price_difference' => $priceDifference,
                'price_difference_percent' => round($priceDifferencePercent, 2),
                'price_status' => $priceStatus,
                'currency' => $validated['currency'],
                'verified_at' => now(),
            ],
        ]);
    }

    /**
     * Obtenir les prix de référence
     */
    public function reference(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'product_ids' => 'nullable|array',
            'product_ids.*' => 'integer',
            'region' => 'nullable|string',
        ]);

        // Prix de référence Friesland (données statiques pour l'exemple)
        $referencePrices = [
            1 => [
                'product_id' => 1,
                'product_name' => 'Peak Milk Powder',
                'recommended_price' => 850,
                'min_price' => 800,
                'max_price' => 900,
                'currency' => 'XOF',
                'region' => 'West Africa',
                'last_updated' => now()->subDays(7),
            ],
            2 => [
                'product_id' => 2,
                'product_name' => 'Three Crowns Milk',
                'recommended_price' => 800,
                'min_price' => 750,
                'max_price' => 850,
                'currency' => 'XOF',
                'region' => 'West Africa',
                'last_updated' => now()->subDays(7),
            ],
            3 => [
                'product_id' => 3,
                'product_name' => 'Completa Milk',
                'recommended_price' => 750,
                'min_price' => 700,
                'max_price' => 800,
                'currency' => 'XOF',
                'region' => 'West Africa',
                'last_updated' => now()->subDays(7),
            ],
            4 => [
                'product_id' => 4,
                'product_name' => 'Friso Growing Up Milk',
                'recommended_price' => 1200,
                'min_price' => 1150,
                'max_price' => 1250,
                'currency' => 'XOF',
                'region' => 'West Africa',
                'last_updated' => now()->subDays(7),
            ],
            5 => [
                'product_id' => 5,
                'product_name' => 'Friso Gold Formula',
                'recommended_price' => 1500,
                'min_price' => 1450,
                'max_price' => 1550,
                'currency' => 'XOF',
                'region' => 'West Africa',
                'last_updated' => now()->subDays(7),
            ],
        ];

        // Filtrer par product_ids si fourni
        if (!empty($validated['product_ids'])) {
            $referencePrices = array_filter($referencePrices, function($key) use ($validated) {
                return in_array($key, $validated['product_ids']);
            }, ARRAY_FILTER_USE_KEY);
        }

        return response()->json([
            'reference_prices' => array_values($referencePrices),
            'total' => count($referencePrices),
            'region' => $validated['region'] ?? 'West Africa',
            'currency' => 'XOF',
            'last_updated' => now()->subDays(7),
        ]);
    }

    /**
     * Obtenir l'historique des prix pour un produit
     */
    public function history(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'product_id' => 'required|integer',
            'pdv_id' => 'nullable|exists:pdvs,id',
            'period_days' => 'nullable|integer|min:1|max:365',
        ]);

        $periodDays = $validated['period_days'] ?? 30;
        
        // Générer un historique factice pour l'exemple
        $history = [];
        $basePrice = 850; // Prix de base
        
        for ($i = $periodDays; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $variation = (rand(-10, 10) / 100) * $basePrice; // Variation de ±10%
            $price = $basePrice + $variation;
            
            $history[] = [
                'date' => $date->toDateString(),
                'price' => round($price, 2),
                'currency' => 'XOF',
                'pdv_id' => $validated['pdv_id'] ?? null,
            ];
        }

        return response()->json([
            'product_id' => $validated['product_id'],
            'pdv_id' => $validated['pdv_id'] ?? null,
            'period_days' => $periodDays,
            'history' => $history,
            'average_price' => round(array_sum(array_column($history, 'price')) / count($history), 2),
            'min_price' => round(min(array_column($history, 'price')), 2),
            'max_price' => round(max(array_column($history, 'price')), 2),
        ]);
    }
} 