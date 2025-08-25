<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Product;

class RealProductSeeder extends Seeder
{
    /**
     * Seeder pour les vrais produits Friesland Campina selon CLAUDE.md
     */
    public function run(): void
    {
        $this->command->info('🥛 Ajout des vrais produits Friesland Campina...');

        // Vider la table des produits existants
        Product::truncate();

        // Produits EVAP (Lait Évaporé)
        $this->createEvapProducts();
        
        // Produits IMP (Lait en Poudre Importé)  
        $this->createImpProducts();
        
        // Produits SCM (Lait en Poudre Sucré)
        $this->createScmProducts();
        
        // Produits UHT (Lait UHT)
        $this->createUhtProducts();
        
        // Produits YAOURT
        $this->createYaourtProducts();

        $this->command->info('✅ Tous les produits Friesland Campina ont été ajoutés !');
    }

    /**
     * Produits EVAP selon CLAUDE.md
     */
    private function createEvapProducts(): void
    {
        $evapProducts = [
            [
                'code' => 'BR_GOLD_400G',
                'name' => 'Bonnet Rouge Gold 400g',
                'price' => 850.00,
                'description' => 'Lait évaporé Gold premium 400g'
            ],
            [
                'code' => 'BR_150G',
                'name' => 'Bonnet Rouge 150g',
                'price' => 325.00,
                'description' => 'Lait évaporé Bonnet Rouge 150g format pratique'
            ],
            [
                'code' => 'BRB_150G',
                'name' => 'Bonnet Rouge Bleu 150g',
                'price' => 350.00,
                'description' => 'Lait évaporé Bonnet Rouge Bleu 150g'
            ],
            [
                'code' => 'BR_380G',
                'name' => 'Bonnet Rouge 380g',
                'price' => 750.00,
                'description' => 'Lait évaporé Bonnet Rouge 380g format familial'
            ],
            [
                'code' => 'BRB_380G',
                'name' => 'Bonnet Rouge Bleu 380g',
                'price' => 780.00,
                'description' => 'Lait évaporé Bonnet Rouge Bleu 380g'
            ],
            [
                'code' => 'PEARL_380G',
                'name' => 'Pearl 380g',
                'price' => 720.00,
                'description' => 'Lait évaporé Pearl 380g gamme économique'
            ]
        ];

        foreach ($evapProducts as $product) {
            Product::create([
                'code' => $product['code'],
                'name' => $product['name'],
                'category' => 'EVAP',
                'price' => $product['price'],
                'stock_quantity' => 100,
                'unit' => 'boîte',
                'description' => $product['description'],
                'is_active' => true,
            ]);
        }

        $this->command->info('   ✓ Produits EVAP créés (6 produits)');
    }

    /**
     * Produits IMP selon CLAUDE.md
     */
    private function createImpProducts(): void
    {
        $impProducts = [
            [
                'code' => 'BR_2_SACHET',
                'name' => 'Bonnet Rouge 2 (sachet)',
                'price' => 25.00,
                'description' => 'Lait en poudre Bonnet Rouge format sachet 2'
            ],
            [
                'code' => 'BR_16G',
                'name' => 'Bonnet Rouge 16g',
                'price' => 50.00,
                'description' => 'Lait en poudre Bonnet Rouge 16g portion individuelle'
            ],
            [
                'code' => 'BRB_16G',
                'name' => 'Bonnet Rouge Bleu 16g',
                'price' => 55.00,
                'description' => 'Lait en poudre Bonnet Rouge Bleu 16g'
            ],
            [
                'code' => 'BR_360G',
                'name' => 'Bonnet Rouge 360g',
                'price' => 1250.00,
                'description' => 'Lait en poudre Bonnet Rouge 360g boîte'
            ],
            [
                'code' => 'BR_400G_TIN',
                'name' => 'Bonnet Rouge 400g Tin',
                'price' => 1350.00,
                'description' => 'Lait en poudre Bonnet Rouge 400g boîte métal'
            ],
            [
                'code' => 'BRB_360G',
                'name' => 'Bonnet Rouge Bleu 360g',
                'price' => 1300.00,
                'description' => 'Lait en poudre Bonnet Rouge Bleu 360g'
            ],
            [
                'code' => 'BR_900G_TIN',
                'name' => 'Bonnet Rouge 900g Tin',
                'price' => 2950.00,
                'description' => 'Lait en poudre Bonnet Rouge 900g grand format'
            ]
        ];

        foreach ($impProducts as $product) {
            Product::create([
                'code' => $product['code'],
                'name' => $product['name'],
                'category' => 'IMP',
                'price' => $product['price'],
                'stock_quantity' => 150,
                'unit' => strpos($product['code'], 'SACHET') !== false ? 'sachet' : 'boîte',
                'description' => $product['description'],
                'is_active' => true,
            ]);
        }

        $this->command->info('   ✓ Produits IMP créés (7 produits)');
    }

