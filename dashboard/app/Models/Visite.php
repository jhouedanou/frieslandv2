<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class Visite extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'visites';

    // Structure selon CLAUDE.md
    protected $fillable = [
        'visite_id',
        'pdv_id', 
        'commercial',
        'date_visite',
        'geolocation',
        'geofence_validated',
        'precision_gps',
        'produits',
        'concurrence', 
        'visibilite',
        'actions',
        'images',
        'sync_status',
    ];

    protected $casts = [
        'date_visite' => 'datetime',
        'geolocation' => 'array', // {lat: float, lng: float}
        'geofence_validated' => 'boolean',
        'precision_gps' => 'decimal:2',
        'produits' => 'array', // Structure JSON complexe selon CLAUDE.md
        'concurrence' => 'array', // Structure JSON selon CLAUDE.md
        'visibilite' => 'array', // Structure JSON selon CLAUDE.md
        'actions' => 'array', // Structure JSON selon CLAUDE.md
        'images' => 'array', // Array de base64 ou URLs
    ];

    public function pdv(): BelongsTo
    {
        return $this->belongsTo(PDV::class, 'pdv_id', 'pdv_id');
    }

    // Accesseurs pour calculer KPIs selon CLAUDE.md
    public function getEvapPresentAttribute(): bool
    {
        return $this->produits['evap']['present'] ?? false;
    }

    public function getImpPresentAttribute(): bool  
    {
        return $this->produits['imp']['present'] ?? false;
    }

    public function getScmPresentAttribute(): bool
    {
        return $this->produits['scm']['present'] ?? false;
    }

    public function getUhtPresentAttribute(): bool
    {
        return $this->produits['uht']['present'] ?? false;
    }

    public function getYaourtPresentAttribute(): bool
    {
        return $this->produits['yaourt']['present'] ?? false;
    }

    public function getEvapPrixRespecteAttribute(): bool
    {
        return $this->produits['evap']['prix_respectes'] ?? false;
    }

    public function getImpPrixRespecteAttribute(): bool
    {
        return $this->produits['imp']['prix_respectes'] ?? false;
    }

    public function getScmPrixRespecteAttribute(): bool
    {
        return $this->produits['scm']['prix_respectes'] ?? false;
    }

    // Scopes pour les KPIs Dashboard selon CLAUDE.md
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

    public function scopeAvecEvap($query)
    {
        return $query->whereJsonContains('produits->evap->present', true);
    }

    public function scopeAvecImp($query)
    {
        return $query->whereJsonContains('produits->imp->present', true);
    }

    public function scopeAvecScm($query)
    {
        return $query->whereJsonContains('produits->scm->present', true);
    }

    public function scopeAvecUht($query)
    {
        return $query->whereJsonContains('produits->uht->present', true);
    }

    public function scopeParCommercial($query, $commercial)
    {
        return $query->where('commercial', $commercial);
    }

    public function scopeSynced($query)
    {
        return $query->where('sync_status', 'synced');
    }

    public function scopePending($query)
    {
        return $query->where('sync_status', 'pending');
    }

    public function scopeFailed($query)
    {
        return $query->where('sync_status', 'failed');
    }
} 