class AppConstants {
  static const String appName = 'Friesland Dashboard';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String visitesCollection = 'visites';
  static const String pdvCollection = 'pdv';
  static const String merchandisersCollection = 'merchandisers';
  static const String geofenceZonesCollection = 'geofence_zones';
  
  // Geofencing
  static const double defaultGeofenceRadius = 300.0; // metres
  static const double minGpsAccuracy = 10.0; // metres
  
  // Product Categories
  static const String evapCategory = 'EVAP';
  static const String impCategory = 'IMP';
  static const String scmCategory = 'SCM';
  static const String uhtCategory = 'UHT';
  static const String yoghurtCategory = 'YOGHURT';
  
  // Product Status
  static const String disponiblePrixRespecte = 'Disponible , Prix respecté';
  static const String disponiblePrixNonRespecte = 'Disponible , Prix non respecté';
  static const String presentPrixRespecte = 'Présent , Prix respecté';
  static const String enRupture = 'En rupture';
  
  // PDV Categories
  static const String boutique = 'Boutique';
  static const String superette = 'Superette';
  static const String kiosque = 'Kiosque';
  static const String tablier = 'Tabliers';
  static const String pushcart = 'Pushcart';
  static const String cafeteria = 'Cafétéria';
  
  // Commercials
  static const List<String> commercials = [
    'COULIBALY PADIE',
    'EBROTTIE MIAN CHRISTIAN INNOCENT',
    'GAI KAMY',
    'OUATTARA ZANGA',
    'Guea Hermann'
  ];
  
  // Colors
  static const int bonnetRougeColor = 0xFFE53E3E;
}