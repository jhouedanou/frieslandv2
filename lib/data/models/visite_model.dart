import 'package:json_annotation/json_annotation.dart';
import 'visite_data_models.dart';

part 'visite_model.g.dart';

// Modèle principal Visite selon les spécifications CLAUDE.md
@JsonSerializable()
class VisiteModel {
  final String visiteId;
  final String pdvId;
  final String commercial;
  final DateTime dateVisite;
  final GeolocationData geolocation;
  final bool geofenceValidated;
  final double precisionGps;
  final ProduitsData produits;
  final ConcurrenceData concurrence;
  final VisibiliteData visibilite;
  final ActionsData actions;
  final List<String> images;
  final String syncStatus; // "synced|pending|failed"

  const VisiteModel({
    required this.visiteId,
    required this.pdvId,
    required this.commercial,
    required this.dateVisite,
    required this.geolocation,
    required this.geofenceValidated,
    required this.precisionGps,
    required this.produits,
    required this.concurrence,
    required this.visibilite,
    required this.actions,
    this.images = const [],
    this.syncStatus = 'pending',
  });

  factory VisiteModel.fromJson(Map<String, dynamic> json) => _$VisiteModelFromJson(json);
  Map<String, dynamic> toJson() => _$VisiteModelToJson(this);

  // Conversion depuis API/Database selon format CLAUDE.md
  factory VisiteModel.fromApiResponse(Map<String, dynamic> json) {
    return VisiteModel(
      visiteId: json['visite_id'] ?? '',
      pdvId: json['pdv_id'] ?? '',
      commercial: json['commercial'] ?? '',
      dateVisite: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      geolocation: GeolocationData.fromJson(json['geolocation'] ?? {'lat': 0.0, 'lng': 0.0}),
      geofenceValidated: json['geofence_validated'] ?? false,
      precisionGps: (json['precision_gps'] ?? 0.0).toDouble(),
      produits: ProduitsData.fromJson(json['produits'] ?? {}),
      concurrence: ConcurrenceData.fromJson(json['concurrence'] ?? {}),
      visibilite: VisibiliteData.fromJson(json['visibilite'] ?? {}),
      actions: ActionsData.fromJson(json['actions'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
      syncStatus: json['sync_status'] ?? 'pending',
    );
  }

  // Conversion vers API selon format CLAUDE.md
  Map<String, dynamic> toApiRequest() {
    return {
      'visite_id': visiteId,
      'pdv_id': pdvId,
      'commercial': commercial,
      'date': dateVisite.toIso8601String(),
      'geolocation': geolocation.toJson(),
      'geofence_validated': geofenceValidated,
      'precision_gps': precisionGps,
      'produits': produits.toJson(),
      'concurrence': concurrence.toJson(),
      'visibilite': visibilite.toJson(),
      'actions': actions.toJson(),
      'images': images,
      'sync_status': syncStatus,
    };
  }
}