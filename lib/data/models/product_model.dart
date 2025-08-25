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

  // Vrais produits par catégorie d'après les captures
  static Map<String, List<Map<String, String>>> getRealProducts() {
    return {
      evap: [
        {'name': 'EVAP-BR Gold', 'code': 'EVAP-BR-GOLD'},
        {'name': 'EVAP-BR 160g', 'code': 'EVAP-BR-160G'},
        {'name': 'EVAP-BRB 160g', 'code': 'EVAP-BRB-160G'},
        {'name': 'EVAP-BR 400g', 'code': 'EVAP-BR-400G'},
        {'name': 'EVAP-BRB 400g', 'code': 'EVAP-BRB-400G'},
        {'name': 'EVAP-Pearl 400g', 'code': 'EVAP-PEARL-400G'},
      ],
      scm: [
        {'name': 'SCM-BR 1Kg', 'code': 'SCM-BR-1KG'},
        {'name': 'SCM-BRB 1Kg', 'code': 'SCM-BRB-1KG'},
        {'name': 'SCM-BRB 397g', 'code': 'SCM-BRB-397G'},
        {'name': 'SCM-BR 397g', 'code': 'SCM-BR-397G'},
        {'name': 'SCM-Pearl 1Kg', 'code': 'SCM-PEARL-1KG'},
      ],
      imp: [
        {'name': 'IMP-BR 400g', 'code': 'IMP-BR-400G'},
        {'name': 'IMP-BR 900g', 'code': 'IMP-BR-900G'},
        {'name': 'IMP-BR 2.5 Kg', 'code': 'IMP-BR-2.5KG'},
        {'name': 'IMP-BR 375g', 'code': 'IMP-BR-375G'},
        {'name': 'IMP-BRB 400g', 'code': 'IMP-BRB-400G'},
        {'name': 'IMP-BR 20g', 'code': 'IMP-BR-20G'},
        {'name': 'IMP-BRB 25g', 'code': 'IMP-BRB-25G'},
      ],
      yaourt: [
        {'name': 'YAOURT-BR Yogoo nature mini 90 ml', 'code': 'YAOURT-BR-NATURE-90ML'},
        {'name': 'YAOURT-BR Yogoo fraise mini 90 ml', 'code': 'YAOURT-BR-FRAISE-90ML'},
        {'name': 'YAOURT-BR Yogoo fraise maxi 318 ml', 'code': 'YAOURT-BR-FRAISE-318ML'},
        {'name': 'YAOURT-BR Yogoo nature maxi 318 ml', 'code': 'YAOURT-BR-NATURE-318ML'},
      ],
      uht: [
        {'name': 'UHT-Demi écrémé', 'code': 'UHT-DEMI-ECREME'},
        {'name': 'UHT-Elopack 500 ml', 'code': 'UHT-ELOPACK-500ML'},
        {'name': 'UHT-Brique 1L', 'code': 'UHT-BRIQUE-1L'},
      ],
      cerealesAuLait: [
        {'name': 'Céréales au lait-BRCV', 'code': 'CEREALES-BRCV'},
        {'name': 'Céréales au lait-BRCC', 'code': 'CEREALES-BRCC'},
      ],
    };
  }
}
