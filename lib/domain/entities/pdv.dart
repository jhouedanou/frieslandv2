import 'package:equatable/equatable.dart';

class PDV extends Equatable {
  final String pdvId;
  final String nomPdv;
  final String canal;
  final String categoriePdv;
  final String sousCategoriePdv;
  final String? autreSousCategorie;
  final String region;
  final String territoire;
  final String zone;
  final String secteur;
  final double latitude;
  final double longitude;
  final double rayonGeofence;
  final String adressage;
  final String? imagePath;
  final DateTime dateCreation;
  final String ajoutePar;
  final String mdm;

  const PDV({
    required this.pdvId,
    required this.nomPdv,
    required this.canal,
    required this.categoriePdv,
    required this.sousCategoriePdv,
    this.autreSousCategorie,
    required this.region,
    required this.territoire,
    required this.zone,
    required this.secteur,
    required this.latitude,
    required this.longitude,
    this.rayonGeofence = 300.0,
    required this.adressage,
    this.imagePath,
    required this.dateCreation,
    required this.ajoutePar,
    required this.mdm,
  });

  @override
  List<Object?> get props => [
    pdvId,
    nomPdv,
    canal,
    categoriePdv,
    sousCategoriePdv,
    autreSousCategorie,
    region,
    territoire,
    zone,
    secteur,
    latitude,
    longitude,
    rayonGeofence,
    adressage,
    imagePath,
    dateCreation,
    ajoutePar,
    mdm,
  ];
}