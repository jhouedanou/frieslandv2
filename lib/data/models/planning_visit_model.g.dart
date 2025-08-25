// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planning_visit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanningVisitModel _$PlanningVisitModelFromJson(Map<String, dynamic> json) =>
    PlanningVisitModel(
      id: (json['id'] as num).toInt(),
      pdvId: (json['pdvId'] as num).toInt(),
      pdvName: json['pdvName'] as String,
      visitDate: DateTime.parse(json['visitDate'] as String),
      status: json['status'] as String,
      merchandiserName: json['merchandiserName'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PlanningVisitModelToJson(PlanningVisitModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pdvId': instance.pdvId,
      'pdvName': instance.pdvName,
      'visitDate': instance.visitDate.toIso8601String(),
      'status': instance.status,
      'merchandiserName': instance.merchandiserName,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

SimplePDV _$SimplePDVFromJson(Map<String, dynamic> json) => SimplePDV(
      id: (json['id'] as num).toInt(),
      nom: json['nom'] as String,
      adresse: json['adresse'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      telephone: json['telephone'] as String,
      email: json['email'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      category: json['category'] as String,
    );

Map<String, dynamic> _$SimplePDVToJson(SimplePDV instance) => <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'adresse': instance.adresse,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'telephone': instance.telephone,
      'email': instance.email,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'category': instance.category,
    };
