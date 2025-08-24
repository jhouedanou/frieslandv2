<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RolePermissionSeeder extends Seeder
{
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        // Create permissions
        $permissions = [
            // PDV permissions
            'view pdvs',
            'create pdvs',
            'edit pdvs',
            'delete pdvs',
            'export pdvs',
            
            // Visite permissions
            'view visites',
            'create visites',
            'edit visites',
            'delete visites',
            'export visites',
            'validate visites',
            
            // User permissions
            'view users',
            'create users',
            'edit users',
            'delete users',
            'manage roles',
            
            // Dashboard permissions
            'view dashboard',
            'view analytics',
            'export reports',
            
            // System permissions
            'manage settings',
            'view logs',
            'manage backups',
        ];

        foreach ($permissions as $permission) {
            Permission::create(['name' => $permission]);
        }

        // Create roles and assign permissions
        $adminRole = Role::create(['name' => 'admin']);
        $adminRole->givePermissionTo(Permission::all());

        $managerRole = Role::create(['name' => 'manager']);
        $managerRole->givePermissionTo([
            'view pdvs', 'create pdvs', 'edit pdvs', 'export pdvs',
            'view visites', 'create visites', 'edit visites', 'export visites', 'validate visites',
            'view users', 'edit users',
            'view dashboard', 'view analytics', 'export reports',
        ]);

        $supervisorRole = Role::create(['name' => 'supervisor']);
        $supervisorRole->givePermissionTo([
            'view pdvs', 'edit pdvs', 'export pdvs',
            'view visites', 'edit visites', 'export visites', 'validate visites',
            'view dashboard', 'view analytics',
        ]);

        $commercialRole = Role::create(['name' => 'commercial']);
        $commercialRole->givePermissionTo([
            'view pdvs',
            'view visites', 'create visites', 'edit visites',
            'view dashboard',
        ]);

        $this->command->info('Rôles et permissions créés avec succès!');
    }
} 