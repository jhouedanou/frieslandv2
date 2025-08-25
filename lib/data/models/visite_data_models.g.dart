// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visite_data_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeolocationData _$GeolocationDataFromJson(Map<String, dynamic> json) =>
    GeolocationData(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$GeolocationDataToJson(GeolocationData instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
    };

EvapData _$EvapDataFromJson(Map<String, dynamic> json) => EvapData(
      present: json['present'] as bool,
      brGold: json['brGold'] as String?,
      br150g: json['br150g'] as String?,
      brb150g: json['brb150g'] as String?,
      br380g: json['br380g'] as String?,
      brb380g: json['brb380g'] as String?,
      pearl380g: json['pearl380g'] as String?,
    );

Map<String, dynamic> _$EvapDataToJson(EvapData instance) => <String, dynamic>{
      'present': instance.present,
      'brGold': instance.brGold,
      'br150g': instance.br150g,
      'brb150g': instance.brb150g,
      'br380g': instance.br380g,
      'brb380g': instance.brb380g,
      'pearl380g': instance.pearl380g,
    };

ImpData _$ImpDataFromJson(Map<String, dynamic> json) => ImpData(
      present: json['present'] as bool,
      prixRespectes: json['prixRespectes'] as bool,
      br2: json['br2'] as String?,
      br16g: json['br16g'] as String?,
      brb16g: json['brb16g'] as String?,
      br360g: json['br360g'] as String?,
      br400gTin: json['br400gTin'] as String?,
      brb360g: json['brb360g'] as String?,
      br900gTin: json['br900gTin'] as String?,
    );

Map<String, dynamic> _$ImpDataToJson(ImpData instance) => <String, dynamic>{
      'present': instance.present,
      'prixRespectes': instance.prixRespectes,
      'br2': instance.br2,
      'br16g': instance.br16g,
      'brb16g': instance.brb16g,
      'br360g': instance.br360g,
      'br400gTin': instance.br400gTin,
      'brb360g': instance.brb360g,
      'br900gTin': instance.br900gTin,
    };

ScmData _$ScmDataFromJson(Map<String, dynamic> json) => ScmData(
      present: json['present'] as bool,
      prixRespectes: json['prixRespectes'] as bool,
      produits: (json['produits'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$ScmDataToJson(ScmData instance) => <String, dynamic>{
      'present': instance.present,
      'prixRespectes': instance.prixRespectes,
      'produits': instance.produits,
    };

UhtData _$UhtDataFromJson(Map<String, dynamic> json) => UhtData(
      present: json['present'] as bool,
      prixRespectes: json['prixRespectes'] as bool,
      produits: (json['produits'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$UhtDataToJson(UhtData instance) => <String, dynamic>{
      'present': instance.present,
      'prixRespectes': instance.prixRespectes,
      'produits': instance.produits,
    };

YaourtData _$YaourtDataFromJson(Map<String, dynamic> json) => YaourtData(
      present: json['present'] as bool,
    );

Map<String, dynamic> _$YaourtDataToJson(YaourtData instance) =>
    <String, dynamic>{
      'present': instance.present,
    };

ProduitsData _$ProduitsDataFromJson(Map<String, dynamic> json) => ProduitsData(
      evap: EvapData.fromJson(json['evap'] as Map<String, dynamic>),
      imp: ImpData.fromJson(json['imp'] as Map<String, dynamic>),
      scm: ScmData.fromJson(json['scm'] as Map<String, dynamic>),
      uht: UhtData.fromJson(json['uht'] as Map<String, dynamic>),
      yaourt: YaourtData.fromJson(json['yaourt'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProduitsDataToJson(ProduitsData instance) =>
    <String, dynamic>{
      'evap': instance.evap,
      'imp': instance.imp,
      'scm': instance.scm,
      'uht': instance.uht,
      'yaourt': instance.yaourt,
    };

ConcurrenceEvapData _$ConcurrenceEvapDataFromJson(Map<String, dynamic> json) =>
    ConcurrenceEvapData(
      present: json['present'] as bool,
      cowmilk: json['cowmilk'] as String?,
      nido150g: json['nido150g'] as String?,
      autre: json['autre'] as String?,
    );

Map<String, dynamic> _$ConcurrenceEvapDataToJson(
        ConcurrenceEvapData instance) =>
    <String, dynamic>{
      'present': instance.present,
      'cowmilk': instance.cowmilk,
      'nido150g': instance.nido150g,
      'autre': instance.autre,
    };

ConcurrenceImpData _$ConcurrenceImpDataFromJson(Map<String, dynamic> json) =>
    ConcurrenceImpData(
      present: json['present'] as bool,
      nido: json['nido'] as String?,
      laity: json['laity'] as String?,
      autre: json['autre'] as String?,
    );

Map<String, dynamic> _$ConcurrenceImpDataToJson(ConcurrenceImpData instance) =>
    <String, dynamic>{
      'present': instance.present,
      'nido': instance.nido,
      'laity': instance.laity,
      'autre': instance.autre,
    };

ConcurrenceScmData _$ConcurrenceScmDataFromJson(Map<String, dynamic> json) =>
    ConcurrenceScmData(
      present: json['present'] as bool,
      topSaho: json['topSaho'] as String?,
      autre: json['autre'] as String?,
      nomConcurrent: json['nomConcurrent'] as String?,
    );

Map<String, dynamic> _$ConcurrenceScmDataToJson(ConcurrenceScmData instance) =>
    <String, dynamic>{
      'present': instance.present,
      'topSaho': instance.topSaho,
      'autre': instance.autre,
      'nomConcurrent': instance.nomConcurrent,
    };

ConcurrenceData _$ConcurrenceDataFromJson(Map<String, dynamic> json) =>
    ConcurrenceData(
      presenceConcurrents: json['presenceConcurrents'] as bool,
      evap: ConcurrenceEvapData.fromJson(json['evap'] as Map<String, dynamic>),
      imp: ConcurrenceImpData.fromJson(json['imp'] as Map<String, dynamic>),
      scm: ConcurrenceScmData.fromJson(json['scm'] as Map<String, dynamic>),
      uht: json['uht'] as bool,
    );

Map<String, dynamic> _$ConcurrenceDataToJson(ConcurrenceData instance) =>
    <String, dynamic>{
      'presenceConcurrents': instance.presenceConcurrents,
      'evap': instance.evap,
      'imp': instance.imp,
      'scm': instance.scm,
      'uht': instance.uht,
    };

VisibiliteInterieureData _$VisibiliteInterieureDataFromJson(
        Map<String, dynamic> json) =>
    VisibiliteInterieureData(
      presenceVisibilite: json['presenceVisibilite'] as bool,
    );

Map<String, dynamic> _$VisibiliteInterieureDataToJson(
        VisibiliteInterieureData instance) =>
    <String, dynamic>{
      'presenceVisibilite': instance.presenceVisibilite,
    };

VisibiliteConcurrenceData _$VisibiliteConcurrenceDataFromJson(
        Map<String, dynamic> json) =>
    VisibiliteConcurrenceData(
      presenceVisibilite: json['presenceVisibilite'] as bool,
      nidoExterieur: json['nidoExterieur'] as bool,
      nidoInterieur: json['nidoInterieur'] as bool,
      laityExterieur: json['laityExterieur'] as bool,
      laityInterieur: json['laityInterieur'] as bool,
      candiaExterieur: json['candiaExterieur'] as bool,
      candiaInterieur: json['candiaInterieur'] as bool,
    );

Map<String, dynamic> _$VisibiliteConcurrenceDataToJson(
        VisibiliteConcurrenceData instance) =>
    <String, dynamic>{
      'presenceVisibilite': instance.presenceVisibilite,
      'nidoExterieur': instance.nidoExterieur,
      'nidoInterieur': instance.nidoInterieur,
      'laityExterieur': instance.laityExterieur,
      'laityInterieur': instance.laityInterieur,
      'candiaExterieur': instance.candiaExterieur,
      'candiaInterieur': instance.candiaInterieur,
    };

VisibiliteData _$VisibiliteDataFromJson(Map<String, dynamic> json) =>
    VisibiliteData(
      interieure: VisibiliteInterieureData.fromJson(
          json['interieure'] as Map<String, dynamic>),
      concurrence: VisibiliteConcurrenceData.fromJson(
          json['concurrence'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VisibiliteDataToJson(VisibiliteData instance) =>
    <String, dynamic>{
      'interieure': instance.interieure,
      'concurrence': instance.concurrence,
    };

ActionsData _$ActionsDataFromJson(Map<String, dynamic> json) => ActionsData(
      referencementProduits: json['referencementProduits'] as bool,
      executionActivitesPromotionnelles:
          json['executionActivitesPromotionnelles'] as bool,
      prospectionPdv: json['prospectionPdv'] as bool,
      verificationFifo: json['verificationFifo'] as bool,
      rangementProduits: json['rangementProduits'] as bool,
      poseAffiches: json['poseAffiches'] as bool,
      poseMaterielVisibilite: json['poseMaterielVisibilite'] as bool,
    );

Map<String, dynamic> _$ActionsDataToJson(ActionsData instance) =>
    <String, dynamic>{
      'referencementProduits': instance.referencementProduits,
      'executionActivitesPromotionnelles':
          instance.executionActivitesPromotionnelles,
      'prospectionPdv': instance.prospectionPdv,
      'verificationFifo': instance.verificationFifo,
      'rangementProduits': instance.rangementProduits,
      'poseAffiches': instance.poseAffiches,
      'poseMaterielVisibilite': instance.poseMaterielVisibilite,
    };
