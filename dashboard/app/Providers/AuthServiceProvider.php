<?php

namespace App\Providers;

use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Gate;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * The model to policy mappings for the application.
     *
     * @var array<class-string, class-string>
     */
    protected $policies = [
        //
    ];

    /**
     * Register any authentication / authorization services.
     */
    public function boot(): void
    {
        $this->registerPolicies();

        // Définir les gates d'autorisation
        Gate::define('manage-users', function ($user) {
            return $user->hasRole(['admin', 'manager']);
        });

        Gate::define('manage-pdvs', function ($user) {
            return $user->hasRole(['admin', 'manager', 'supervisor']);
        });

        Gate::define('manage-visites', function ($user) {
            return $user->hasRole(['admin', 'manager', 'supervisor', 'commercial']);
        });

        Gate::define('view-analytics', function ($user) {
            return $user->hasRole(['admin', 'manager', 'supervisor']);
        });
    }
} 