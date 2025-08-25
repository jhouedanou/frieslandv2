import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/pdv_model.dart';
import '../../../core/services/sync_service.dart';
import 'geofence_validation_page.dart';

// Écran 2: Sélection PDV selon CLAUDE.md
// Permet de choisir le point de vente à visiter
class PDVSelectionPage extends StatefulWidget {
  final PDVModel? preSelectedPDV;
  
  const PDVSelectionPage({super.key, this.preSelectedPDV});

  @override
  State<PDVSelectionPage> createState() => _PDVSelectionPageState();
}

class _PDVSelectionPageState extends State<PDVSelectionPage> {
  final SyncService _syncService = SyncService();
  final TextEditingController _searchController = TextEditingController();
  
  List<PDVModel> _pdvs = [];
  List<PDVModel> _filteredPdvs = [];
  bool _isLoading = true;
  Position? _currentPosition;
  String? _selectedSortOption = 'distance';

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _loadPDVs();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Le service de localisation est désactivé';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Permissions de localisation refusées';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Permissions de localisation refusées définitivement';
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _sortPDVs();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur localisation: $e')),
        );
      }
    }
  }

  Future<void> _loadPDVs() async {
    try {
      final pdvs = await _syncService.getPDVsOffline();
      setState(() {
        _pdvs = pdvs;
        _filteredPdvs = pdvs;
        _isLoading = false;
      });
      _sortPDVs();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement PDV: $e')),
        );
      }
    }
  }

  void _filterPDVs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPdvs = _pdvs;
      } else {
        _filteredPdvs = _pdvs.where((pdv) {
          return pdv.nomPdv.toLowerCase().contains(query.toLowerCase()) ||
                 pdv.canal.toLowerCase().contains(query.toLowerCase()) ||
                 pdv.zone.toLowerCase().contains(query.toLowerCase()) ||
                 pdv.secteur.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
      _sortPDVs();
    });
  }

  void _sortPDVs() {
    if (_currentPosition == null) return;

    setState(() {
      switch (_selectedSortOption) {
        case 'distance':
          _filteredPdvs.sort((a, b) {
            final distanceA = Geolocator.distanceBetween(
              _currentPosition!.latitude, 
              _currentPosition!.longitude,
              a.latitude, 
              a.longitude,
            );
            final distanceB = Geolocator.distanceBetween(
              _currentPosition!.latitude, 
              _currentPosition!.longitude,
              b.latitude, 
              b.longitude,
            );
            return distanceA.compareTo(distanceB);
          });
          break;
        case 'name':
          _filteredPdvs.sort((a, b) => a.nomPdv.compareTo(b.nomPdv));
          break;
        case 'zone':
          _filteredPdvs.sort((a, b) => a.zone.compareTo(b.zone));
          break;
      }
    });
  }

  double _calculateDistance(PDVModel pdv) {
    if (_currentPosition == null) return 0;
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      pdv.latitude,
      pdv.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélection PDV'),
        backgroundColor: const Color(0xFFE53E3E),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            initialValue: _selectedSortOption,
            onSelected: (value) {
              setState(() {
                _selectedSortOption = value;
              });
              _sortPDVs();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'distance',
                child: Text('Par distance'),
              ),
              const PopupMenuItem(
                value: 'name',
                child: Text('Par nom'),
              ),
              const PopupMenuItem(
                value: 'zone',
                child: Text('Par zone'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un PDV...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: _filterPDVs,
            ),
          ),
          
          // Statistiques
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '${_filteredPdvs.length} PDV trouvés',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (_currentPosition != null)
                  Text(
                    'Position: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Liste des PDV
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPdvs.isEmpty
                    ? _buildEmptyState()
                    : _buildPDVList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun PDV trouvé',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier votre recherche',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPDVList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredPdvs.length,
      itemBuilder: (context, index) {
        final pdv = _filteredPdvs[index];
        final distance = _calculateDistance(pdv);
        final isInGeofence = distance <= (pdv.rayonGeofence ?? 300.0);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isInGeofence ? Colors.green : Colors.orange,
              child: Text(
                pdv.canal.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              pdv.nomPdv,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${pdv.canal} • ${pdv.zone} • ${pdv.secteur}'),
                Text(
                  pdv.adressage,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: isInGeofence ? Colors.green : Colors.orange,
                    ),
                    Text(
                      '${distance.round()}m • ${isInGeofence ? "Dans la zone" : "Hors zone"}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isInGeofence ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Icon(
              isInGeofence 
                  ? Icons.check_circle 
                  : Icons.warning,
              color: isInGeofence ? Colors.green : Colors.orange,
            ),
            onTap: () => _selectPDV(pdv),
          ),
        );
      },
    );
  }

  // Navigation vers validation géofencing selon CLAUDE.md
  void _selectPDV(PDVModel pdv) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeofenceValidationPage(
          selectedPdv: pdv,
          currentPosition: _currentPosition,
        ),
      ),
    );
  }
}