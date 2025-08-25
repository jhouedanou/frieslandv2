import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/pdv.dart';

part 'pdv_model.g.dart';

@JsonSerializable()
class PDVModel extends PDV {
  const PDVModel({
    required super.pdvId,
    required super.nomPdv,
    required super.canal,
    required super.categoriePdv,
    required super.sousCategoriePdv,
    super.autreSousCategorie,
    required super.region,
    required super.territoire,
    required super.zone,
    required super.secteur,
    required super.latitude,
    required super.longitude,
    super.rayonGeofence = 30.0,
    required super.adressage,
    super.imagePath,
    required super.dateCreation,
    required super.ajoutePar,
    required super.mdm,
  });

  factory PDVModel.fromJson(Map<String, dynamic> json) => _$PDVModelFromJson(json);
  Map<String, dynamic> toJson() => _$PDVModelToJson(this);

  factory PDVModel.fromFirestore(Map<String, dynamic> doc) {
    return PDVModel(
      pdvId: doc['pdv_id'] ?? '',
      nomPdv: doc['nom_pdv'] ?? '',
      canal: doc['canal'] ?? '',
      categoriePdv: doc['categorie_pdv'] ?? '',
      sousCategoriePdv: doc['sous_categorie_pdv'] ?? '',
      autreSousCategorie: doc['autre_sous_categorie'],
      region: doc['region'] ?? '',
      territoire: doc['territoire'] ?? '',
      zone: doc['zone'] ?? '',
      secteur: doc['secteur'] ?? '',
      latitude: (doc['latitude'] ?? 0.0).toDouble(),
      longitude: (doc['longitude'] ?? 0.0).toDouble(),
      rayonGeofence: (doc['rayon_geofence'] ?? 30.0).toDouble(),
      adressage: doc['adressage'] ?? '',
      imagePath: doc['image_path'],
      dateCreation: DateTime.fromMillisecondsSinceEpoch(doc['date_creation'] ?? 0),
      ajoutePar: doc['ajoute_par'] ?? '',
      mdm: doc['mdm'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'pdv_id': pdvId,
      'nom_pdv': nomPdv,
      'canal': canal,
      'categorie_pdv': categoriePdv,
      'sous_categorie_pdv': sousCategoriePdv,
      'autre_sous_categorie': autreSousCategorie,
      'region': region,
      'territoire': territoire,
      'zone': zone,
      'secteur': secteur,
      'latitude': latitude,
      'longitude': longitude,
      'rayon_geofence': rayonGeofence,
      'adressage': adressage,
      'image_path': imagePath,
      'date_creation': dateCreation.millisecondsSinceEpoch,
      'ajoute_par': ajoutePar,
      'mdm': mdm,
    };
  }
}