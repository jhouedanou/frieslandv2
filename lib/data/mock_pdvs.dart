import '../domain/entities/pdv.dart';

/// PDVs fictifs pour l'utilisateur connecté
/// Inclut le PDV spécifique aux coordonnées 5.294972583702423, -3.996776177589156
class MockPDVs {
  static List<PDV> getFictionalPDVs() {
    return [
      // PDV PRINCIPAL - Coordonnées exactes demandées
      PDV(
        pdvId: 'TR_FICT_001',
        nomPdv: 'Superette Central Treichville',
        canal: 'Moderne',
        categoriePdv: 'Superette',
        sousCategoriePdv: 'Superette',
        region: 'ABIDJAN',
        territoire: 'ABIDJAN SUD',
        zone: 'ABIDJAN SUD',
        secteur: 'TREICHVILLE',
        latitude: 5.294972583702423,
        longitude: -3.996776177589156,
        rayonGeofence: 100.0,
        adressage: 'Avenue de la République, Treichville',
        dateCreation: DateTime.now().subtract(const Duration(days: 10)),
        ajoutePar: 'test.treichville@friesland.ci',
        mdm: 'FR_PRINCIPAL_001',
      ),
      
      // PDV 2 - Dans les environs
      PDV(
        pdvId: 'TR_FICT_002',
        nomPdv: 'Boutique du Marché Central',
        canal: 'Traditionnel',
        categoriePdv: 'Boutique',
        sousCategoriePdv: 'Boutique',
        region: 'ABIDJAN',
        territoire: 'ABIDJAN SUD',
        zone: 'ABIDJAN SUD',
        secteur: 'TREICHVILLE',
        latitude: 5.294580,
        longitude: -3.996234,
        rayonGeofence: 100.0,
        adressage: 'Marché Central, Treichville',
        dateCreation: DateTime.now().subtract(const Duration(days: 8)),
        ajoutePar: 'test.treichville@friesland.ci',
        mdm: 'FR_FICT_002',
      ),
      
      // PDV 3
      PDV(
        pdvId: 'TR_FICT_003',
        nomPdv: 'Épicerie Avenue 7',
        canal: 'Traditionnel',
        categoriePdv: 'Épicerie',
        sousCategoriePdv: 'Épicerie',
        region: 'ABIDJAN',
        territoire: 'ABIDJAN SUD',
        zone: 'ABIDJAN SUD',
        secteur: 'TREICHVILLE',
        latitude: 5.295123,
        longitude: -3.997045,
        rayonGeofence: 100.0,
        adressage: 'Avenue 7, Treichville',
        dateCreation: DateTime.now().subtract(const Duration(days: 7)),
        ajoutePar: 'test.treichville@friesland.ci',
        mdm: 'FR_FICT_003',
      ),
      
      // PDV 4
      PDV(
        pdvId: 'TR_FICT_004',
        nomPdv: 'Mini-Market Boulevard Lagunaire',
        canal: 'Moderne',
        categoriePdv: 'Mini-Market',
        sousCategoriePdv: 'Mini-Market',
        region: 'ABIDJAN',
        territoire: 'ABIDJAN SUD',
        zone: 'ABIDJAN SUD',
        secteur: 'TREICHVILLE',
        latitude: 5.294456,
        longitude: -3.996890,
        rayonGeofence: 100.0,
        adressage: 'Boulevard Lagunaire, Treichville',
        dateCreation: DateTime.now().subtract(const Duration(days: 6)),
        ajoutePar: 'test.treichville@friesland.ci',
        mdm: 'FR_FICT_004',
      ),
      
      // PDV 5
      PDV(
        pdvId: 'TR_FICT_005',
        nomPdv: 'Superette Nouvelle Route',
        canal: 'Moderne',
        categoriePdv: 'Superette',
        sousCategoriePdv: 'Superette',
        region: 'ABIDJAN',
        territoire: 'ABIDJAN SUD',
        zone: 'ABIDJAN SUD',
        secteur: 'TREICHVILLE',
        latitude: 5.295678,
        longitude: -3.996123,
        rayonGeofence: 100.0,
        adressage: 'Nouvelle Route, Treichville',
        dateCreation: DateTime.now().subtract(const Duration(days: 5)),
        ajoutePar: 'test.treichville@friesland.ci',
        mdm: 'FR_FICT_005',
      ),
      
      // PDV 6
      PDV(
        pdvId: 'TR_FICT_006',
        nomPdv: 'Boutique Quartier Commerce',
        canal: 'Traditionnel',
        categoriePdv: 'Boutique',
        sousCategoriePdv: 'Boutique',
        region: 'ABIDJAN',
        territoire: 'ABIDJAN SUD',
        zone: 'ABIDJAN SUD',
        secteur: 'TREICHVILLE',
        latitude: 5.294234,
        longitude: -3.997234,
        rayonGeofence: 100.0,
        adressage: 'Quartier Commerce, Treichville',
        dateCreation: DateTime.now().subtract(const Duration(days: 4)),
        ajoutePar: 'test.treichville@friesland.ci',
        mdm: 'FR_FICT_006',
      ),
      
      // PDV 7
      PDV(
        pdvId: 'TR_FICT_007',
        nomPdv: 'Épicerie Rue des Palmiers',
        canal: 'Traditionnel',
        categoriePdv: 'Épicerie',
        sousCategoriePdv: 'Épicerie',
        region: 'ABIDJAN',
        territoire: 'ABIDJAN SUD',
        zone: 'ABIDJAN SUD',
        secteur: 'TREICHVILLE',
        latitude: 5.295890,
        longitude: -3.996567,
        rayonGeofence: 100.0,
        adressage: 'Rue des Palmiers, Treichville',
        dateCreation: DateTime.now().subtract(const Duration(days: 3)),
        ajoutePar: 'test.treichville@friesland.ci',
        mdm: 'FR_FICT_007',
      ),
      
      // PDV 8
      PDV(
        pdvId: 'TR_FICT_008',
        nomPdv: 'Mini-Market Place de la Paix',
        canal: 'Moderne',
        categoriePdv: 'Mini-Market',
        sousCategoriePdv: 'Mini-Market',
        region: 'ABIDJAN',
        territoire: 'ABIDJAN SUD',
        zone: 'ABIDJAN SUD',
        secteur: 'TREICHVILLE',
        latitude: 5.294789,
        longitude: -3.996890,
        rayonGeofence: 100.0,
        adressage: 'Place de la Paix, Treichville',
        dateCreation: DateTime.now().subtract(const Duration(days: 2)),
        ajoutePar: 'test.treichville@friesland.ci',
        mdm: 'FR_FICT_008',
      ),
      
      // PDV 9
      PDV(
        pdvId: 'TR_FICT_009',
        nomPdv: 'Superette Avenue des Cocotiers',
        canal: 'Moderne',
        categoriePdv: 'Superette',
        sousCategoriePdv: 'Superette',
        region: 'ABIDJAN',
        territoire: 'ABIDJAN SUD',
        zone: 'ABIDJAN SUD',
        secteur: 'TREICHVILLE',
        latitude: 5.295345,
        longitude: -3.997123,
        rayonGeofence: 100.0,
        adressage: 'Avenue des Cocotiers, Treichville',
        dateCreation: DateTime.now().subtract(const Duration(days: 1)),
        ajoutePar: 'test.treichville@friesland.ci',
        mdm: 'FR_FICT_009',
      ),
      
      // PDV 10
      PDV(
        pdvId: 'TR_FICT_010',
        nomPdv: 'Boutique Carrefour Principal',
        canal: 'Traditionnel',
        categoriePdv: 'Boutique',
        sousCategoriePdv: 'Boutique',
        region: 'ABIDJAN',
        territoire: 'ABIDJAN SUD',
        zone: 'ABIDJAN SUD',
        secteur: 'TREICHVILLE',
        latitude: 5.294567,
        longitude: -3.996345,
        rayonGeofence: 100.0,
        adressage: 'Carrefour Principal, Treichville',
        dateCreation: DateTime.now(),
        ajoutePar: 'test.treichville@friesland.ci',
        mdm: 'FR_FICT_010',
      ),
    ];
  }
  
  /// Retourne le PDV principal (coordonnées exactes demandées)
  static PDV getPrincipalPDV() {
    return getFictionalPDVs().first;
  }
  
  /// Retourne les PDVs dans un rayon donné (en mètres) autour d'un point
  static List<PDV> getPDVsInRadius(double lat, double lon, double radiusInMeters) {
    return getFictionalPDVs().where((pdv) {
      double distance = _calculateDistance(lat, lon, pdv.latitude, pdv.longitude);
      return distance <= radiusInMeters;
    }).toList();
  }
  
  /// Calcule la distance entre deux points géographiques (en mètres)
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double radiusEarth = 6371000; // Rayon de la Terre en mètres
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = 
        (dLat / 2) * (dLat / 2) +
        _degreesToRadians(lat1) * _degreesToRadians(lat2) *
        (dLon / 2) * (dLon / 2);
    double c = 2 * 3.14159265359 * radiusEarth * a / (2 * 3.14159265359);
    return radiusEarth * c;
  }
  
  static double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}
