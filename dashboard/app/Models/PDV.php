<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PDV extends Model
{
    use HasFactory;

    protected $table = 'pdvs';

    protected $fillable = [
        'nom',
        'adresse',
        'ville',
        'code_postal',
        'pays',
        'latitude',
        'longitude',
        'type_pdv',
        'secteur',
        'commercial_id',
        'statut',
        'date_creation',
        'derniere_visite',
        'notes',
    ];

    protected $casts = [
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'date_creation' => 'datetime',
        'derniere_visite' => 'datetime',
    ];

    public function visites(): HasMany
    {
        return $this->hasMany(Visite::class, 'pdv_id');
    }

    public function commercial()
    {
        return $this->belongsTo(User::class, 'commercial_id');
    }

    public function getFullAddressAttribute(): string
    {
        return "{$this->adresse}, {$this->code_postal} {$this->ville}, {$this->pays}";
    }

    public function getDistanceFrom($lat, $lng): float
    {
        if (!$this->latitude || !$this->longitude) {
            return 0;
        }

        $earthRadius = 6371000; // Rayon de la Terre en mètres
        $latFrom = deg2rad($lat);
        $lonFrom = deg2rad($lng);
        $latTo = deg2rad($this->latitude);
        $lonTo = deg2rad($this->longitude);

        $latDelta = $latTo - $latFrom;
        $lonDelta = $lonTo - $lonFrom;

        $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) +
            cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));

        return $angle * $earthRadius;
    }
} 