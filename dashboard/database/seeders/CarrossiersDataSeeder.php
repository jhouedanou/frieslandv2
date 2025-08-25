<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\PDV;
use App\Models\Visite;
use App\Models\Commercial;
use Illuminate\Support\Str;
use Carbon\Carbon;

class CarrossiersDataSeeder extends Seeder
{
    public function run(): void
    {
        // Créer les PDVs aux emplacements spécifiés
        $pdvs = [
            [
                'nom' => 'Boutique Rue des Carrossiers 159',
                'adresse' => 'Rue des Carrossiers, n° 159, Treichville',
                'latitude' => 5.293531,
                'longitude' => -3.994062,
                'type' => 'Boutique',
                'secteur' => 'TREICHVILLE',
                'zone' => 'ABIDJAN SUD',
            ],
            [
                'nom' => 'Superette Zone Générale',
                'adresse' => 'Zone générale, Treichville',
                'latitude' => 5.296130,
                'longitude' => -3.997690,
                'type' => 'Superette',
                'secteur' => 'TREICHVILLE',
                'zone' => 'ABIDJAN SUD',
            ],
            [
                'nom' => 'Épicerie 21ᵉ Rue des Carrossiers',
                'adresse' => '21ᵉ Rue des Carrossiers, Treichville',
                'latitude' => 5.295187159,
                'longitude' => -3.996560304,
                'type' => 'Épicerie',
                'secteur' => 'TREICHVILLE',
                'zone' => 'ABIDJAN SUD',
            ],
            [
                'nom' => 'Mini-Market Central Treichville',
                'adresse' => 'Avenue 7, Treichville',
                'latitude' => 5.294156,
                'longitude' => -3.995123,
                'type' => 'Mini-Market',
                'secteur' => 'TREICHVILLE',
                'zone' => 'ABIDJAN SUD',
            ],
            [
                'nom' => 'Boutique Carrefour Treichville',
                'adresse' => 'Carrefour principal, Treichville',
                'latitude' => 5.293890,
                'longitude' => -3.996234,
                'type' => 'Boutique',
                'secteur' => 'TREICHVILLE',
                'zone' => 'ABIDJAN SUD',
            ],
            [
                'nom' => 'Épicerie du Marché',
                'adresse' => 'Près du marché de Treichville',
                'latitude' => 5.295673,
                'longitude' => -3.994789,
                'type' => 'Épicerie',
                'secteur' => 'TREICHVILLE',
                'zone' => 'ABIDJAN SUD',
            ],
            [
                'nom' => 'Superette Rue du Commerce',
                'adresse' => 'Rue du Commerce, Treichville',
                'latitude' => 5.294567,
                'longitude' => -3.995678,
                'type' => 'Superette',
                'secteur' => 'TREICHVILLE',
                'zone' => 'ABIDJAN SUD',
            ],
            [
                'nom' => 'Boutique Nouvelle Route',
                'adresse' => 'Nouvelle Route, Treichville',
                'latitude' => 5.292834,
                'longitude' => -3.996789,
                'type' => 'Boutique',
                'secteur' => 'TREICHVILLE',
                'zone' => 'ABIDJAN SUD',
            ],
            [
                'nom' => 'Mini-Market Boulevard',
                'adresse' => 'Boulevard Principal, Treichville',
                'latitude' => 5.295234,
                'longitude' => -3.993456,
                'type' => 'Mini-Market',
                'secteur' => 'TREICHVILLE',
                'zone' => 'ABIDJAN SUD',
            ],
            [
                'nom' => 'Épicerie Quartier Résidentiel',
                'adresse' => 'Quartier résidentiel, Treichville',
                'latitude' => 5.294789,
                'longitude' => -3.997123,
                'type' => 'Épicerie',
                'secteur' => 'TREICHVILLE',
                'zone' => 'ABIDJAN SUD',
            ],
        ];

        $createdPDVs = [];
        foreach ($pdvs as $pdvData) {
            $pdv = PDV::firstOrCreate(
                ['nom' => $pdvData['nom']],
                array_merge($pdvData, [
                    'id' => Str::uuid(),
                    'code_pdv' => 'TR' . str_pad(count($createdPDVs) + 1, 3, '0', STR_PAD_LEFT),
                    'telephone' => '+2250' . rand(100000000, 999999999),
                    'contact_principal' => 'Gérant ' . $pdvData['nom'],
                    'rayon_geofence' => 300, // 300m selon CLAUDE.md
                    'horaires_ouverture' => json_encode([
                        'lundi' => ['ouverture' => '07:00', 'fermeture' => '19:00'],
                        'mardi' => ['ouverture' => '07:00', 'fermeture' => '19:00'],
                        'mercredi' => ['ouverture' => '07:00', 'fermeture' => '19:00'],
                        'jeudi' => ['ouverture' => '07:00', 'fermeture' => '19:00'],
                        'vendredi' => ['ouverture' => '07:00', 'fermeture' => '19:00'],
                        'samedi' => ['ouverture' => '07:00', 'fermeture' => '20:00'],
                        'dimanche' => ['ouverture' => '08:00', 'fermeture' => '18:00'],
                    ]),
                    'is_active' => true,
                    'created_at' => now(),
                    'updated_at' => now(),
                ])
            );
            $createdPDVs[] = $pdv;
        }

        // Récupérer le commercial de test
        $commercial = Commercial::where('email', 'test.treichville@friesland.ci')->first();
        
        if (!$commercial) {
            $this->command->warn('Commercial de test non trouvé. Exécutez d\'abord TestDataSeeder.');
            return;
        }

        // Créer 10 visites sur les PDVs créés
        $visitTypes = ['visite_programmee', 'visite_surprise', 'visite_controle'];
        $statusList = ['planifiee', 'en_cours', 'terminee', 'reportee'];

        for ($i = 1; $i <= 10; $i++) {
            $pdv = $createdPDVs[($i - 1) % count($createdPDVs)];
            $dateVisite = Carbon::now()->subDays(rand(1, 30));
            
            // Données de visite selon CLAUDE.md
            $visiteData = [
                'geolocation' => [
                    'latitude' => $pdv->latitude + (rand(-10, 10) / 100000), // Légère variation
                    'longitude' => $pdv->longitude + (rand(-10, 10) / 100000),
                    'precision' => rand(5, 15),
                    'timestamp' => $dateVisite->toISOString(),
                ],
                'produits' => [
                    'evap' => [
                        'present' => rand(0, 1) == 1,
                        'br_gold' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                        'br_150g' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                        'brb_150g' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                        'br_380g' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                        'brb_380g' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                        'pearl_380g' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                    ],
                    'imp' => [
                        'present' => rand(0, 1) == 1,
                        'prix_respectes' => rand(0, 1) == 1,
                        'br_2' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                        'br_16g' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                        'brb_16g' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                        'br_360g' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                        'br_400g_tin' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                        'brb_360g' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                        'br_900g_tin' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                    ],
                    'scm' => [
                        'present' => rand(0, 1) == 1,
                        'prix_respectes' => rand(0, 1) == 1,
                    ],
                    'uht' => [
                        'present' => rand(0, 1) == 1,
                        'prix_respectes' => rand(0, 1) == 1,
                    ],
                    'yaourt' => [
                        'present' => rand(0, 1) == 1,
                    ],
                ],
                'concurrence' => [
                    'presence_concurrents' => rand(0, 1) == 1,
                    'evap' => [
                        'present' => rand(0, 1) == 1,
                        'cowmilk' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                        'nido_150g' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                        'autre' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                    ],
                    'imp' => [
                        'present' => rand(0, 1) == 1,
                        'nido' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                        'laity' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                        'autre' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                    ],
                    'scm' => [
                        'present' => rand(0, 1) == 1,
                        'top_saho' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                        'autre' => rand(0, 1) == 1 ? 'Présent' : 'En rupture',
                        'nom_concurrent' => '',
                    ],
                    'uht' => rand(0, 1) == 1,
                ],
                'visibilite' => [
                    'facade_visible' => rand(0, 1) == 1,
                    'enseigne_presente' => rand(0, 1) == 1,
                    'materiel_pos' => [
                        'present' => rand(0, 1) == 1,
                        'types' => ['Affiche', 'Présentoir', 'Frigo'],
                        'etat' => 'bon',
                    ],
                    'respect_charte' => rand(0, 1) == 1,
                ],
                'actions' => [
                    'formation_vendeur' => rand(0, 1) == 1,
                    'negociation_prix' => rand(0, 1) == 1,
                    'installation_materiel' => rand(0, 1) == 1,
                    'prise_commande' => rand(0, 1) == 1,
                    'commentaires' => 'Visite test #' . $i . ' - Secteur Treichville',
                ],
            ];

            Visite::create([
                'id' => Str::uuid(),
                'pdv_id' => $pdv->id,
                'commercial_id' => $commercial->email,
                'type_visite' => $visitTypes[array_rand($visitTypes)],
                'statut' => $statusList[array_rand($statusList)],
                'date_planifiee' => $dateVisite,
                'date_debut' => $dateVisite,
                'date_fin' => $dateVisite->copy()->addMinutes(rand(30, 120)),
                'donnees_collectees' => json_encode($visiteData),
                'photos' => json_encode([]), // Pas de photos pour les données de test
                'commentaires' => 'Visite de test dans le secteur Treichville - Rue des Carrossiers',
                'score_visite' => rand(60, 100),
                'synchronise' => true,
                'created_at' => $dateVisite,
                'updated_at' => $dateVisite,
            ]);
        }

        $this->command->info('✅ Données de test créées :');
        $this->command->info('   - ' . count($createdPDVs) . ' PDVs dans le secteur Treichville');
        $this->command->info('   - 10 visites de test');
        $this->command->info('   - Emplacements spécifiés : Rue des Carrossiers');
        $this->command->info('📍 Coordonnées principales :');
        $this->command->info('   - Rue des Carrossiers, n° 159 : 5.293531, -3.994062');
        $this->command->info('   - Zone générale : 5.296130, -3.997690');
        $this->command->info('   - 21ᵉ Rue des Carrossiers : 5.295187159, -3.996560304');
    }
}
