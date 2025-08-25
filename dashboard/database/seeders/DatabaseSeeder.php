<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database selon CLAUDE.md + demandes utilisateur
     */
    public function run(): void
    {
        $this->command->info('🚀 Initialisation de la base de données Friesland Bonnet Rouge...');

        // 1. Rôles et permissions (base)
        $this->call(RolePermissionSeeder::class);
        $this->command->info('✅ Rôles et permissions configurés');

        // 2. Utilisateurs admin de base
        $this->call(AdminUserSeeder::class);
        $this->command->info('✅ Utilisateurs administrateurs créés');

        // 3. Données de test spécifiques pour Treichville
        $this->call(TestDataSeeder::class);
        $this->command->info('✅ Utilisateur test et PDV Treichville créés');

        // 4. Système de routing optimisé
        $this->call(RoutingSeeder::class);
        $this->command->info('✅ Système de routing configuré');

        // 5. PDVs fictifs avec coordonnées spécifiques
        $this->call(FictionalPDVSeeder::class);
        $this->command->info('✅ PDVs fictifs créés avec coordonnées demandées');

        $this->command->info('');
        $this->command->info('🎉 Base de données initialisée avec succès !');
        $this->command->info('');
        $this->command->info('📋 Comptes créés :');
        $this->command->info('   👤 Admin: admin@friesland.local / admin123');
        $this->command->info('   👤 Commercial: commercial@friesland.local / commercial123');
        $this->command->info('   👤 Superviseur: superviseur@friesland.local / superviseur123');
        $this->command->info('   👤 Test Treichville: test.treichville@friesland.ci / test123');
        $this->command->info('');
        $this->command->info('📍 PDV créés :');
        $this->command->info('   🛣️  Route principale: 6 points rue Roger Abinader');
        $this->command->info('   🏪 Route alternative: 3 points zone portuaire');
        $this->command->info('   📊 Total: ~17 PDV pour tests à Treichville');
        $this->command->info('');
        $this->command->info('🌐 Accès Dashboard: http://localhost/admin');
    }
}
