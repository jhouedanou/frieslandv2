import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../../data/models/pdv_model.dart';
import 'visit_form_page.dart';

// Écran 3: Validation géofencing selon CLAUDE.md 
// Contrôle obligatoire 300m du PDV avant accès au formulaire
class GeofenceValidationPage extends StatefulWidget {
  final PDVModel selectedPdv;
  final Position? currentPosition;

  const GeofenceValidationPage({
    super.key,
    required this.selectedPdv,
    this.currentPosition,
  });

  @override
  State<GeofenceValidationPage> createState() => _GeofenceValidationPageState();
}

class _GeofenceValidationPageState extends State<GeofenceValidationPage> {
  Position? _currentPosition;
  double _currentDistance = 0.0;
  bool _isValidating = false;
  bool _isInGeofence = false;
  Timer? _locationTimer;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.currentPosition;
    _startLocationValidation();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  void _startLocationValidation() {
    setState(() {
      _isValidating = true;
    });

    // Stream de position temps réel pour validation géofencing selon CLAUDE.md
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // Mise à jour chaque mètre
      ),
    ).listen((Position position) {
      _updatePosition(position);
    });

    // Validation périodique toutes les 2 secondes
    _locationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentPosition != null) {
        _validateGeofence();
      }
    });
  }

  void _updatePosition(Position position) {
    setState(() {
      _currentPosition = position;
      _currentDistance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.selectedPdv.latitude,
        widget.selectedPdv.longitude,
      );
    });
  }

  void _validateGeofence() {
    final maxDistance = widget.selectedPdv.rayonGeofence ?? 300.0;
    final isInside = _currentDistance <= maxDistance;
    
    setState(() {
      _isInGeofence = isInside;
      _isValidating = false;
    });

    // Auto-navigation si dans la zone depuis plus de 3 secondes
    if (isInside && !_isValidating) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isInGeofence) {
          _proceedToForm();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxDistance = widget.selectedPdv.rayonGeofence ?? 300.0;
    final progressValue = _currentDistance > maxDistance 
        ? 0.0 
        : (maxDistance - _currentDistance) / maxDistance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation Géofencing'),
        backgroundColor: const Color(0xFFE53E3E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Informations PDV
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PDV Sélectionné',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.selectedPdv.nomPdv,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${widget.selectedPdv.canal} • ${widget.selectedPdv.zone}'),
                    Text(
                      widget.selectedPdv.adressage,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Indicateur géofencing visuel selon CLAUDE.md
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cercle de validation visuelle
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Cercle extérieur (zone maximale)
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.red.withOpacity(0.5),
                            width: 3,
                          ),
                        ),
                      ),
                      // Cercle intérieur (zone validée)
                      Container(
                        width: 200 * progressValue,
                        height: 200 * progressValue,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isInGeofence 
                              ? Colors.green.withOpacity(0.3)
                              : Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      // Point central (PDV)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE53E3E),
                        ),
                      ),
                      // Position actuelle
                      Positioned(
                        left: 100 + (progressValue * 90) * 
                            (_currentDistance > 0 ? 1 : 0),
                        top: 100,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isInGeofence ? Colors.green : Colors.orange,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Informations de distance
                  Card(
                    color: _isInGeofence 
                        ? Colors.green[50] 
                        : Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isInGeofence 
                                    ? Icons.check_circle 
                                    : Icons.location_on,
                                color: _isInGeofence 
                                    ? Colors.green 
                                    : Colors.orange,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Distance: ${_currentDistance.round()}m',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _isInGeofence 
                                      ? Colors.green[700] 
                                      : Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isInGeofence
                                ? '✅ Vous êtes dans la zone autorisée'
                                : '⚠️ Rapprochez-vous du PDV (max ${maxDistance.round()}m)',
                            style: TextStyle(
                              color: _isInGeofence 
                                  ? Colors.green[700] 
                                  : Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_currentPosition != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Précision GPS: ${_currentPosition!.accuracy.round()}m',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Instructions selon CLAUDE.md
                  if (!_isInGeofence) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Validation géofencing requise',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Vous devez être à moins de ${maxDistance.round()}m du PDV pour commencer la visite.',
                            style: TextStyle(
                              color: Colors.blue[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Bouton de validation
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isInGeofence ? _proceedToForm : null,
                icon: Icon(_isInGeofence ? Icons.check : Icons.location_on),
                label: Text(
                  _isInGeofence 
                      ? 'Commencer la visite' 
                      : 'En attente de validation...',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isInGeofence 
                      ? const Color(0xFFE53E3E) 
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation vers formulaire multi-onglets selon CLAUDE.md
  void _proceedToForm() {
    if (!_isInGeofence) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être dans la zone géofencée pour continuer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VisitFormPage(
          selectedPdv: widget.selectedPdv,
          validatedPosition: _currentPosition!,
        ),
      ),
    );
  }
}