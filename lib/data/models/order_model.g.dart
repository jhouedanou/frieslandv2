// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      id: (json['id'] as num).toInt(),
      orderNumber: json['orderNumber'] as String,
      pdvId: (json['pdvId'] as num).toInt(),
      pdvName: json['pdvName'] as String,
      status: json['status'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      totalPreOrder: (json['totalPreOrder'] as num).toDouble(),
      grandTotal: (json['grandTotal'] as num).toDouble(),
      paymentStatus: json['paymentStatus'] as String,
      deliveryType: json['deliveryType'] as String,
      orderDate: DateTime.parse(json['orderDate'] as String),
      deliveryDate: json['deliveryDate'] == null
          ? null
          : DateTime.parse(json['deliveryDate'] as String),
      signature: json['signature'] as String?,
      notes: json['notes'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'pdvId': instance.pdvId,
      'pdvName': instance.pdvName,
      'status': instance.status,
      'totalAmount': instance.totalAmount,
      'totalPreOrder': instance.totalPreOrder,
      'grandTotal': instance.grandTotal,
      'paymentStatus': instance.paymentStatus,
      'deliveryType': instance.deliveryType,
      'orderDate': instance.orderDate.toIso8601String(),
      'deliveryDate': instance.deliveryDate?.toIso8601String(),
      'signature': instance.signature,
      'notes': instance.notes,
      'items': instance.items,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    OrderItemModel(
      id: (json['id'] as num).toInt(),
      orderId: (json['orderId'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$OrderItemModelToJson(OrderItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'productId': instance.productId,
      'product': instance.product,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
      'notes': instance.notes,
    };
