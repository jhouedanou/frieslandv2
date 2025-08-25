import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/pdv_model.dart';
import 'pdv_creation_page.dart';
import 'visit_creation/visit_form_page.dart';

class PDVListPage extends StatefulWidget {
  const PDVListPage({super.key});

  @override
  State<PDVListPage> createState() => _PDVListPageState();
}

class _PDVListPageState extends State<PDVListPage> {
  final SyncService _syncService = SyncService();
  final AuthService _authService = AuthService();
  
  List<PDVModel> _pdvs = [];
  bool _isLoading = true;
  String _filterType = 'Tous';
  String _searchQuery = '';
  Position? _currentPosition;
  
  final List<String> _filterTypes = [
    'Tous',
    'Superette',
    'Boutique',
    'Épicerie',
    'Mini-Market',
    'Supermarché',
  ];

  @override
  void initState() {
    super.initState();
    _loadPDVs();
    _getCurrentLocation();
  }

  Future<void> _loadPDVs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pdvs = await _syncService.getPDVsOffline();
      setState(() {
        _pdvs = pdvs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement PDVs: $e')),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Erreur localisation: $e');
    }
  }

  List<PDVModel> get _filteredPDVs {
    var filtered = _pdvs;
    
    // Filtre par type
    if (_filterType != 'Tous') {
      filtered = filtered.where((pdv) => pdv.categoriePdv == _filterType).toList();
    }
    
    // Filtre par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((pdv) => 
        pdv.nomPdv.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        pdv.adressage.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  Future<void> _createNewPDV() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PDVCreationPage()),
    );
    
    if (result != null && result is PDVModel) {
      // Rafraîchir la liste
      await _loadPDVs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDV "${result.nomPdv}" créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header avec recherche et filtre
          _buildSearchAndFilter(),
          
          // Liste des PDVs
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _buildPDVList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewPDV,
        backgroundColor: const Color(0xFFE53E3E),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_business),
        tooltip: 'Créer un nouveau PDV',
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Rechercher un PDV...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE53E3E)),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Filtres
          Row(
            children: [
              const Icon(Icons.filter_list, color: Color(0xFFE53E3E)),
              const SizedBox(width: 8),
              const Text(
                'Type:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterTypes.map((type) {
                      final isSelected = _filterType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _filterType = type;
                            });
                          },
                          selectedColor: const Color(0xFFE53E3E).withOpacity(0.2),
                          checkmarkColor: const Color(0xFFE53E3E),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPDVList() {
    final filteredPDVs = _filteredPDVs;
    
    if (filteredPDVs.isEmpty) {
      return _buildEmptyState();
    }
    
    return RefreshIndicator(
      onRefresh: _loadPDVs,
      child: ListView.builder(
        itemCount: filteredPDVs.length,
        itemBuilder: (context, index) {
          final pdv = filteredPDVs[index];
          return _buildPDVCard(pdv);
        },
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
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _filterType != 'Tous'
                ? 'Aucun PDV trouvé\navec ces critères'
                : 'Aucun PDV créé',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewPDV,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add_business),
            label: const Text('Créer mon premier PDV'),
          ),
        ],
      ),
    );
  }

  Widget _buildPDVCard(PDVModel pdv) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showPDVDetails(pdv),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec nom et type
              Row(
                children: [
                  Expanded(
                    child: Text(
                      pdv.nomPdv,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53E3E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pdv.categoriePdv,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE53E3E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Adresse
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      pdv.adressage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Zone et secteur
              Row(
                children: [
                  Icon(Icons.map, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${pdv.zone} - ${pdv.secteur}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  // Distance réelle
                  _buildDistanceIndicator(pdv),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _planVisit(pdv),
                      icon: const Icon(Icons.schedule, size: 16),
                      label: const Text('Planifier visite'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE53E3E),
                        side: const BorderSide(color: Color(0xFFE53E3E)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _canStartVisit(pdv) ? () => _startVisit(pdv) : null,
                      icon: Icon(
                        _canStartVisit(pdv) ? Icons.play_arrow : Icons.location_off, 
                        size: 16
                      ),
                      label: Text(_canStartVisit(pdv) ? 'Commencer' : 'Hors zone'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canStartVisit(pdv) 
                            ? const Color(0xFFE53E3E) 
                            : Colors.grey,
                        foregroundColor: Colors.white,
                      ),
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

  void _showPDVDetails(PDVModel pdv) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Titre
                  Text(
                    pdv.nomPdv,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Détails
                  _buildDetailRow('Type', pdv.categoriePdv),
                  _buildDetailRow('Canal', pdv.canal),
                  _buildDetailRow('Adresse', pdv.adressage),
                  _buildDetailRow('Zone', pdv.zone),
                  _buildDetailRow('Secteur', pdv.secteur),
                  _buildDetailRow('Coordonnées', '${pdv.latitude}, ${pdv.longitude}'),
                  _buildDetailRow('Géofencing', '${pdv.rayonGeofence.round()}m'),
                  _buildDetailRow('Créé le', '${pdv.dateCreation.day}/${pdv.dateCreation.month}/${pdv.dateCreation.year}'),
                  
                  const SizedBox(height: 24),
                  
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _planVisit(pdv);
                          },
                          child: const Text('Planifier visite'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _canStartVisit(pdv) ? () {
                            Navigator.pop(context);
                            _startVisit(pdv);
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _canStartVisit(pdv) 
                                ? const Color(0xFFE53E3E) 
                                : Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(_canStartVisit(pdv) 
                              ? 'Commencer visite' 
                              : 'Hors zone (${_calculateDistance(pdv).round()}m)'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _planVisit(PDVModel pdv) {
    // TODO: Implémenter la planification de visite
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Planification visite pour ${pdv.nomPdv}')),
    );
  }

  bool _canStartVisit(PDVModel pdv) {
    if (_currentPosition == null) return false;
    
    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      pdv.latitude,
      pdv.longitude,
    );
    
    return distance <= (pdv.rayonGeofence ?? 100.0);
  }

  double _calculateDistance(PDVModel pdv) {
    if (_currentPosition == null) return double.infinity;
    
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      pdv.latitude,
      pdv.longitude,
    );
  }

  Widget _buildDistanceIndicator(PDVModel pdv) {
    if (_currentPosition == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'Position?',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final distance = _calculateDistance(pdv);
    final isInGeofence = distance <= (pdv.rayonGeofence ?? 100.0);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isInGeofence 
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isInGeofence ? Icons.check_circle : Icons.warning,
            size: 12,
            color: isInGeofence ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 2),
          Text(
            distance < 1000 
                ? '${distance.round()}m'
                : '${(distance / 1000).toStringAsFixed(1)}km',
            style: TextStyle(
              fontSize: 10,
              color: isInGeofence ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _startVisit(PDVModel pdv) {
    if (!_canStartVisit(pdv)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vous devez être dans un rayon de ${pdv.rayonGeofence?.round() ?? 100}m du PDV pour commencer la visite',
          ),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      return;
    }

    // Lancer la visite directement
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisitFormPage(selectedPDV: pdv),
      ),
    );
  }
}
