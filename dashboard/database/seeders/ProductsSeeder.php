<?php

namespace Database\Seeders;

use App\Models\Product;
use Illuminate\Database\Seeder;

class ProductsSeeder extends Seeder
{
    public function run()
    {
        $products = [
            // Produits EVAP
            [
                'code' => 'EVAP-BR-GOLD',
                'name' => 'EVAP-BR Gold : 275 FCFA (manquant 12)',
                'category' => 'EVAP',
                'price' => 275,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Lait évaporé Gold - Manquant 12 unités',
            ],
            [
                'code' => 'EVAP-BR-160G',
                'name' => 'EVAP-BR 160g : 250 FCFA (manquant 18)',
                'category' => 'EVAP',
                'price' => 250,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Lait évaporé 160g - Manquant 18 unités',
            ],
            [
                'code' => 'EVAP-BRB-160G',
                'name' => 'EVAP-BRB 160g : 190 FCFA (manquant 12)',
                'category' => 'EVAP',
                'price' => 190,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Lait évaporé BRB 160g - Manquant 12 unités',
            ],
            [
                'code' => 'EVAP-BR-400G',
                'name' => 'EVAP-BR 400g : 495 FCFA (manquant 10)',
                'category' => 'EVAP',
                'price' => 495,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Lait évaporé 400g - Manquant 10 unités',
            ],
            [
                'code' => 'EVAP-BRB-400G',
                'name' => 'EVAP-BRB 400g : 385 FCFA (manquant 6)',
                'category' => 'EVAP',
                'price' => 385,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Lait évaporé BRB 400g - Manquant 6 unités',
            ],
            [
                'code' => 'EVAP-PEARL-400G',
                'name' => 'EVAP-Pearl 400g : 330 FCFA (manquant 10)',
                'category' => 'EVAP',
                'price' => 330,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Lait évaporé Pearl 400g - Manquant 10 unités',
            ],

            // Produits SCM
            [
                'code' => 'SCM-BR-1KG',
                'name' => 'SCM-BR 1Kg : 1430 FCFA (manquant)',
                'category' => 'SCM',
                'price' => 1430,
                'stock_quantity' => 0,
                'unit' => 'kg',
                'description' => 'Lait en poudre SCM-BR 1kg',
            ],
            [
                'code' => 'SCM-BRB-1KG',
                'name' => 'SCM-BRB 1Kg : 715 FCFA (manquant)',
                'category' => 'SCM',
                'price' => 715,
                'stock_quantity' => 0,
                'unit' => 'kg',
                'description' => 'Lait en poudre SCM-BRB 1kg',
            ],
            [
                'code' => 'SCM-BRB-397G',
                'name' => 'SCM-BRB 397g : 825 FCFA (manquant)',
                'category' => 'SCM',
                'price' => 825,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Lait en poudre SCM-BRB 397g',
            ],
            [
                'code' => 'SCM-BR-397G',
                'name' => 'SCM-BR 397g : 825 FCFA (manquant)',
                'category' => 'SCM',
                'price' => 825,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Lait en poudre SCM-BR 397g',
            ],
            [
                'code' => 'SCM-PEARL-1KG',
                'name' => 'SCM-Pearl 1Kg : 605 FCFA (manquant 3)',
                'category' => 'SCM',
                'price' => 605,
                'stock_quantity' => 0,
                'unit' => 'kg',
                'description' => 'Lait en poudre SCM-Pearl 1kg - Manquant 3 unités',
            ],

            // Produits IMP
            [
                'code' => 'IMP-BR-400G',
                'name' => 'IMP-BR 400g : 495 FCFA (manquant 3)',
                'category' => 'IMP',
                'price' => 495,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Lait IMP-BR 400g - Manquant 3 unités',
            ],
            [
                'code' => 'IMP-BR-900G',
                'name' => 'IMP-BR 900g : 3025 FCFA (manquant)',
                'category' => 'IMP',
                'price' => 3025,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Lait IMP-BR 900g',
            ],
            [
                'code' => 'IMP-BR-2.5KG',
                'name' => 'IMP-BR 2.5 Kg : 7425 FCFA (manquant)',
                'category' => 'IMP',
                'price' => 7425,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Lait IMP-BR 2.5kg',
            ],
            [
                'code' => 'IMP-BR-375G',
                'name' => 'IMP-BR 375g : 990 FCFA (manquant 3)',
                'category' => 'IMP',
                'price' => 990,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Lait IMP-BR 375g - Manquant 3 unités',
            ],
            [
                'code' => 'IMP-BRB-400G',
                'name' => 'IMP-BRB 400g : 825 FCFA (manquant 3)',
                'category' => 'IMP',
                'price' => 825,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Lait IMP-BRB 400g - Manquant 3 unités',
            ],
            [
                'code' => 'IMP-BR-20G',
                'name' => 'IMP-BR 20g : 55 FCFA (manquant 3)',
                'category' => 'IMP',
                'price' => 55,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Lait IMP-BR 20g - Manquant 3 unités',
            ],
            [
                'code' => 'IMP-BRB-25G',
                'name' => 'IMP-BRB 25g : 55 FCFA (manquant 3)',
                'category' => 'IMP',
                'price' => 55,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Lait IMP-BRB 25g - Manquant 3 unités',
            ],

            // Produits UHT
            [
                'code' => 'UHT-DEMI-ECREME',
                'name' => 'UHT-Demi écrémé : 330 FCFA (manquant 3)',
                'category' => 'UHT',
                'price' => 330,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Lait UHT demi-écrémé - Manquant 3 unités',
            ],
            [
                'code' => 'UHT-ELOPACK-500ML',
                'name' => 'UHT-Elopack 500 ml : 330 FCFA (manquant 3)',
                'category' => 'UHT',
                'price' => 330,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Lait UHT Elopack 500ml - Manquant 3 unités',
            ],
            [
                'code' => 'UHT-BRIQUE-1L',
                'name' => 'UHT-Brique 1L : 330 FCFA (manquant 3)',
                'category' => 'UHT',
                'price' => 330,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Lait UHT brique 1L - Manquant 3 unités',
            ],

            // Produits YAOURT
            [
                'code' => 'YAOURT-BR-YOGOO-NATURE-MINI-90ML',
                'name' => 'YAOURT-BR Yogoo nature mini 90 ml : 135 FCFA (manquant 6)',
                'category' => 'YAOURT',
                'price' => 135,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Yaourt Yogoo nature mini 90ml - Manquant 6 unités',
            ],
            [
                'code' => 'YAOURT-BR-YOGOO-FRAISE-MINI-90ML',
                'name' => 'YAOURT-BR Yogoo fraise mini 90 ml : 330 FCFA (manquant 3)',
                'category' => 'YAOURT',
                'price' => 330,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Yaourt Yogoo fraise mini 90ml - Manquant 3 unités',
            ],
            [
                'code' => 'YAOURT-BR-YOGOO-FRAISE-MAXI-318ML',
                'name' => 'YAOURT-BR Yogoo fraise maxi 318 ml : 135 FCFA (manquant 6)',
                'category' => 'YAOURT',
                'price' => 135,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Yaourt Yogoo fraise maxi 318ml - Manquant 6 unités',
            ],
            [
                'code' => 'YAOURT-BR-YOGOO-NATURE-MAXI-318ML',
                'name' => 'YAOURT-BR Yogoo nature maxi 318 ml : 330 FCFA (manquant 0)',
                'category' => 'YAOURT',
                'price' => 330,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Yaourt Yogoo nature maxi 318ml',
            ],

            // Produits CÉRÉALES AU LAIT
            [
                'code' => 'CEREALES-AU-LAIT-BRCV',
                'name' => 'Céréales au lait-BRCV : 330 FCFA (manquant 3)',
                'category' => 'CÉRÉALES AU LAIT',
                'price' => 330,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Céréales au lait BRCV - Manquant 3 unités',
            ],
            [
                'code' => 'CEREALES-AU-LAIT-BRCC',
                'name' => 'Céréales au lait-BRCC : 330 FCFA (manquant 3)',
                'category' => 'CÉRÉALES AU LAIT',
                'price' => 330,
                'stock_quantity' => 0,
                'unit' => 'unité',
                'description' => 'Céréales au lait BRCC - Manquant 3 unités',
            ],
        ];

        foreach ($products as $product) {
            Product::create($product);
        }
    }
}
