<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Visite extends Model
{
    use HasFactory;

    protected $table = 'visites';

    protected $fillable = [
        'pdv_id',
        'commercial_id',
        'date_visite',
        'heure_debut',
        'heure_fin',
        'latitude_debut',
        'longitude_debut',
        'latitude_fin',
        'longitude_fin',
        'statut',
        'notes',
        'produits_verifies',
        'prix_verifies',
        'photos',
        'signature',
    ];

    protected $casts = [
        'date_visite' => 'date',
        'heure_debut' => 'datetime',
        'heure_fin' => 'datetime',
        'latitude_debut' => 'decimal:8',
        'longitude_debut' => 'decimal:8',
        'latitude_fin' => 'decimal:8',
        'longitude_fin' => 'decimal:8',
        'produits_verifies' => 'array',
        'prix_verifies' => 'array',
        'photos' => 'array',
    ];

    public function pdv(): BelongsTo
    {
        return $this->belongsTo(PDV::class, 'pdv_id');
    }

    public function commercial(): BelongsTo
    {
        return $this->belongsTo(User::class, 'commercial_id');
    }

    public function getDureeVisiteAttribute(): string
    {
        if (!$this->heure_debut || !$this->heure_fin) {
            return 'N/A';
        }

        $duree = $this->heure_fin->diffInMinutes($this->heure_debut);
        $heures = intval($duree / 60);
        $minutes = $duree % 60;

        if ($heures > 0) {
            return "{$heures}h {$minutes}min";
        }

        return "{$minutes}min";
    }

    public function getDistanceParcourueAttribute(): float
    {
        if (!$this->latitude_debut || !$this->longitude_debut || 
            !$this->latitude_fin || !$this->longitude_fin) {
            return 0;
        }

        $earthRadius = 6371000;
        $latFrom = deg2rad($this->latitude_debut);
        $lonFrom = deg2rad($this->longitude_debut);
        $latTo = deg2rad($this->latitude_fin);
        $lonTo = deg2rad($this->longitude_fin);

        $latDelta = $latTo - $latFrom;
        $lonDelta = $lonTo - $lonFrom;

        $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) +
            cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));

        return round($angle * $earthRadius, 2);
    }

    public function scopeAujourdhui($query)
    {
        return $query->whereDate('date_visite', today());
    }

    public function scopeCetteSemaine($query)
    {
        return $query->whereBetween('date_visite', [now()->startOfWeek(), now()->endOfWeek()]);
    }

    public function scopeCeMois($query)
    {
        return $query->whereMonth('date_visite', now()->month);
    }
} 