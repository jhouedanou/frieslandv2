import 'package:equatable/equatable.dart';

class Visite extends Equatable {
  final String visiteId;
  final String pdvId;
  final String nomDuPdv;
  final DateTime dateVisite;
  final String commercial;
  final double latitude;
  final double longitude;
  final double distanceAuPdv;
  final String mdm;
  final String? imagePath;
  final bool geofenceValide;
  final double precisionGps;
  
  // EVAP (Lait évaporé)
  final bool evapPresent;
  final String? evapBrGoldPresent;
  final String? evapBr160gPresent;
  final String? evapBrb160gPresent;
  final String? evapBr400gPresent;
  final String? evapBrb400gPresent;
  final String? evapPearl400gPresent;
  final bool evapPrixRespectes;
  
  // IMP (Lait en poudre)
  final bool impPresent;
  final String? impBr400gPresent;
  final String? impBr900gPresent;
  final String? impBr25kgPresent;
  final String? impBr375gPresent;
  final String? impBrb400gPresent;
  final String? impBr20gPresent;
  final String? impBrb25gPresent;
  final bool impPrixRespectes;
  
  // SCM (Lait concentré sucré)
  final bool scmPresent;
  final String? scmBr1kgPresent;
  final String? scmBrb1kgPresent;
  final String? scmBrb397gPresent;
  final String? scmBr397gPresent;
  final String? scmPearl1kgPresent;
  final bool scmPrixRespectes;
  
  // UHT (Lait UHT)
  final bool uhtPresent;
  final bool uhtPrixRespectes;
  
  // YOGHURT (Yaourt)
  final bool yoghurtPresent;
  final bool yoghurtPrixRespectes;

  const Visite({
    required this.visiteId,
    required this.pdvId,
    required this.nomDuPdv,
    required this.dateVisite,
    required this.commercial,
    required this.latitude,
    required this.longitude,
    required this.distanceAuPdv,
    required this.mdm,
    this.imagePath,
    required this.geofenceValide,
    required this.precisionGps,
    required this.evapPresent,
    this.evapBrGoldPresent,
    this.evapBr160gPresent,
    this.evapBrb160gPresent,
    this.evapBr400gPresent,
    this.evapBrb400gPresent,
    this.evapPearl400gPresent,
    required this.evapPrixRespectes,
    required this.impPresent,
    this.impBr400gPresent,
    this.impBr900gPresent,
    this.impBr25kgPresent,
    this.impBr375gPresent,
    this.impBrb400gPresent,
    this.impBr20gPresent,
    this.impBrb25gPresent,
    required this.impPrixRespectes,
    required this.scmPresent,
    this.scmBr1kgPresent,
    this.scmBrb1kgPresent,
    this.scmBrb397gPresent,
    this.scmBr397gPresent,
    this.scmPearl1kgPresent,
    required this.scmPrixRespectes,
    required this.uhtPresent,
    required this.uhtPrixRespectes,
    required this.yoghurtPresent,
    required this.yoghurtPrixRespectes,
  });

  @override
  List<Object?> get props => [
    visiteId,
    pdvId,
    nomDuPdv,
    dateVisite,
    commercial,
    latitude,
    longitude,
    distanceAuPdv,
    mdm,
    imagePath,
    geofenceValide,
    precisionGps,
    evapPresent,
    evapBrGoldPresent,
    evapBr160gPresent,
    evapBrb160gPresent,
    evapBr400gPresent,
    evapBrb400gPresent,
    evapPearl400gPresent,
    evapPrixRespectes,
    impPresent,
    impBr400gPresent,
    impBr900gPresent,
    impBr25kgPresent,
    impBr375gPresent,
    impBrb400gPresent,
    impBr20gPresent,
    impBrb25gPresent,
    impPrixRespectes,
    scmPresent,
    scmBr1kgPresent,
    scmBrb1kgPresent,
    scmBrb397gPresent,
    scmBr397gPresent,
    scmPearl1kgPresent,
    scmPrixRespectes,
    uhtPresent,
    uhtPrixRespectes,
    yoghurtPresent,
    yoghurtPrixRespectes,
  ];
}