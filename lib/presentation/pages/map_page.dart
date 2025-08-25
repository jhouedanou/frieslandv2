import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/models/pdv_model.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/services/map_service.dart';
import 'visit_creation/geofence_validation_page.dart';

// Page de carte interactive avec OpenStreetMap pour Treichville
class MapPage extends StatefulWidget {
  final bool showAppBar;
  
  const MapPage({super.key, this.showAppBar = true});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final SyncService _syncService = SyncService();
  
  List<PDVModel> _pdvs = [];
  Position? _currentPosition;
  bool _isLoading = true;
  bool _showGeofencing = true;
  String _filterSecteur = 'Tous';
  PDVModel? _selectedPDV;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    setState(() => _isLoading = true);
    
    try {
      // Charger les PDV
      final pdvs = await _syncService.getPDVsOffline();
      
      // Afficher tous les PDVs fictifs créés (zone ABIDJAN SUD - secteur TREICHVILLE)
      final availablePDVs = pdvs.where((pdv) => 
        pdv.secteur.toLowerCase().contains('treichville') || 
        pdv.zone.toLowerCase().contains('abidjan')).toList();
      
      // Obtenir la position actuelle
      try {
        _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        debugPrint('Erreur localisation: $e');
      }

      setState(() {
        _pdvs = availablePDVs;
        _isLoading = false;
      });
      
      print('✅ Carte: ${availablePDVs.length} PDVs chargés');
      for (var pdv in availablePDVs) {
        print('📍 ${pdv.nomPdv} - ${pdv.latitude}, ${pdv.longitude}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement carte: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: const Text('Carte Treichville - Roger Abinader'),
        backgroundColor: const Color(0xFFE53E3E),
        foregroundColor: Colors.white,
        actions: [
          // Toggle géofencing
          IconButton(
            icon: Icon(_showGeofencing ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() => _showGeofencing = !_showGeofencing);
            },
            tooltip: 'Géofencing',
          ),
          // Localisation
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnCurrentLocation,
            tooltip: 'Ma position',
          ),
        ],
      ) : null,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Barre de filtre et informations
                _buildInfoBar(),
                
                // Carte principale
                Expanded(
                  child: Stack(
                    children: [
                      // Carte OpenStreetMap
                      MapService.createTreichvilleMap(
                        pdvs: _getFilteredPDVs(),
                        currentPosition: _currentPosition != null 
                            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                            : null,
                        onPDVTap: _onPDVTap,
                        showGeofencing: _showGeofencing,
                      ),
                      
                      // Panneau d'informations PDV sélectionné
                      if (_selectedPDV != null)
                        _buildPDVInfoPanel(),
                    ],
                  ),
                ),
                
                // Barre d'actions
                _buildActionBar(),
              ],
            ),
    );
  }

  Widget _buildInfoBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100],
      child: Row(
        children: [
          Icon(Icons.store, color: const Color(0xFFE53E3E)),
          const SizedBox(width: 8),
          Text(
            '${_getFilteredPDVs().length} PDV',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          Icon(Icons.location_on, color: Colors.blue, size: 16),
          const SizedBox(width: 4),
          Text(
            _currentPosition != null ? 'Localisé' : 'Position inconnue',
            style: TextStyle(
              fontSize: 12,
              color: _currentPosition != null ? Colors.blue : Colors.grey,
            ),
          ),
          const Spacer(),
          DropdownButton<String>(
            value: _filterSecteur,
            items: _getSecteurs().map((secteur) {
              return DropdownMenuItem(
                value: secteur,
                child: Text(secteur),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _filterSecteur = value ?? 'Tous');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPDVInfoPanel() {
    return Positioned(
      bottom: 80,
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.store,
                    color: const Color(0xFFE53E3E),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedPDV!.nomPdv,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selectedPDV = null),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('${_selectedPDV!.canal} • ${_selectedPDV!.secteur}'),
              Text(
                _selectedPDV!.adressage,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildDistanceInfo(),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _canStartVisit() ? _startVisit : null,
                    icon: Icon(_canStartVisit() ? Icons.check_circle : Icons.location_off),
                    label: Text(_canStartVisit() ? 'Commencer visite' : 'Hors zone'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canStartVisit() 
                          ? const Color(0xFFE53E3E) 
                          : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceInfo() {
    if (_currentPosition == null || _selectedPDV == null) {
      return const Text('Distance: --');
    }

    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _selectedPDV!.latitude,
      _selectedPDV!.longitude,
    );

    final isInGeofence = distance <= (_selectedPDV!.rayonGeofence ?? 100.0);

    return Row(
      children: [
        Icon(
          isInGeofence ? Icons.check_circle : Icons.warning,
          color: isInGeofence ? Colors.green : Colors.orange,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '${distance.round()}m',
          style: TextStyle(
            color: isInGeofence ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _showRouteOptimization,
              icon: const Icon(Icons.route),
              label: const Text('Optimiser tournée'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _loadMapData,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PDVModel> _getFilteredPDVs() {
    if (_filterSecteur == 'Tous') return _pdvs;
    return _pdvs.where((pdv) => pdv.secteur == _filterSecteur).toList();
  }

  List<String> _getSecteurs() {
    final secteurs = _pdvs.map((pdv) => pdv.secteur).toSet().toList();
    secteurs.sort();
    return ['Tous', ...secteurs];
  }

  void _onPDVTap(PDVModel pdv) {
    setState(() => _selectedPDV = pdv);
  }

  bool _canStartVisit() {
    if (_currentPosition == null || _selectedPDV == null) return false;
    return MapService.isWithinGeofence(_currentPosition!, _selectedPDV!);
  }

  void _startVisit() {
    if (_selectedPDV == null || _currentPosition == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeofenceValidationPage(
          selectedPdv: _selectedPDV!,
          currentPosition: _currentPosition,
        ),
      ),
    );
  }

  void _centerOnCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() => _currentPosition = position);
      
      // La carte se centre automatiquement sur la nouvelle position
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur localisation: $e')),
        );
      }
    }
  }

  void _showRouteOptimization() {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Position actuelle requise pour optimiser la tournée')),
      );
      return;
    }

    final currentLatLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    final optimizedRoute = MapService.calculateOptimizedRoute(_getFilteredPDVs(), currentLatLng);
    final distance = MapService.calculateRouteDistance(optimizedRoute);
    final duration = MapService.estimateRouteTime(optimizedRoute);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tournée Optimisée'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PDV à visiter: ${_getFilteredPDVs().length}'),
            Text('Distance totale: ${(distance / 1000).toStringAsFixed(1)} km'),
            Text('Temps estimé: ${duration.inMinutes} minutes'),
            const SizedBox(height: 16),
            const Text(
              'Route optimisée selon algorithme du plus proche voisin',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Démarrer navigation guidée
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigation guidée à implémenter')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
            ),
            child: const Text('Démarrer'),
          ),
        ],
      ),
    );
  }
}
