<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Commercial;
use App\Models\PDV;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class TestDataSeeder extends Seeder
{
    /**
     * Run the database seeds - Données de test pour Treichville selon demande utilisateur
     */
    public function run(): void
    {
        // 1. Créer un utilisateur de test spécifique
        $testUser = User::create([
            'name' => 'Merchandiser Test Treichville',
            'email' => 'test.treichville@friesland.ci',
            'password' => Hash::make('test123'),
            'role' => 'commercial',
            'is_active' => true,
            'email_verified_at' => now(),
        ]);

        // 2. Créer un commercial correspondant selon CLAUDE.md
        $commercial = Commercial::create([
            'nom' => 'MERCHANDISER TEST',
            'email' => 'test.treichville@friesland.ci',
            'telephone' => '+225 07 12 34 56 78',
            'zone_assignee' => 'ABIDJAN SUD',
            'secteurs_assignes' => ['TREICHVILLE', 'MARCORY'], // JSON array
            'zone_geofence' => [
                'type' => 'Polygon',
                'coordinates' => [[
                    [5.2471, -4.0278], // Treichville boundaries approximatives
                    [5.2471, -4.0200],
                    [5.2550, -4.0200],
                    [5.2550, -4.0278],
                    [5.2471, -4.0278]
                ]]
            ]
        ]);

        // 3. Créer des PDV de test à Treichville - rue Roger Abinader
        $pdvs = [
            [
                'nom_pdv' => 'Boutique Roger Abinader 1',
                'adressage' => 'Rue Roger Abinader, près du carrefour, Treichville',
                'lat' => 5.2495,
                'lng' => -4.0240,
            ],
            [
                'nom_pdv' => 'Superette Roger Abinader',
                'adressage' => 'Rue Roger Abinader, face à la pharmacie, Treichville',
                'lat' => 5.2500,
                'lng' => -4.0235,
            ],
            [
                'nom_pdv' => 'Magasin Roger Abinader Centre',
                'adressage' => 'Rue Roger Abinader, centre commercial, Treichville',
                'lat' => 5.2505,
                'lng' => -4.0230,
            ],
            [
                'nom_pdv' => 'Épicerie Roger Abinader 2',
                'adressage' => 'Rue Roger Abinader, près de la station-service, Treichville',
                'lat' => 5.2510,
                'lng' => -4.0225,
            ],
            [
                'nom_pdv' => 'Commerce Roger Abinader Sud',
                'adressage' => 'Rue Roger Abinader, quartier résidentiel, Treichville',
                'lat' => 5.2485,
                'lng' => -4.0245,
            ]
        ];

        foreach ($pdvs as $pdvData) {
            PDV::create([
                'pdv_id' => Str::uuid(),
                'nom_pdv' => $pdvData['nom_pdv'],
                'canal' => 'TRADITIONNEL',
                'categorie_pdv' => 'BOUTIQUE',
                'sous_categorie_pdv' => 'ÉPICERIE',
                'region' => 'ABIDJAN',
                'territoire' => 'ABIDJAN SUD',
                'zone' => 'TREICHVILLE',
                'secteur' => 'TREICHVILLE CENTRE',
                'geolocation' => [
                    'lat' => $pdvData['lat'],
                    'lng' => $pdvData['lng']
                ],
                'rayon_geofence' => 300.0, // 300m selon CLAUDE.md
                'adressage' => $pdvData['adressage'],
                'image' => null,
                'date_creation' => now(),
                'ajoute_par' => 'TEST_SEEDER',
                'mdm' => 'TEST_' . Str::random(6),
            ]);
        }

        // 4. Ajouter quelques PDV supplémentaires pour le routing dans d'autres zones de Treichville
        $pdvsRouting = [
            [
                'nom_pdv' => 'Marché Treichville - Entrée Nord',
                'adressage' => 'Avenue Treichville, entrée nord du marché',
                'lat' => 5.2520,
                'lng' => -4.0210,
            ],
            [
                'nom_pdv' => 'Pharmacie Boulevard Lagunaire',
                'adressage' => 'Boulevard Lagunaire, face au port, Treichville',
                'lat' => 5.2475,
                'lng' => -4.0260,
            ],
            [
                'nom_pdv' => 'Station Total Treichville',
                'adressage' => 'Carrefour principal Treichville, près du pont',
                'lat' => 5.2515,
                'lng' => -4.0200,
            ]
        ];

        foreach ($pdvsRouting as $pdvData) {
            PDV::create([
                'pdv_id' => Str::uuid(),
                'nom_pdv' => $pdvData['nom_pdv'],
                'canal' => 'MODERNE',
                'categorie_pdv' => 'SUPERMARCHÉ',
                'sous_categorie_pdv' => 'GRANDE SURFACE',
                'region' => 'ABIDJAN',
                'territoire' => 'ABIDJAN SUD',
                'zone' => 'TREICHVILLE',
                'secteur' => 'TREICHVILLE PORT',
                'geolocation' => [
                    'lat' => $pdvData['lat'],
                    'lng' => $pdvData['lng']
                ],
                'rayon_geofence' => 300.0,
                'adressage' => $pdvData['adressage'],
                'image' => null,
                'date_creation' => now(),
                'ajoute_par' => 'TEST_SEEDER',
                'mdm' => 'ROUTE_' . Str::random(6),
            ]);
        }

        $this->command->info('✅ Utilisateur test et PDV Treichville créés avec succès !');
        $this->command->info('📧 Email: test.treichville@friesland.ci');
        $this->command->info('🔑 Mot de passe: test123');
        $this->command->info('📍 8 PDV créés à Treichville (5 sur rue Roger Abinader + 3 pour routing)');
    }
}
