<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Migration pour adapter la table pdvs selon CLAUDE.md
     */
    public function up(): void
    {
        Schema::table('geofence_zones', function (Blueprint $table) {
            $table->dropForeign(['pdv_id']);
        });
        
        Schema::dropIfExists('pdvs');
        
        Schema::create('pdvs', function (Blueprint $table) {
            $table->id();
            $table->uuid('pdv_id')->unique()->index(); // UUID selon CLAUDE.md
            $table->string('nom_pdv'); // Nom du point de vente
            $table->string('canal'); // Canal de distribution
            $table->string('categorie_pdv'); // Catégorie du PDV
            $table->string('sous_categorie_pdv'); // Sous-catégorie
            $table->string('region'); // Région géographique  
            $table->string('territoire'); // Territoire
            $table->string('zone'); // Zone
            $table->string('secteur'); // Secteur
            $table->json('geolocation'); // {lat: float, lng: float}
            $table->decimal('rayon_geofence', 6, 2)->default(300.00); // Rayon en mètres, défaut 300m
            $table->text('adressage'); // Adresse complète
            $table->string('image')->nullable(); // Photo du PDV
            $table->timestamp('date_creation'); // Date de création du PDV
            $table->string('ajoute_par'); // Qui a ajouté le PDV
            $table->string('mdm'); // Manager/Merchandiser responsable
            $table->timestamps();
            
            // Index pour optimiser les requêtes selon CLAUDE.md
            $table->index(['region', 'territoire', 'zone']);
            $table->index(['secteur']);
            $table->index(['canal']);
            $table->index(['categorie_pdv']);
            $table->index(['mdm']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pdvs');
    }
};