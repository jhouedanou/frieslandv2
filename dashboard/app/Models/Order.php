<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_number',
        'pdv_id',
        'pdv_name',
        'status',
        'total_amount',
        'total_pre_order',
        'grand_total',
        'payment_status',
        'delivery_type',
        'order_date',
        'delivery_date',
        'signature',
        'notes',
    ];

    protected $casts = [
        'total_amount' => 'decimal:2',
        'total_pre_order' => 'decimal:2',
        'grand_total' => 'decimal:2',
        'order_date' => 'datetime',
        'delivery_date' => 'datetime',
    ];

    public function pdv(): BelongsTo
    {
        return $this->belongsTo(PDV::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    public function scopeByPdv($query, $pdvId)
    {
        return $query->where('pdv_id', $pdvId);
    }

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($order) {
            if (empty($order->order_number)) {
                $order->order_number = 'CMD-' . now()->format('Ymd') . '-' . str_pad(static::whereDate('created_at', now())->count() + 1, 4, '0', STR_PAD_LEFT);
            }
        });
    }

    // Statuts disponibles
    public static function getStatuses()
    {
        return [
            'DRAFT' => 'Brouillon',
            'PENDING' => 'En attente',
            'CONFIRMED' => 'Confirmée',
            'SHIPPED' => 'Expédiée',
            'DELIVERED' => 'Livrée',
            'CANCELLED' => 'Annulée',
        ];
    }

    public static function getPaymentStatuses()
    {
        return [
            'PENDING' => 'En attente',
            'PAID' => 'Payé',
            'PARTIALLY_PAID' => 'Partiellement payé',
            'UNPAID' => 'Non payé',
        ];
    }

    public static function getDeliveryTypes()
    {
        return [
            'IMMEDIATE' => 'Immédiate',
            'SCHEDULED' => 'Programmée',
        ];
    }
}
