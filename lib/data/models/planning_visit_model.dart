import 'package:json_annotation/json_annotation.dart';

part 'planning_visit_model.g.dart';

@JsonSerializable()
class PlanningVisitModel {
  final int id;
  final int pdvId;
  final String pdvName;
  final DateTime visitDate;
  final String status;
  final String merchandiserName;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlanningVisitModel({
    required this.id,
    required this.pdvId,
    required this.pdvName,
    required this.visitDate,
    required this.status,
    required this.merchandiserName,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlanningVisitModel.fromJson(Map<String, dynamic> json) =>
      _$PlanningVisitModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlanningVisitModelToJson(this);

  PlanningVisitModel copyWith({
    int? id,
    int? pdvId,
    String? pdvName,
    DateTime? visitDate,
    String? status,
    String? merchandiserName,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlanningVisitModel(
      id: id ?? this.id,
      pdvId: pdvId ?? this.pdvId,
      pdvName: pdvName ?? this.pdvName,
      visitDate: visitDate ?? this.visitDate,
      status: status ?? this.status,
      merchandiserName: merchandiserName ?? this.merchandiserName,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Simple PDV model for orders
@JsonSerializable()
class SimplePDV {
  final int id;
  final String nom;
  final String adresse;
  final double latitude;
  final double longitude;
  final String telephone;
  final String email;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category;

  const SimplePDV({
    required this.id,
    required this.nom,
    required this.adresse,
    required this.latitude,
    required this.longitude,
    required this.telephone,
    required this.email,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
  });

  factory SimplePDV.fromJson(Map<String, dynamic> json) =>
      _$SimplePDVFromJson(json);

  Map<String, dynamic> toJson() => _$SimplePDVToJson(this);
}
