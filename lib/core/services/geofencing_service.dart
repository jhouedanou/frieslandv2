import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geodesy/geodesy.dart';
import '../constants/app_constants.dart';
import '../../domain/entities/pdv.dart';

class GeofencingService {
  static final GeofencingService _instance = GeofencingService._internal();
  factory GeofencingService() => _instance;
  GeofencingService._internal();

  final Geodesy _geodesy = Geodesy();
  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;

  // Stream controllers for geofencing events
  final StreamController<bool> _geofenceStatusController = StreamController<bool>.broadcast();
  final StreamController<double> _distanceController = StreamController<double>.broadcast();

  Stream<bool> get geofenceStatus => _geofenceStatusController.stream;
  Stream<double> get distanceStream => _distanceController.stream;

  Position? get currentPosition => _currentPosition;

  Future<void> initialize() async {
    await _checkPermissions();
    await _getCurrentPosition();
    _startLocationTracking();
  }

  Future<void> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }
  }

  Future<void> _getCurrentPosition() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      throw Exception('Failed to get current position: $e');
    }
  }

  void _startLocationTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _currentPosition = position;
    });
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    final LatLng point1 = LatLng(lat1, lon1);
    final LatLng point2 = LatLng(lat2, lon2);
    return _geodesy.distanceBetweenTwoGeoPoints(point1, point2).toDouble();
  }

  bool isWithinGeofence(PDV pdv, Position? position) {
    if (position == null) return false;
    
    final distance = calculateDistance(
      position.latitude,
      position.longitude,
      pdv.latitude,
      pdv.longitude,
    );

    return distance <= pdv.rayonGeofence;
  }

  GeofenceValidationResult validateGeofence(PDV pdv, Position? position) {
    if (position == null) {
      return GeofenceValidationResult(
        isValid: false,
        distance: double.infinity,
        message: 'Position GPS non disponible',
        accuracy: 0,
      );
    }

    if (position.accuracy > AppConstants.minGpsAccuracy) {
      return GeofenceValidationResult(
        isValid: false,
        distance: calculateDistance(
          position.latitude,
          position.longitude,
          pdv.latitude,
          pdv.longitude,
        ),
        message: 'Précision GPS insuffisante (${position.accuracy.toStringAsFixed(1)}m)',
        accuracy: position.accuracy,
      );
    }

    final distance = calculateDistance(
      position.latitude,
      position.longitude,
      pdv.latitude,
      pdv.longitude,
    );

    final isWithin = distance <= pdv.rayonGeofence;

    return GeofenceValidationResult(
      isValid: isWithin,
      distance: distance,
      message: isWithin 
        ? 'Position validée' 
        : 'Trop éloigné du PDV (${distance.toStringAsFixed(0)}m)',
      accuracy: position.accuracy,
    );
  }

  void startMonitoringPDV(PDV pdv) {
    _positionSubscription?.cancel();
    
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _currentPosition = position;
      
      final distance = calculateDistance(
        position.latitude,
        position.longitude,
        pdv.latitude,
        pdv.longitude,
      );

      final isWithin = distance <= pdv.rayonGeofence;
      
      _geofenceStatusController.add(isWithin);
      _distanceController.add(distance);
    });
  }

  void stopMonitoring() {
    _positionSubscription?.cancel();
  }

  void dispose() {
    _positionSubscription?.cancel();
    _geofenceStatusController.close();
    _distanceController.close();
  }
}

class GeofenceValidationResult {
  final bool isValid;
  final double distance;
  final String message;
  final double accuracy;

  GeofenceValidationResult({
    required this.isValid,
    required this.distance,
    required this.message,
    required this.accuracy,
  });
}