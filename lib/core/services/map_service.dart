import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import '../../data/models/pdv_model.dart';

// Service de carte avec OpenStreetMap selon demandes utilisateur
class MapService {
  static const String _osmUrlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String _userAgent = 'FrieslandBonnetRouge/1.0';
  
  // Centre par défaut sur Treichville selon demandes utilisateur
  static const LatLng _defaultCenter = LatLng(5.2500, -4.0235); // Rue Roger Abinader
  static const double _defaultZoom = 15.0;
  static const double _geofenceRadius = 100.0; // 100m selon demande utilisateur

  // Créer une carte OpenStreetMap centrée sur Treichville
  static Widget createTreichvilleMap({
    required List<PDVModel> pdvs,
    LatLng? currentPosition,
    Function(PDVModel)? onPDVTap,
    bool showGeofencing = true,
  }) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: currentPosition ?? _defaultCenter,
        initialZoom: _defaultZoom,
        maxZoom: 19.0,
        minZoom: 10.0,
        onTap: (tapPosition, point) {
          // Vérifier si tap sur un PDV
          if (onPDVTap != null) {
            final nearestPDV = _findNearestPDV(point, pdvs);
            if (nearestPDV != null) {
              onPDVTap(nearestPDV);
            }
          }
        },
      ),
      children: [
        // Couche OpenStreetMap
        TileLayer(
          urlTemplate: _osmUrlTemplate,
          userAgentPackageName: _userAgent,
          maxZoom: 19,
          tileBuilder: (context, widget, tile) {
            return DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: widget,
            );
          },
        ),
        
        // Marqueurs PDV avec géofencing
        MarkerLayer(
          markers: pdvs.map((pdv) => _createPDVMarker(
            pdv, 
            showGeofencing,
            onTap: onPDVTap,
          )).toList(),
        ),

        // Position actuelle si disponible
        if (currentPosition != null)
          MarkerLayer(
            markers: [_createCurrentPositionMarker(currentPosition)],
          ),

        // Couche géofencing retirée selon demande utilisateur
      ],
    );
  }

  // Créer un marqueur pour un PDV selon style Bonnet Rouge
  static Marker _createPDVMarker(
    PDVModel pdv, 
    bool showGeofencing,
    {Function(PDVModel)? onTap}
  ) {
    return Marker(
      point: LatLng(pdv.latitude, pdv.longitude),
      width: 50.0,
      height: 50.0,
      child: GestureDetector(
        onTap: () => onTap?.call(pdv),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE53E3E), // Couleur Bonnet Rouge #E53E3E
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.store,
                color: Colors.white,
                size: 20,
              ),
              Text(
                pdv.canal.substring(0, 1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Créer un marqueur pour la position actuelle
  static Marker _createCurrentPositionMarker(LatLng position) {
    return Marker(
      point: position,
      width: 30.0,
      height: 30.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: const Icon(
          Icons.my_location,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  // Méthode _createGeofenceCircle retirée selon demande utilisateur

  // Trouver le PDV le plus proche d'un point
  static PDVModel? _findNearestPDV(LatLng point, List<PDVModel> pdvs) {
    const double tapThreshold = 100.0; // 100m de tolérance pour le tap
    
    PDVModel? nearest;
    double minDistance = double.infinity;

    for (final pdv in pdvs) {
      final distance = Geolocator.distanceBetween(
        point.latitude,
        point.longitude,
        pdv.latitude,
        pdv.longitude,
      );

      if (distance < tapThreshold && distance < minDistance) {
        minDistance = distance;
        nearest = pdv;
      }
    }

    return nearest;
  }

  // Calculer l'itinéraire optimisé selon route Roger Abinader
  static List<LatLng> calculateOptimizedRoute(List<PDVModel> pdvs, LatLng startPoint) {
    List<LatLng> route = [startPoint];
    List<PDVModel> remaining = [...pdvs];

    LatLng currentPoint = startPoint;

    while (remaining.isNotEmpty) {
      // Trouver le PDV le plus proche
      remaining.sort((a, b) {
        final distanceA = Geolocator.distanceBetween(
          currentPoint.latitude,
          currentPoint.longitude,
          a.latitude,
          a.longitude,
        );
        final distanceB = Geolocator.distanceBetween(
          currentPoint.latitude,
          currentPoint.longitude,
          b.latitude,
          b.longitude,
        );
        return distanceA.compareTo(distanceB);
      });

      final nearest = remaining.removeAt(0);
      final nextPoint = LatLng(nearest.latitude, nearest.longitude);
      route.add(nextPoint);
      currentPoint = nextPoint;
    }

    return route;
  }

  // Vérifier si une position est dans le géofencing selon CLAUDE.md
  static bool isWithinGeofence(
    Position currentPosition,
    PDVModel pdv,
    {double? customRadius}
  ) {
    final distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      pdv.latitude,
      pdv.longitude,
    );

    final radius = customRadius ?? pdv.rayonGeofence ?? _geofenceRadius;
    return distance <= radius;
  }

  // Obtenir les coordonnées pour Treichville / Roger Abinader
  static LatLng getTreichvilleBounds() {
    return _defaultCenter;
  }

  // Calculer la distance totale d'une route
  static double calculateRouteDistance(List<LatLng> route) {
    if (route.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < route.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        route[i].latitude,
        route[i].longitude,
        route[i + 1].latitude,
        route[i + 1].longitude,
      );
    }

    return totalDistance;
  }

  // Estimer le temps de parcours
  static Duration estimateRouteTime(List<LatLng> route, {double speedKmh = 20.0}) {
    final distanceKm = calculateRouteDistance(route) / 1000.0;
    final timeHours = distanceKm / speedKmh;
    return Duration(minutes: (timeHours * 60).round());
  }
}