    /**
     * Produits SCM selon CLAUDE.md
     */
    private function createScmProducts(): void
    {
        $scmProducts = [
            [
                'code' => 'BR_SCM_400G',
                'name' => 'Bonnet Rouge SCM 400g',
                'price' => 1150.00,
                'description' => 'Lait concentré sucré Bonnet Rouge 400g'
            ],
            [
                'code' => 'BR_SCM_200G',
                'name' => 'Bonnet Rouge SCM 200g',
                'price' => 650.00,
                'description' => 'Lait concentré sucré Bonnet Rouge 200g format pratique'
            ],
            [
                'code' => 'PEAK_SCM_400G',
                'name' => 'Peak SCM 400g',
                'price' => 1200.00,
                'description' => 'Lait concentré sucré Peak 400g'
            ],
            [
                'code' => 'PEAK_SCM_200G',
                'name' => 'Peak SCM 200g',
                'price' => 680.00,
                'description' => 'Lait concentré sucré Peak 200g'
            ]
        ];

        foreach ($scmProducts as $product) {
            Product::create([
                'code' => $product['code'],
                'name' => $product['name'],
                'category' => 'SCM',
                'price' => $product['price'],
                'stock_quantity' => 80,
                'unit' => 'boîte',
                'description' => $product['description'],
                'is_active' => true,
            ]);
        }

        $this->command->info('   ✓ Produits SCM créés (4 produits)');
    }

    /**
     * Produits UHT selon CLAUDE.md
     */
    private function createUhtProducts(): void
    {
        $uhtProducts = [
            [
                'code' => 'BR_UHT_1L',
                'name' => 'Bonnet Rouge UHT 1L',
                'price' => 450.00,
                'description' => 'Lait UHT Bonnet Rouge 1 litre'
            ],
            [
                'code' => 'BR_UHT_500ML',
                'name' => 'Bonnet Rouge UHT 500ml',
                'price' => 250.00,
                'description' => 'Lait UHT Bonnet Rouge 500ml format individuel'
            ],
            [
                'code' => 'BR_UHT_250ML',
                'name' => 'Bonnet Rouge UHT 250ml',
                'price' => 150.00,
                'description' => 'Lait UHT Bonnet Rouge 250ml petit format'
            ],
            [
                'code' => 'PEAK_UHT_1L',
                'name' => 'Peak UHT 1L',
                'price' => 480.00,
                'description' => 'Lait UHT Peak 1 litre premium'
            ]
        ];

        foreach ($uhtProducts as $product) {
            Product::create([
                'code' => $product['code'],
                'name' => $product['name'],
                'category' => 'UHT',
                'price' => $product['price'],
                'stock_quantity' => 200,
                'unit' => 'brique',
                'description' => $product['description'],
                'is_active' => true,
            ]);
        }

        $this->command->info('   ✓ Produits UHT créés (4 produits)');
    }

    /**
     * Produits YAOURT selon CLAUDE.md
     */
    private function createYaourtProducts(): void
    {
        $yaourtProducts = [
            [
                'code' => 'BR_YAOURT_125G_NATURE',
                'name' => 'Yaourt Bonnet Rouge Nature 125g',
                'price' => 200.00,
                'description' => 'Yaourt nature Bonnet Rouge 125g'
            ],
            [
                'code' => 'BR_YAOURT_125G_VANILLE',
                'name' => 'Yaourt Bonnet Rouge Vanille 125g',
                'price' => 220.00,
                'description' => 'Yaourt vanille Bonnet Rouge 125g'
            ],
            [
                'code' => 'BR_YAOURT_125G_FRAISE',
                'name' => 'Yaourt Bonnet Rouge Fraise 125g',
                'price' => 220.00,
                'description' => 'Yaourt fraise Bonnet Rouge 125g'
            ],
            [
                'code' => 'BR_YAOURT_500G_NATURE',
                'name' => 'Yaourt Bonnet Rouge Nature 500g',
                'price' => 750.00,
                'description' => 'Yaourt nature Bonnet Rouge 500g format familial'
            ],
            [
                'code' => 'PEAK_YAOURT_125G_NATURE',
                'name' => 'Yaourt Peak Nature 125g',
                'price' => 250.00,
                'description' => 'Yaourt nature Peak 125g premium'
            ]
        ];

        foreach ($yaourtProducts as $product) {
            Product::create([
                'code' => $product['code'],
                'name' => $product['name'],
                'category' => 'YAOURT',
                'price' => $product['price'],
                'stock_quantity' => 120,
                'unit' => 'pot',
                'description' => $product['description'],
                'is_active' => true,
            ]);
        }

        $this->command->info('   ✓ Produits YAOURT créés (5 produits)');
    }
}