<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Créer un utilisateur admin par défaut
        User::create([
            'name' => 'Administrator',
            'email' => 'admin@friesland.local',
            'password' => Hash::make('admin123'),
            'role' => 'admin',
            'is_active' => true,
            'email_verified_at' => now(),
        ]);

        // Créer un commercial de test
        User::create([
            'name' => 'Commercial Test',
            'email' => 'commercial@friesland.local',
            'password' => Hash::make('commercial123'),
            'role' => 'commercial',
            'is_active' => true,
            'email_verified_at' => now(),
        ]);

        // Créer un superviseur de test
        User::create([
            'name' => 'Superviseur Test',
            'email' => 'superviseur@friesland.local',
            'password' => Hash::make('superviseur123'),
            'role' => 'supervisor',
            'is_active' => true,
            'email_verified_at' => now(),
        ]);
    }
}