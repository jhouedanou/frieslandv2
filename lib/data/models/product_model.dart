import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final int id;
  final String code;
  final String name;
  final String category;
  final double price;
  final int stockQuantity;
  final String unit;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
    required this.price,
    required this.stockQuantity,
    required this.unit,
    this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  ProductModel copyWith({
    int? id,
    String? code,
    String? name,
    String? category,
    double? price,
    int? stockQuantity,
    String? unit,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Catégories de produits d'après les captures d'écran
class ProductCategory {
  static const String evap = 'EVAP';
  static const String scm = 'SCM';
  static const String imp = 'IMP';
  static const String uht = 'UHT';
  static const String yaourt = 'YAOURT';
  static const String cerealesAuLait = 'CÉRÉALES AU LAIT';

  static const List<String> all = [
    evap,
    scm,
    imp,
    uht,
    yaourt,
    cerealesAuLait,
  ];

  static String getDisplayName(String category) {
    switch (category) {
      case evap:
        return 'Dispo et Prix EVAP';
      case scm:
        return 'Dispo et Prix SCM';
      case imp:
        return 'Dispo et Prix IMP';
      case uht:
        return 'Dispo et Prix UHT';
      case yaourt:
        return 'Dispo et Prix Yoghurt';
      case cerealesAuLait:
        return 'Dispo et Prix UHT Céréales au lait';
      default:
        return category;
    }
  }
}
