<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Migration pour créer la table commerciaux selon CLAUDE.md
     */
    public function up(): void
    {
        Schema::create('commerciaux', function (Blueprint $table) {
            $table->id();
            $table->string('nom')->unique(); // Nom du merchandiser
            $table->string('email')->unique(); // Email
            $table->string('telephone')->nullable(); // Téléphone
            $table->string('zone_assignee'); // Zone géographique assignée
            $table->json('secteurs_assignes'); // JSON array des secteurs assignés
            $table->json('zone_geofence')->nullable(); // GeoJSON pour la zone géographique
            $table->timestamps();
            
            // Index pour optimiser les requêtes selon CLAUDE.md
            $table->index(['zone_assignee']);
            $table->index(['nom']); // Pour les jointures avec visites
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('commerciaux');
    }
};