import 'package:json_annotation/json_annotation.dart';
import 'product_model.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel {
  final int id;
  final String orderNumber;
  final int pdvId;
  final String pdvName;
  final String status;
  final double totalAmount;
  final double totalPreOrder;
  final double grandTotal;
  final String paymentStatus;
  final String deliveryType;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String? signature;
  final String? notes;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.pdvId,
    required this.pdvName,
    required this.status,
    required this.totalAmount,
    required this.totalPreOrder,
    required this.grandTotal,
    required this.paymentStatus,
    required this.deliveryType,
    required this.orderDate,
    this.deliveryDate,
    this.signature,
    this.notes,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}

@JsonSerializable()
class OrderItemModel {
  final int id;
  final int orderId;
  final int productId;
  final ProductModel product;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? notes;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.notes,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);
}

// Statuts de commande
class OrderStatus {
  static const String draft = 'DRAFT';
  static const String pending = 'PENDING';
  static const String confirmed = 'CONFIRMED';
  static const String shipped = 'SHIPPED';
  static const String delivered = 'DELIVERED';
  static const String cancelled = 'CANCELLED';

  static const List<String> all = [
    draft,
    pending,
    confirmed,
    shipped,
    delivered,
    cancelled,
  ];
}

// Statuts de paiement
class PaymentStatus {
  static const String pending = 'PENDING';
  static const String paid = 'PAID';
  static const String partiallyPaid = 'PARTIALLY_PAID';
  static const String unpaid = 'UNPAID';

  static const List<String> all = [
    pending,
    paid,
    partiallyPaid,
    unpaid,
  ];
}

// Types de livraison
class DeliveryType {
  static const String immediate = 'IMMEDIATE';
  static const String scheduled = 'SCHEDULED';

  static const List<String> all = [
    immediate,
    scheduled,
  ];
}
