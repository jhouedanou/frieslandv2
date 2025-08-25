import 'package:json_annotation/json_annotation.dart';

part 'visite_data_models.g.dart';

// Structure géolocalisation selon CLAUDE.md
@JsonSerializable()
class GeolocationData {
  final double lat;
  final double lng;

  const GeolocationData({
    required this.lat,
    required this.lng,
  });

  factory GeolocationData.fromJson(Map<String, dynamic> json) => _$GeolocationDataFromJson(json);
  Map<String, dynamic> toJson() => _$GeolocationDataToJson(this);
}

// Structure produits EVAP selon CLAUDE.md
@JsonSerializable()
class EvapData {
  final bool present;
  final String? brGold; // "En rupture" | "Présent"
  final String? br150g;
  final String? brb150g;
  final String? br380g;
  final String? brb380g;
  final String? pearl380g;

  const EvapData({
    required this.present,
    this.brGold,
    this.br150g,
    this.brb150g,
    this.br380g,
    this.brb380g,
    this.pearl380g,
  });

  factory EvapData.fromJson(Map<String, dynamic> json) => _$EvapDataFromJson(json);
  Map<String, dynamic> toJson() => _$EvapDataToJson(this);
}

// Structure produits IMP selon CLAUDE.md
@JsonSerializable()
class ImpData {
  final bool present;
  final bool prixRespectes;
  final String? br2;
  final String? br16g;
  final String? brb16g;
  final String? br360g;
  final String? br400gTin;
  final String? brb360g;
  final String? br900gTin;

  const ImpData({
    required this.present,
    required this.prixRespectes,
    this.br2,
    this.br16g,
    this.brb16g,
    this.br360g,
    this.br400gTin,
    this.brb360g,
    this.br900gTin,
  });

  factory ImpData.fromJson(Map<String, dynamic> json) => _$ImpDataFromJson(json);
  Map<String, dynamic> toJson() => _$ImpDataToJson(this);
}

// Structure produits SCM selon CLAUDE.md
@JsonSerializable()
class ScmData {
  final bool present;
  final bool prixRespectes;
  final Map<String, String>? produits; // Produits dynamiques

  const ScmData({
    required this.present,
    required this.prixRespectes,
    this.produits,
  });

  factory ScmData.fromJson(Map<String, dynamic> json) => _$ScmDataFromJson(json);
  Map<String, dynamic> toJson() => _$ScmDataToJson(this);
}

// Structure produits UHT selon CLAUDE.md
@JsonSerializable()
class UhtData {
  final bool present;
  final bool prixRespectes;
  final Map<String, String>? produits; // Produits dynamiques

  const UhtData({
    required this.present,
    required this.prixRespectes,
    this.produits,
  });

  factory UhtData.fromJson(Map<String, dynamic> json) => _$UhtDataFromJson(json);
  Map<String, dynamic> toJson() => _$UhtDataToJson(this);
}

// Structure produits YAOURT selon CLAUDE.md
@JsonSerializable()
class YaourtData {
  final bool present;

  const YaourtData({
    required this.present,
  });

  factory YaourtData.fromJson(Map<String, dynamic> json) => _$YaourtDataFromJson(json);
  Map<String, dynamic> toJson() => _$YaourtDataToJson(this);
}

// Structure complète produits selon CLAUDE.md
@JsonSerializable()
class ProduitsData {
  final EvapData evap;
  final ImpData imp;
  final ScmData scm;
  final UhtData uht;
  final YaourtData yaourt;

  const ProduitsData({
    required this.evap,
    required this.imp,
    required this.scm,
    required this.uht,
    required this.yaourt,
  });

  factory ProduitsData.fromJson(Map<String, dynamic> json) => _$ProduitsDataFromJson(json);
  Map<String, dynamic> toJson() => _$ProduitsDataToJson(this);
}

// Structure concurrence EVAP selon CLAUDE.md
@JsonSerializable()
class ConcurrenceEvapData {
  final bool present;
  final String? cowmilk; // "En rupture" | "Présent"
  final String? nido150g;
  final String? autre;

  const ConcurrenceEvapData({
    required this.present,
    this.cowmilk,
    this.nido150g,
    this.autre,
  });

  factory ConcurrenceEvapData.fromJson(Map<String, dynamic> json) => _$ConcurrenceEvapDataFromJson(json);
  Map<String, dynamic> toJson() => _$ConcurrenceEvapDataToJson(this);
}

