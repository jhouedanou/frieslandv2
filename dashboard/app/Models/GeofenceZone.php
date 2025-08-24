<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GeofenceZone extends Model
{
    use HasFactory;

    protected $table = 'geofence_zones';

    protected $fillable = [
        'pdv_id',
        'name',
        'latitude',
        'longitude',
        'radius',
        'is_active',
        'description',
    ];

    protected $casts = [
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'radius' => 'integer',
        'is_active' => 'boolean',
    ];

    /**
     * Relation avec le PDV
     */
    public function pdv(): BelongsTo
    {
        return $this->belongsTo(PDV::class);
    }

    /**
     * Vérifier si un point est dans la zone
     */
    public function containsPoint(float $lat, float $lng): bool
    {
        $distance = $this->getDistanceFrom($lat, $lng);
        return $distance <= $this->radius;
    }

    /**
     * Calculer la distance depuis un point
     */
    public function getDistanceFrom(float $lat, float $lng): float
    {
        $earthRadius = 6371000; // Rayon de la Terre en mètres

        $latFrom = deg2rad($this->latitude);
        $lonFrom = deg2rad($this->longitude);
        $latTo = deg2rad($lat);
        $lonTo = deg2rad($lng);

        $latDelta = $latTo - $latFrom;
        $lonDelta = $lonTo - $lonFrom;

        $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) +
            cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));

        return $angle * $earthRadius;
    }

    /**
     * Scope pour les zones actives
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope pour les zones proches d'un point
     */
    public function scopeNearby($query, float $lat, float $lng, float $maxDistance = 1000)
    {
        return $query->whereRaw('
            (6371000 * acos(cos(radians(?)) * cos(radians(latitude)) * 
            cos(radians(longitude) - radians(?)) + sin(radians(?)) * 
            sin(radians(latitude)))) <= ?
        ', [$lat, $lng, $lat, $maxDistance]);
    }
} 