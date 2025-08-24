<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pdvs', function (Blueprint $table) {
            $table->id();
            $table->string('nom');
            $table->text('adresse');
            $table->string('ville');
            $table->string('code_postal');
            $table->string('pays')->default('France');
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            $table->string('type_pdv');
            $table->string('secteur');
            $table->foreignId('commercial_id')->nullable()->constrained('users')->onDelete('set null');
            $table->string('statut')->default('actif');
            $table->timestamp('date_creation')->useCurrent();
            $table->timestamp('derniere_visite')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->index(['latitude', 'longitude']);
            $table->index(['secteur', 'statut']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pdvs');
    }
}; 