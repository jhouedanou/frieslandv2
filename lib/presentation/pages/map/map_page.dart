import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/geofencing_service.dart';
import '../../../domain/entities/pdv.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final GeofencingService _geofencingService = GeofencingService();
  
  Position? _currentPosition;
  List<PDV> _pdvList = [];
  PDV? _selectedPDV;
  String _selectedFilter = 'Tous';
  bool _showGeofences = true;
  bool _isLoading = true;

  // Mock data - Replace with actual data from repository
  final List<PDV> _mockPDVs = [
    PDV(
      pdvId: '1',
      nomPdv: 'Boutique Central',
      canal: 'General trade',
      categoriePdv: 'Point de vente détail',
      sousCategoriePdv: 'Boutique',
      region: 'Abidjan',
      territoire: 'Abidjan Centre',
      zone: 'Zone 1',
      secteur: 'Secteur A',
      latitude: 5.3600,
      longitude: -4.0083,
      adressage: 'Plateau, Abidjan',
      dateCreation: DateTime.now(),
      ajoutePar: 'Admin',
      mdm: 'MDM001',
    ),
    PDV(
      pdvId: '2',
      nomPdv: 'Superette Nord',
      canal: 'General trade',
      categoriePdv: 'Point de vente détail',
      sousCategoriePdv: 'Superette',
      region: 'Yamoussoukro',
      territoire: 'Yamoussoukro Nord',
      zone: 'Zone 2',
      secteur: 'Secteur B',
      latitude: 6.8276,
      longitude: -5.2893,
      adressage: 'Quartier Administratif, Yamoussoukro',
      dateCreation: DateTime.now(),
      ajoutePar: 'Admin',
      mdm: 'MDM002',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      await _geofencingService.initialize();
      _currentPosition = _geofencingService.currentPosition;
      _pdvList = _mockPDVs; // Replace with actual data loading
      
      if (_currentPosition != null) {
        _mapController.move(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          10,
        );
      } else if (_pdvList.isNotEmpty) {
        _mapController.move(
          LatLng(_pdvList.first.latitude, _pdvList.first.longitude),
          10,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des PDV'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Tous', child: Text('Tous les PDV')),
              const PopupMenuItem(value: 'Boutique', child: Text('Boutiques')),
              const PopupMenuItem(value: 'Superette', child: Text('Superettes')),
              const PopupMenuItem(value: 'Kiosque', child: Text('Kiosques')),
            ],
          ),
          IconButton(
            icon: Icon(
              _showGeofences ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _showGeofences = !_showGeofences;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition != null
                        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                        : const LatLng(5.3600, -4.0083), // Default to Abidjan
                    initialZoom: 10,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedPDV = null;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.friesland.dashboard',
                      maxZoom: 19,
                      tileProvider: NetworkTileProvider(),
                    ),
                    
                    // Geofence circles
                    if (_showGeofences)
                      CircleLayer(
                        circles: _getFilteredPDVs().map((pdv) {
                          return CircleMarker(
                            point: LatLng(pdv.latitude, pdv.longitude),
                            radius: pdv.rayonGeofence,
                            useRadiusInMeter: true,
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            borderColor: AppTheme.primaryColor,
                            borderStrokeWidth: 2,
                          );
                        }).toList(),
                      ),
                    
                    // PDV markers
                    MarkerLayer(
                      markers: [
                        // Current position marker
                        if (_currentPosition != null)
                          Marker(
                            point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                            ),
                          ),
                        
                        // PDV markers
                        ..._getFilteredPDVs().map((pdv) {
                          return Marker(
                            point: LatLng(pdv.latitude, pdv.longitude),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPDV = pdv;
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getPDVColor(pdv),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selectedPDV?.pdvId == pdv.pdvId 
                                        ? Colors.yellow 
                                        : Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _getPDVIcon(pdv),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
                
                // PDV details bottom sheet
                if (_selectedPDV != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildPDVDetailsSheet(_selectedPDV!),
                  ),
                
                // Map controls
                Positioned(
                  top: 16,
                  left: 16,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: "zoom_in",
                        onPressed: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom + 1,
                          );
                        },
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: "zoom_out",
                        onPressed: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom - 1,
                          );
                        },
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
                
                // Center on location button
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton.small(
                    heroTag: "center_location",
                    onPressed: _centerOnCurrentLocation,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
    );
  }

  List<PDV> _getFilteredPDVs() {
    if (_selectedFilter == 'Tous') {
      return _pdvList;
    }
    return _pdvList.where((pdv) => pdv.sousCategoriePdv == _selectedFilter).toList();
  }

  Color _getPDVColor(PDV pdv) {
    switch (pdv.sousCategoriePdv) {
      case AppConstants.boutique:
        return AppTheme.primaryColor;
      case AppConstants.superette:
        return AppTheme.successColor;
      case AppConstants.kiosque:
        return AppTheme.warningColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getPDVIcon(PDV pdv) {
    switch (pdv.sousCategoriePdv) {
      case AppConstants.boutique:
        return Icons.store;
      case AppConstants.superette:
        return Icons.business;
      case AppConstants.kiosque:
        return Icons.local_convenience_store;
      default:
        return Icons.location_on;
    }
  }

  Widget _buildPDVDetailsSheet(PDV pdv) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getPDVColor(pdv),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getPDVIcon(pdv),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pdv.nomPdv,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        pdv.sousCategoriePdv,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedPDV = null;
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pdv.adressage,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.business, color: Colors.grey[600], size: 16),
                const SizedBox(width: 8),
                Text(
                  '${pdv.zone} • ${pdv.secteur}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showDirections(pdv);
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Itinéraire'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/visit-form',
                        arguments: pdv,
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Nouvelle visite'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _centerOnCurrentLocation() async {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15,
      );
    } else {
      try {
        final position = _geofencingService.currentPosition;
        if (position != null) {
          _mapController.move(
            LatLng(position.latitude, position.longitude),
            15,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'obtenir la position: $e')),
        );
      }
    }
  }

  void _showDirections(PDV pdv) {
    // Implement directions functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité d\'itinéraire à implémenter')),
    );
  }

  @override
  void dispose() {
    _geofencingService.dispose();
    super.dispose();
  }
}