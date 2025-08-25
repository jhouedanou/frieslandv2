<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class PDV extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'pdvs';

    // Structure selon CLAUDE.md
    protected $fillable = [
        'pdv_id',
        'nom_pdv',
        'canal',
        'categorie_pdv',
        'sous_categorie_pdv',
        'region',
        'territoire', 
        'zone',
        'secteur',
        'geolocation', // lat/lng
        'rayon_geofence', // default 300m
        'adressage',
        'image',
        'date_creation',
        'ajoute_par',
        'mdm',
    ];

    protected $casts = [
        'geolocation' => 'array', // {lat: float, lng: float}
        'rayon_geofence' => 'decimal:2',
        'date_creation' => 'datetime',
    ];

    public function visites(): HasMany
    {
        return $this->hasMany(Visite::class, 'pdv_id', 'pdv_id');
    }

    // Accesseurs pour faciliter l'utilisation selon CLAUDE.md
    public function getLatitudeAttribute(): float
    {
        return $this->geolocation['lat'] ?? 0.0;
    }

    public function getLongitudeAttribute(): float  
    {
        return $this->geolocation['lng'] ?? 0.0;
    }

    // Géofencing validation selon CLAUDE.md - 300m par défaut
    public function isWithinGeofence($lat, $lng): bool
    {
        $distance = $this->getDistanceFrom($lat, $lng);
        return $distance <= ($this->rayon_geofence ?? 300.0);
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

    // Scopes pour filtres Dashboard selon CLAUDE.md
    public function scopeParRegion($query, $region)
    {
        return $query->where('region', $region);
    }

    public function scopeParTerritoire($query, $territoire)
    {
        return $query->where('territoire', $territoire);
    }

    public function scopeParZone($query, $zone)
    {
        return $query->where('zone', $zone);
    }

    public function scopeParSecteur($query, $secteur)  
    {
        return $query->where('secteur', $secteur);
    }

    public function scopeParCanal($query, $canal)
    {
        return $query->where('canal', $canal);
    }

    public function scopeParCategorie($query, $categorie)
    {
        return $query->where('categorie_pdv', $categorie);
    }

    // Statistiques pour Dashboard selon CLAUDE.md
    public function getTotalVisitesAttribute(): int
    {
        return $this->visites()->count();
    }

    public function getDerniereVisiteAttribute()
    {
        return $this->visites()->latest('date_visite')->first();
    }
} 