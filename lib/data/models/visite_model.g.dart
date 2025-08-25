// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visite_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisiteModel _$VisiteModelFromJson(Map<String, dynamic> json) => VisiteModel(
      visiteId: json['visiteId'] as String,
      pdvId: json['pdvId'] as String,
      commercial: json['commercial'] as String,
      dateVisite: DateTime.parse(json['dateVisite'] as String),
      geolocation:
          GeolocationData.fromJson(json['geolocation'] as Map<String, dynamic>),
      geofenceValidated: json['geofenceValidated'] as bool,
      precisionGps: (json['precisionGps'] as num).toDouble(),
      produits: ProduitsData.fromJson(json['produits'] as Map<String, dynamic>),
      concurrence:
          ConcurrenceData.fromJson(json['concurrence'] as Map<String, dynamic>),
      visibilite:
          VisibiliteData.fromJson(json['visibilite'] as Map<String, dynamic>),
      actions: ActionsData.fromJson(json['actions'] as Map<String, dynamic>),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      syncStatus: json['syncStatus'] as String? ?? 'pending',
    );

Map<String, dynamic> _$VisiteModelToJson(VisiteModel instance) =>
    <String, dynamic>{
      'visiteId': instance.visiteId,
      'pdvId': instance.pdvId,
      'commercial': instance.commercial,
      'dateVisite': instance.dateVisite.toIso8601String(),
      'geolocation': instance.geolocation,
      'geofenceValidated': instance.geofenceValidated,
      'precisionGps': instance.precisionGps,
      'produits': instance.produits,
      'concurrence': instance.concurrence,
      'visibilite': instance.visibilite,
      'actions': instance.actions,
      'images': instance.images,
      'syncStatus': instance.syncStatus,
    };
