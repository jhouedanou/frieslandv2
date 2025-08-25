// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdv_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PDVModel _$PDVModelFromJson(Map<String, dynamic> json) => PDVModel(
      pdvId: json['pdvId'] as String,
      nomPdv: json['nomPdv'] as String,
      canal: json['canal'] as String,
      categoriePdv: json['categoriePdv'] as String,
      sousCategoriePdv: json['sousCategoriePdv'] as String,
      autreSousCategorie: json['autreSousCategorie'] as String?,
      region: json['region'] as String,
      territoire: json['territoire'] as String,
      zone: json['zone'] as String,
      secteur: json['secteur'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      rayonGeofence: (json['rayonGeofence'] as num?)?.toDouble() ?? 300.0,
      adressage: json['adressage'] as String,
      imagePath: json['imagePath'] as String?,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      ajoutePar: json['ajoutePar'] as String,
      mdm: json['mdm'] as String,
    );

Map<String, dynamic> _$PDVModelToJson(PDVModel instance) => <String, dynamic>{
      'pdvId': instance.pdvId,
      'nomPdv': instance.nomPdv,
      'canal': instance.canal,
      'categoriePdv': instance.categoriePdv,
      'sousCategoriePdv': instance.sousCategoriePdv,
      'autreSousCategorie': instance.autreSousCategorie,
      'region': instance.region,
      'territoire': instance.territoire,
      'zone': instance.zone,
      'secteur': instance.secteur,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'rayonGeofence': instance.rayonGeofence,
      'adressage': instance.adressage,
      'imagePath': instance.imagePath,
      'dateCreation': instance.dateCreation.toIso8601String(),
      'ajoutePar': instance.ajoutePar,
      'mdm': instance.mdm,
    };
