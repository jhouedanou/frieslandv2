<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'code',
        'name',
        'category',
        'price',
        'stock_quantity',
        'unit',
        'description',
        'is_active',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'is_active' => 'boolean',
    ];

    public function orderItems(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeByCategory($query, $category)
    {
        return $query->where('category', $category);
    }

    public function getFormattedPriceAttribute()
    {
        return number_format($this->price, 0, ',', ' ') . ' FCFA';
    }

    // Catégories disponibles
    public static function getCategories()
    {
        return [
            'EVAP' => 'Dispo et Prix EVAP',
            'SCM' => 'Dispo et Prix SCM',
            'IMP' => 'Dispo et Prix IMP',
            'UHT' => 'Dispo et Prix UHT',
            'YAOURT' => 'Dispo et Prix Yoghurt',
            'CÉRÉALES AU LAIT' => 'Dispo et Prix UHT Céréales au lait',
        ];
    }
}
