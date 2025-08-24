<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('visites', function (Blueprint $table) {
            $table->id();
            $table->foreignId('pdv_id')->constrained('pdvs')->onDelete('cascade');
            $table->foreignId('commercial_id')->constrained('users')->onDelete('cascade');
            $table->date('date_visite');
            $table->timestamp('heure_debut')->nullable();
            $table->timestamp('heure_fin')->nullable();
            $table->decimal('latitude_debut', 10, 8)->nullable();
            $table->decimal('longitude_debut', 11, 8)->nullable();
            $table->decimal('latitude_fin', 10, 8)->nullable();
            $table->decimal('longitude_fin', 11, 8)->nullable();
            $table->string('statut')->default('en_cours');
            $table->text('notes')->nullable();
            $table->json('produits_verifies')->nullable();
            $table->json('prix_verifies')->nullable();
            $table->json('photos')->nullable();
            $table->text('signature')->nullable();
            $table->timestamps();

            $table->index(['date_visite', 'commercial_id']);
            $table->index(['pdv_id', 'date_visite']);
            $table->index(['statut', 'date_visite']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('visites');
    }
}; 