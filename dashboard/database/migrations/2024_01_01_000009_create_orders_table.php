<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('order_number')->unique();
            $table->foreignId('pdv_id')->constrained()->onDelete('cascade');
            $table->string('pdv_name');
            $table->enum('status', ['DRAFT', 'PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED'])->default('DRAFT');
            $table->decimal('total_amount', 12, 2)->default(0);
            $table->decimal('total_pre_order', 12, 2)->default(0);
            $table->decimal('grand_total', 12, 2)->default(0);
            $table->enum('payment_status', ['PENDING', 'PAID', 'PARTIALLY_PAID', 'UNPAID'])->default('PENDING');
            $table->enum('delivery_type', ['IMMEDIATE', 'SCHEDULED'])->default('IMMEDIATE');
            $table->datetime('order_date');
            $table->datetime('delivery_date')->nullable();
            $table->text('signature')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->index(['pdv_id', 'status']);
            $table->index('order_number');
            $table->index('order_date');
        });
    }

    public function down()
    {
        Schema::dropIfExists('orders');
    }
};
