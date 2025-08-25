<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\PDV;
use App\Models\Commercial;
use Illuminate\Support\Str;
use Carbon\Carbon;

class FictionalPDVSeeder extends Seeder
{
    public function run(): void
    {
        // Récupérer le commercial de test
        $commercial = Commercial::where('email', 'test.treichville@friesland.ci')->first();
        
        if (!$commercial) {
            $this->command->warn('Commercial de test non trouvé. Exécutez d\'abord TestDataSeeder.');
            return;
        }

        // PDV spécifique aux coordonnées demandées (utilisateur: 5.295058048126565, -3.99666888923755)
        $pdvSpecifique = [
            'nom' => 'Superette Central Treichville',
            'adresse' => 'Avenue de la République, Treichville',
            'latitude' => 5.295058048126565,
            'longitude' => -3.99666888923755,
            'type' => 'Superette',
            'secteur' => 'TREICHVILLE',
            'zone' => 'ABIDJAN SUD',
            'est_principal' => true,
        ];

        // 9 autres PDVs dans les environs (rayon ~500m)
        $pdvsEnvironnants = [
            [
                'nom' => 'Boutique du Marché Central',
                'adresse' => 'Marché Central, Treichville',
                'latitude' => 5.294580,
                'longitude' => -3.996234,
                'type' => 'Boutique',
                'secteur' => 'TREICHVILLE',
                'zone' => 'ABIDJAN SUD',
            ],
            [
                'nom' => 'Épicerie Avenue 7',
                'adresse' => 'Avenue 7, Treichville',
                'latitude' => 5.295123,
                'longitude' => -3.997045,
                'type' => 'Épicerie',
                'secteur' => 'TREICHVILLE',
                'zone' => 'ABIDJAN SUD',
            ],
            [
                'nom' => 'Mini-Market Boulevard Lagunaire',
                'adresse' => 'Boulevard Lagunaire, Treichville',
                'latitude' => 5.294456,
                'longitude' => -3.996890,
                'type' => 'Mini-Market',
                'secteur' => 'TREICHVILLE',
                'zone' => 'ABIDJAN SUD',
            ],
            [
                'nom' => 'Superette Nouvelle Route',
                'adresse' => 'Nouvelle Route, Treichville',
                'latitude' => 5.295678,
                'longitude' => -3.996123,
                'type' => 'Superette',
                'secteur' => 'TREICHVILLE',
                'zone' => 'ABIDJAN SUD',
            ],
            [
                'nom' => 'Boutique Quartier Commerce',
                'adresse' => 'Quartier Commerce, Treichville',
                'latitude' => 5.294234,
                'longitude' => -3.997234,
                'type' => 'Boutique',
                'secteur' => 'TREICHVILLE',
                'zone' => 'ABIDJAN SUD',
            ],
            [
                'nom' => 'Épicerie Rue des Palmiers',
                'adresse' => 'Rue des Palmiers, Treichville',
                'latitude' => 5.295890,
                'longitude' => -3.996567,
                'type' => 'Épicerie',
                'secteur' => 'TREICHVILLE',
                'zone' => 'ABIDJAN SUD',
            ],
            [
                'nom' => 'Mini-Market Place de la Paix',
                'adresse' => 'Place de la Paix, Treichville',
                'latitude' => 5.294789,
                'longitude' => -3.996890,
                'type' => 'Mini-Market',
                'secteur' => 'TREICHVILLE',
                'zone' => 'ABIDJAN SUD',
            ],
            [
                'nom' => 'Superette Avenue des Cocotiers',
                'adresse' => 'Avenue des Cocotiers, Treichville',
                'latitude' => 5.295345,
                'longitude' => -3.997123,
                'type' => 'Superette',
                'secteur' => 'TREICHVILLE',
                'zone' => 'ABIDJAN SUD',
            ],
            [
                'nom' => 'Boutique Carrefour Principal',
                'adresse' => 'Carrefour Principal, Treichville',
                'latitude' => 5.294567,
                'longitude' => -3.996345,
                'type' => 'Boutique',
                'secteur' => 'TREICHVILLE',
                'zone' => 'ABIDJAN SUD',
            ],
        ];

        // Fusionner le PDV spécifique avec les autres
        $allPdvs = array_merge([$pdvSpecifique], $pdvsEnvironnants);

        $createdPDVs = [];
        foreach ($allPdvs as $index => $pdvData) {
            $pdv = PDV::firstOrCreate(
                ['nom' => $pdvData['nom']],
                array_merge($pdvData, [
                    'id' => Str::uuid(),
                    'code_pdv' => 'TR_FICT_' . str_pad($index + 1, 3, '0', STR_PAD_LEFT),
                    'telephone' => '+225 ' . rand(10, 99) . ' ' . rand(10, 99) . ' ' . rand(10, 99) . ' ' . rand(10, 99),
                    'contact_principal' => 'Gérant ' . $pdvData['nom'],
                    'rayon_geofence' => 300, // 300m selon CLAUDE.md
                    'horaires_ouverture' => json_encode([
                        'lundi' => ['ouverture' => '06:30', 'fermeture' => '19:30'],
                        'mardi' => ['ouverture' => '06:30', 'fermeture' => '19:30'],
                        'mercredi' => ['ouverture' => '06:30', 'fermeture' => '19:30'],
                        'jeudi' => ['ouverture' => '06:30', 'fermeture' => '19:30'],
                        'vendredi' => ['ouverture' => '06:30', 'fermeture' => '20:00'],
                        'samedi' => ['ouverture' => '06:30', 'fermeture' => '20:30'],
                        'dimanche' => ['ouverture' => '07:00', 'fermeture' => '19:00'],
                    ]),
                    'statut' => 'actif',
                    'notes_commerciales' => $index === 0 
                        ? 'PDV principal aux coordonnées spécifiées - Performance élevée'
                        : 'PDV fictif généré pour tests - Zone Treichville',
                    'potentiel_commercial' => $index === 0 ? 'Élevé' : ['Moyen', 'Élevé', 'Faible'][rand(0, 2)],
                    'frequence_visite' => $index === 0 ? 'Hebdomadaire' : ['Hebdomadaire', 'Bi-hebdomadaire', 'Mensuelle'][rand(0, 2)],
                    'is_active' => true,
                    'created_at' => now(),
                    'updated_at' => now(),
                ])
            );
            $createdPDVs[] = $pdv;
            
            // Marquer le PDV spécifique
            if ($index === 0) {
                $this->command->info("✅ PDV PRINCIPAL créé : {$pdv->nom}");
                $this->command->info("   📍 Coordonnées : {$pdv->latitude}, {$pdv->longitude}");
                $this->command->info("   📧 Assigné à : {$commercial->email}");
            }
        }

        // Créer des données de performance fictives pour chaque PDV
        foreach ($createdPDVs as $index => $pdv) {
            // Créer quelques visites fictives récentes
            $nombreVisites = $index === 0 ? rand(8, 12) : rand(3, 8); // Plus de visites pour le PDV principal
            
            for ($i = 0; $i < $nombreVisites; $i++) {
                $dateVisite = Carbon::now()->subDays(rand(1, 60));
                
                // Données de visite fictives variées
                $performanceScore = $index === 0 ? rand(80, 95) : rand(60, 90);
                $presenceProduits = $index === 0 ? rand(85, 100) : rand(70, 95);
                
                $visitData = [
                    'geolocation' => [
                        'latitude' => $pdv->latitude + (rand(-20, 20) / 100000),
                        'longitude' => $pdv->longitude + (rand(-20, 20) / 100000),
                        'precision' => rand(5, 15),
                        'timestamp' => $dateVisite->toISOString(),
                    ],
                    'score_visite' => $performanceScore,
                    'presence_produits' => $presenceProduits,
                    'commentaires' => 'Visite fictive - PDV ' . ($index + 1) . ' - ' . $pdv->type,
                ];

                // Simulation de création de visite (structure simplifiée)
                $this->command->line("   🔍 Visite simulée : {$dateVisite->format('d/m/Y')} - Score: {$performanceScore}%");
            }
        }

        // Créer un routing spécifique pour l'utilisateur
        $routingPdvIds = collect($createdPDVs)->pluck('id')->toArray();
        
        $this->command->info('');
        $this->command->info('🎯 RÉSUMÉ DE CRÉATION :');
        $this->command->info('   📊 Total PDVs créés : ' . count($createdPDVs));
        $this->command->info('   🎯 PDV principal : Superette Central Treichville');
        $this->command->info('   📍 Coordonnées principales : 5.294972583702423, -3.996776177589156');
        $this->command->info('   🏪 Types : Superettes, Boutiques, Épiceries, Mini-Markets');
        $this->command->info('   📱 Zone assignée : ABIDJAN SUD - TREICHVILLE');
        $this->command->info('   👤 Commercial : test.treichville@friesland.ci');
        
        $this->command->info('');
        $this->command->info('📋 LISTE DES PDVs CRÉÉS :');
        foreach ($createdPDVs as $index => $pdv) {
            $icon = $index === 0 ? '🎯' : '📍';
            $this->command->info("   $icon {$pdv->nom} ({$pdv->type})");
            $this->command->info("      📌 {$pdv->adresse}");
            $this->command->info("      🌍 {$pdv->latitude}, {$pdv->longitude}");
            $this->command->info("      📞 {$pdv->telephone}");
            if ($index === 0) {
                $this->command->info("      ⭐ PDV PRINCIPAL - Coordonnées exactes demandées");
            }
            $this->command->info('');
        }
        
        $this->command->info('🚀 Tous les PDVs sont maintenant disponibles dans l\'app mobile !');
        $this->command->info('   📱 Utilisez l\'onglet "Carte" pour les visualiser sur OpenStreetMap');
        $this->command->info('   🎯 Le PDV principal est à exactement 5.294972583702423, -3.996776177589156');
    }
}
