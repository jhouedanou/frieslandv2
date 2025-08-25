import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/pdv_model.dart';
import '../../data/models/visite_model.dart';
import 'pdv_creation_page.dart';
import 'visit_creation/visit_form_page.dart';

class CreateVisitPage extends StatefulWidget {
  const CreateVisitPage({super.key});

  @override
  State<CreateVisitPage> createState() => _CreateVisitPageState();
}

class _CreateVisitPageState extends State<CreateVisitPage> {
  final SyncService _syncService = SyncService();
  final AuthService _authService = AuthService();
  
  List<PDVModel> _pdvs = [];
  List<PDVModel> _filteredPDVs = [];
  bool _isLoading = true;
  String _searchQuery = '';
  Position? _currentPosition;
  
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
        _filteredPDVs = pdvs;
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

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Erreur localisation: $e');
    }
  }

  void _filterPDVs(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPDVs = _pdvs;
      } else {
        _filteredPDVs = _pdvs.where((pdv) =>
          pdv.nomPdv.toLowerCase().contains(query.toLowerCase()) ||
          pdv.adressage.toLowerCase().contains(query.toLowerCase())
        ).toList();
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

  Future<void> _createNewPDV() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PDVCreationPage()),
    );
    
    if (result != null && result is PDVModel) {
      await _loadPDVs(); // Rafraîchir la liste
      // Sélectionner automatiquement le nouveau PDV pour la visite
      _startVisitWithPDV(result);
    }
  }

  void _startVisitWithPDV(PDVModel pdv) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VisitFormPage(selectedPDV: pdv),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle visite'),
        backgroundColor: const Color(0xFFE53E3E),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: _createNewPDV,
            icon: const Icon(Icons.add_business),
            tooltip: 'Créer un nouveau PDV',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
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
                TextField(
                  onChanged: _filterPDVs,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un PDV pour la visite...',
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
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade600, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sélectionnez un PDV existant ou créez-en un nouveau',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Liste des PDVs
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _buildPDVList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewPDV,
        backgroundColor: const Color(0xFFE53E3E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_business),
        label: const Text('Nouveau PDV'),
      ),
    );
  }

  Widget _buildPDVList() {
    if (_filteredPDVs.isEmpty) {
      return _buildEmptyState();
    }
    
    // Trier par distance si position disponible
    final sortedPDVs = List<PDVModel>.from(_filteredPDVs);
    if (_currentPosition != null) {
      sortedPDVs.sort((a, b) => _calculateDistance(a).compareTo(_calculateDistance(b)));
    }
    
    return ListView.builder(
      itemCount: sortedPDVs.length,
      itemBuilder: (context, index) {
        final pdv = sortedPDVs[index];
        return _buildPDVCard(pdv);
      },
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
            _searchQuery.isNotEmpty
                ? 'Aucun PDV trouvé\npour "${_searchQuery}"'
                : 'Aucun PDV disponible',
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
            label: const Text('Créer un nouveau PDV'),
          ),
        ],
      ),
    );
  }

  Widget _buildPDVCard(PDVModel pdv) {
    final distance = _calculateDistance(pdv);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _startVisitWithPDV(pdv),
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
              
              // Zone, secteur et distance
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
                  if (_currentPosition != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: distance < 1000 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        distance < 1000 
                            ? '${distance.round()}m'
                            : '${(distance / 1000).toStringAsFixed(1)}km',
                        style: TextStyle(
                          fontSize: 10,
                          color: distance < 1000 ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Bouton de sélection
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _startVisitWithPDV(pdv),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53E3E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.assignment, size: 18),
                  label: const Text('Commencer la visite'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
