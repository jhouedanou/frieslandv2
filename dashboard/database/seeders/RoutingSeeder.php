<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\PDV;
use App\Models\Commercial;
use Illuminate\Support\Str;

class RoutingSeeder extends Seeder
{
    /**
     * Seeder pour système de routing - Optimisation des tournées Treichville
     */
    public function run(): void
    {
        // Créer une tournée optimisée pour rue Roger Abinader
        $this->createOptimizedRoute();
        
        // Créer des tournées complémentaires dans Treichville
        $this->createComplementaryRoutes();

        $this->command->info('✅ Système de routing Treichville configuré !');
    }

    /**
     * Créer une tournée optimisée rue Roger Abinader
     */
    private function createOptimizedRoute(): void
    {
        $routePDVs = [
            [
                'nom_pdv' => 'Point Départ - Roger Abinader Nord',
                'adressage' => 'Rue Roger Abinader, début de tournée (parking)',
                'lat' => 5.2490,
                'lng' => -4.0248,
                'ordre_visite' => 1,
                'temps_estime' => 5, // minutes
            ],
            [
                'nom_pdv' => 'Boutique Famille Roger Abinader',
                'adressage' => 'Rue Roger Abinader, près école primaire',
                'lat' => 5.2492,
                'lng' => -4.0242,
                'ordre_visite' => 2,
                'temps_estime' => 15,
            ],
            [
                'nom_pdv' => 'Épicerie Moderne Roger Abinader',
                'adressage' => 'Rue Roger Abinader, croisement avenue principale',
                'lat' => 5.2497,
                'lng' => -4.0238,
                'ordre_visite' => 3,
                'temps_estime' => 20,
            ],
            [
                'nom_pdv' => 'Superette Roger Abinader Centre',
                'adressage' => 'Rue Roger Abinader, centre commercial local',
                'lat' => 5.2503,
                'lng' => -4.0232,
                'ordre_visite' => 4,
                'temps_estime' => 25,
            ],
            [
                'nom_pdv' => 'Commerce Roger Abinader Sud',
                'adressage' => 'Rue Roger Abinader, près arrêt de bus',
                'lat' => 5.2508,
                'lng' => -4.0228,
                'ordre_visite' => 5,
                'temps_estime' => 15,
            ],
            [
                'nom_pdv' => 'Point Arrivée - Roger Abinader Sud',
                'adressage' => 'Rue Roger Abinader, fin de tournée (station)',
                'lat' => 5.2512,
                'lng' => -4.0223,
                'ordre_visite' => 6,
                'temps_estime' => 5,
            ]
        ];

        foreach ($routePDVs as $pdvData) {
            PDV::create([
                'pdv_id' => Str::uuid(),
                'nom_pdv' => $pdvData['nom_pdv'],
                'canal' => 'TRADITIONNEL',
                'categorie_pdv' => 'BOUTIQUE',
                'sous_categorie_pdv' => 'ÉPICERIE',
                'region' => 'ABIDJAN',
                'territoire' => 'ABIDJAN SUD',
                'zone' => 'TREICHVILLE',
                'secteur' => 'ROGER_ABINADER_ROUTE',
                'geolocation' => [
                    'lat' => $pdvData['lat'],
                    'lng' => $pdvData['lng']
                ],
                'rayon_geofence' => 300.0,
                'adressage' => $pdvData['adressage'],
                'image' => null,
                'date_creation' => now(),
                'ajoute_par' => 'ROUTING_SEEDER',
                'mdm' => 'ROUTE_' . sprintf('%02d', $pdvData['ordre_visite']) . '_' . Str::random(4),
                // Métadonnées pour le routing
                'metadata' => json_encode([
                    'route_name' => 'ROGER_ABINADER_PRINCIPALE',
                    'ordre_visite' => $pdvData['ordre_visite'],
                    'temps_estime_minutes' => $pdvData['temps_estime'],
                    'distance_precedent_metres' => $this->calculateDistanceFromPrevious($routePDVs, $pdvData['ordre_visite']),
                    'type_pdv' => $pdvData['ordre_visite'] == 1 || $pdvData['ordre_visite'] == 6 ? 'CHECKPOINT' : 'COMMERCIAL'
                ])
            ]);
        }
    }

    /**
     * Créer des tournées complémentaires
     */
    private function createComplementaryRoutes(): void
    {
        // Route alternative pour la zone port
        $routePort = [
            [
                'nom_pdv' => 'Marché Treichville - Poissonnerie',
                'lat' => 5.2518,
                'lng' => -4.0205,
                'secteur' => 'TREICHVILLE_PORT',
            ],
            [
                'nom_pdv' => 'Gare Routière Treichville',
                'lat' => 5.2522,
                'lng' => -4.0195,
                'secteur' => 'TREICHVILLE_PORT',
            ],
            [
                'nom_pdv' => 'Pharmacie Boulevard Lagunaire',
                'lat' => 5.2475,
                'lng' => -4.0260,
                'secteur' => 'TREICHVILLE_PORT',
            ]
        ];

        foreach ($routePort as $index => $pdvData) {
            PDV::create([
                'pdv_id' => Str::uuid(),
                'nom_pdv' => $pdvData['nom_pdv'],
                'canal' => 'MODERNE',
                'categorie_pdv' => 'SUPERMARCHÉ',
                'sous_categorie_pdv' => 'COMMERCE',
                'region' => 'ABIDJAN',
                'territoire' => 'ABIDJAN SUD',
                'zone' => 'TREICHVILLE',
                'secteur' => $pdvData['secteur'],
                'geolocation' => [
                    'lat' => $pdvData['lat'],
                    'lng' => $pdvData['lng']
                ],
                'rayon_geofence' => 300.0,
                'adressage' => 'Zone portuaire Treichville, secteur commercial',
                'image' => null,
                'date_creation' => now(),
                'ajoute_par' => 'ROUTING_SEEDER',
                'mdm' => 'PORT_' . sprintf('%02d', $index + 1) . '_' . Str::random(4),
                'metadata' => json_encode([
                    'route_name' => 'TREICHVILLE_PORT_ALTERNATIVE',
                    'ordre_visite' => $index + 1,
                    'temps_estime_minutes' => 20,
                    'type_pdv' => 'COMMERCIAL'
                ])
            ]);
        }
    }

    /**
     * Calculer la distance depuis le PDV précédent
     */
    private function calculateDistanceFromPrevious(array $route, int $currentOrder): int
    {
        if ($currentOrder <= 1) return 0;
        
        $current = collect($route)->firstWhere('ordre_visite', $currentOrder);
        $previous = collect($route)->firstWhere('ordre_visite', $currentOrder - 1);
        
        if (!$current || !$previous) return 0;

        // Formule de distance approximative en mètres
        $latDiff = $current['lat'] - $previous['lat'];
        $lngDiff = $current['lng'] - $previous['lng'];
        
        return (int) (sqrt(pow($latDiff * 111000, 2) + pow($lngDiff * 111000, 2)));
    }
}
