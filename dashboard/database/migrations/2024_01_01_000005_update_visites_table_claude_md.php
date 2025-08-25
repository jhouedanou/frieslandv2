<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Migration pour adapter la table visites selon CLAUDE.md
     */
    public function up(): void
    {
        Schema::dropIfExists('visites');
        
        Schema::create('visites', function (Blueprint $table) {
            $table->id();
            $table->uuid('visite_id')->unique()->index(); // UUID selon CLAUDE.md
            $table->uuid('pdv_id')->index(); // Référence PDV
            $table->string('commercial')->index(); // Nom du merchandiser
            $table->timestamp('date_visite'); // Date et heure de la visite
            $table->json('geolocation'); // {lat: float, lng: float}
            $table->boolean('geofence_validated')->default(false); // Validation 300m
            $table->decimal('precision_gps', 5, 2); // Précision GPS en mètres
            
            // Structure JSON complexe selon CLAUDE.md
            $table->json('produits'); // Structure complète EVAP, IMP, SCM, UHT, YAOURT
            $table->json('concurrence'); // Structure concurrence par catégorie
            $table->json('visibilite'); // Structure visibilité intérieure/extérieure
            $table->json('actions'); // 7 actions terrain avec toggles OUI/NON
            $table->json('images')->nullable(); // Array de base64/URLs des photos
            
            $table->enum('sync_status', ['pending', 'synced', 'failed'])->default('pending');
            $table->timestamps();
            
            // Index pour optimiser les requêtes Dashboard selon CLAUDE.md
            $table->index(['date_visite']);
            $table->index(['commercial', 'date_visite']);
            $table->index(['sync_status']);
            $table->index(['pdv_id', 'date_visite']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('visites');
    }
};