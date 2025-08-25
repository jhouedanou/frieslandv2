<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Commercial extends Model
{
    use HasFactory;

    protected $table = 'commerciaux';

    // Structure selon CLAUDE.md
    protected $fillable = [
        'nom',
        'email', 
        'telephone',
        'zone_assignee',
        'secteurs_assignes',
        'zone_geofence', // GeoJSON
    ];

    protected $casts = [
        'secteurs_assignes' => 'array', // JSON array des secteurs
        'zone_geofence' => 'array', // GeoJSON pour la zone géographique
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function visites(): HasMany
    {
        return $this->hasMany(Visite::class, 'commercial', 'nom');
    }

    // Statistiques performance selon CLAUDE.md
    public function getTotalVisitesAttribute(): int
    {
        return $this->visites()->count();
    }

    public function getVisitesAujourdhuiAttribute(): int
    {
        return $this->visites()->aujourdhui()->count();
    }

    public function getVisitesCetteSemaineAttribute(): int
    {
        return $this->visites()->cetteSemaine()->count();
    }

    public function getVisitesCeMoisAttribute(): int
    {
        return $this->visites()->ceMois()->count();
    }

    // Taux présence produits selon CLAUDE.md
    public function getTauxEvapAttribute(): float
    {
        $total = $this->visites()->count();
        if ($total === 0) return 0.0;
        
        $avecEvap = $this->visites()->avecEvap()->count();
        return round(($avecEvap / $total) * 100, 2);
    }

    public function getTauxImpAttribute(): float
    {
        $total = $this->visites()->count();
        if ($total === 0) return 0.0;
        
        $avecImp = $this->visites()->avecImp()->count();
        return round(($avecImp / $total) * 100, 2);
    }

    public function getTauxScmAttribute(): float
    {
        $total = $this->visites()->count();
        if ($total === 0) return 0.0;
        
        $avecScm = $this->visites()->avecScm()->count();
        return round(($avecScm / $total) * 100, 2);
    }

    public function getTauxUhtAttribute(): float
    {
        $total = $this->visites()->count();
        if ($total === 0) return 0.0;
        
        $avecUht = $this->visites()->avecUht()->count();
        return round(($avecUht / $total) * 100, 2);
    }

    // Scopes pour Dashboard selon CLAUDE.md
    public function scopeParZone($query, $zone)
    {
        return $query->where('zone_assignee', $zone);
    }

    public function scopeAvecSecteur($query, $secteur)
    {
        return $query->whereJsonContains('secteurs_assignes', $secteur);
    }

    // Performance individuelle pour Dashboard selon CLAUDE.md
    public function getPerformanceScore(): array
    {
        return [
            'total_visites' => $this->total_visites,
            'visites_ce_mois' => $this->visites_ce_mois,
            'taux_evap' => $this->taux_evap,
            'taux_imp' => $this->taux_imp,
            'taux_scm' => $this->taux_scm,
            'taux_uht' => $this->taux_uht,
            'score_global' => round(($this->taux_evap + $this->taux_imp + $this->taux_scm + $this->taux_uht) / 4, 2),
        ];
    }
}