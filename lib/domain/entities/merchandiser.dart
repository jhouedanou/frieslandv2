import 'package:equatable/equatable.dart';

class Merchandiser extends Equatable {
  final String merchandiserId;
  final String nom;
  final String email;
  final String telephone;
  final String zoneAssignee;
  final List<String> secteursAssignes;
  final Map<String, dynamic>? zoneGeofence; // GeoJSON

  const Merchandiser({
    required this.merchandiserId,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.zoneAssignee,
    required this.secteursAssignes,
    this.zoneGeofence,
  });

  @override
  List<Object?> get props => [
    merchandiserId,
    nom,
    email,
    telephone,
    zoneAssignee,
    secteursAssignes,
    zoneGeofence,
  ];
}