// Structure concurrence IMP selon CLAUDE.md
@JsonSerializable()
class ConcurrenceImpData {
  final bool present;
  final String? nido;
  final String? laity;
  final String? autre;

  const ConcurrenceImpData({
    required this.present,
    this.nido,
    this.laity,
    this.autre,
  });

  factory ConcurrenceImpData.fromJson(Map<String, dynamic> json) => _$ConcurrenceImpDataFromJson(json);
  Map<String, dynamic> toJson() => _$ConcurrenceImpDataToJson(this);
}

// Structure concurrence SCM selon CLAUDE.md
@JsonSerializable()
class ConcurrenceScmData {
  final bool present;
  final String? topSaho;
  final String? autre;
  final String? nomConcurrent; // Texte libre

  const ConcurrenceScmData({
    required this.present,
    this.topSaho,
    this.autre,
    this.nomConcurrent,
  });

  factory ConcurrenceScmData.fromJson(Map<String, dynamic> json) => _$ConcurrenceScmDataFromJson(json);
  Map<String, dynamic> toJson() => _$ConcurrenceScmDataToJson(this);
}

// Structure complète concurrence selon CLAUDE.md
@JsonSerializable()
class ConcurrenceData {
  final bool presenceConcurrents;
  final ConcurrenceEvapData evap;
  final ConcurrenceImpData imp;
  final ConcurrenceScmData scm;
  final bool uht;

  const ConcurrenceData({
    required this.presenceConcurrents,
    required this.evap,
    required this.imp,
    required this.scm,
    required this.uht,
  });

  factory ConcurrenceData.fromJson(Map<String, dynamic> json) => _$ConcurrenceDataFromJson(json);
  Map<String, dynamic> toJson() => _$ConcurrenceDataToJson(this);
}

// Structure visibilité intérieure selon CLAUDE.md
@JsonSerializable()
class VisibiliteInterieureData {
  final bool presenceVisibilite;

  const VisibiliteInterieureData({
    required this.presenceVisibilite,
  });

  factory VisibiliteInterieureData.fromJson(Map<String, dynamic> json) => _$VisibiliteInterieureDataFromJson(json);
  Map<String, dynamic> toJson() => _$VisibiliteInterieureDataToJson(this);
}

// Structure visibilité concurrence selon CLAUDE.md
@JsonSerializable()
class VisibiliteConcurrenceData {
  final bool presenceVisibilite;
  final bool nidoExterieur;
  final bool nidoInterieur;
  final bool laityExterieur;
  final bool laityInterieur;
  final bool candiaExterieur;
  final bool candiaInterieur;

  const VisibiliteConcurrenceData({
    required this.presenceVisibilite,
    required this.nidoExterieur,
    required this.nidoInterieur,
    required this.laityExterieur,
    required this.laityInterieur,
    required this.candiaExterieur,
    required this.candiaInterieur,
  });

  factory VisibiliteConcurrenceData.fromJson(Map<String, dynamic> json) => _$VisibiliteConcurrenceDataFromJson(json);
  Map<String, dynamic> toJson() => _$VisibiliteConcurrenceDataToJson(this);
}

// Structure complète visibilité selon CLAUDE.md
@JsonSerializable()
class VisibiliteData {
  final VisibiliteInterieureData interieure;
  final VisibiliteConcurrenceData concurrence;

  const VisibiliteData({
    required this.interieure,
    required this.concurrence,
  });

  factory VisibiliteData.fromJson(Map<String, dynamic> json) => _$VisibiliteDataFromJson(json);
  Map<String, dynamic> toJson() => _$VisibiliteDataToJson(this);
}

// Structure actions terrain selon CLAUDE.md - 7 actions avec toggles OUI/NON
@JsonSerializable()
class ActionsData {
  final bool referencementProduits;
  final bool executionActivitesPromotionnelles;
  final bool prospectionPdv;
  final bool verificationFifo;
  final bool rangementProduits;
  final bool poseAffiches;
  final bool poseMaterielVisibilite;

  const ActionsData({
    required this.referencementProduits,
    required this.executionActivitesPromotionnelles,
    required this.prospectionPdv,
    required this.verificationFifo,
    required this.rangementProduits,
    required this.poseAffiches,
    required this.poseMaterielVisibilite,
  });

  factory ActionsData.fromJson(Map<String, dynamic> json) => _$ActionsDataFromJson(json);
  Map<String, dynamic> toJson() => _$ActionsDataToJson(this);
}