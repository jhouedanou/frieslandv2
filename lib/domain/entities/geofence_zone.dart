import 'package:equatable/equatable.dart';

class GeofenceZone extends Equatable {
  final String zoneId;
  final String nomZone;
  final Map<String, dynamic> coordonneesPolygone; // GeoJSON
  final List<String> merchandiserIds;
  final String secteur;
  final String territoire;
  final double rayonBuffer;

  const GeofenceZone({
    required this.zoneId,
    required this.nomZone,
    required this.coordonneesPolygone,
    required this.merchandiserIds,
    required this.secteur,
    required this.territoire,
    required this.rayonBuffer,
  });

  @override
  List<Object> get props => [
    zoneId,
    nomZone,
    coordonneesPolygone,
    merchandiserIds,
    secteur,
    territoire,
    rayonBuffer,
  ];
}