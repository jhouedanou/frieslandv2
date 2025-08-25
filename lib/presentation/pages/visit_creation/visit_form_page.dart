import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/pdv_model.dart';
import '../../../data/models/visite_data_models.dart';
import '../../../data/models/visite_model.dart';
import '../../../core/services/sync_service.dart';
import 'package:uuid/uuid.dart';

// Écran 4: Formulaire multi-onglets selon CLAUDE.md
// 4 sections: Général, Concurrence, Visibilité, Actions
class VisitFormPage extends StatefulWidget {
  final PDVModel selectedPdv;
  final Position validatedPosition;

  const VisitFormPage({
    super.key,
    required this.selectedPdv,
    required this.validatedPosition,
  });

  @override
  State<VisitFormPage> createState() => _VisitFormPageState();
}

class _VisitFormPageState extends State<VisitFormPage> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  final SyncService _syncService = SyncService();
  
  int _currentTabIndex = 0;
  bool _isSaving = false;
  
  // Données du formulaire selon structure CLAUDE.md
  final Map<String, dynamic> _formData = {
    'produits': {
      'evap': {
        'present': false,
        'br_gold': 'En rupture',
        'br_150g': 'En rupture',
        'brb_150g': 'En rupture',
        'br_380g': 'En rupture',
        'brb_380g': 'En rupture',
        'pearl_380g': 'En rupture',
      },
      'imp': {
        'present': false, 
        'prix_respectes': false,
        'br_2': 'En rupture',
        'br_16g': 'En rupture',
        'brb_16g': 'En rupture',
        'br_360g': 'En rupture',
        'br_400g_tin': 'En rupture',
        'brb_360g': 'En rupture',
        'br_900g_tin': 'En rupture',
      },
      'scm': {'present': false, 'prix_respectes': false},
      'uht': {'present': false, 'prix_respectes': false},
      'yaourt': {'present': false},
    },
    'concurrence': {
      'presence_concurrents': false,
      'evap': {
        'present': false,
        'cowmilk': 'En rupture',
        'nido_150g': 'En rupture',
        'autre': 'En rupture',
      },
      'imp': {
        'present': false,
        'nido': 'En rupture',
        'laity': 'En rupture',
        'autre': 'En rupture',
      },
      'scm': {
        'present': false,
        'top_saho': 'En rupture',
        'autre': 'En rupture',
        'nom_concurrent': '',
      },
      'uht': false,
    },
    'visibilite': {
      'interieure': {'presence_visibilite': false},
      'concurrence': {
        'presence_visibilite': false,
        'nido_exterieur': false,
        'nido_interieur': false,
        'laity_exterieur': false,
        'laity_interieur': false,
        'candia_exterieur': false,
        'candia_interieur': false,
      },
    },
    'actions': {
      'referencement_produits': false,
      'execution_activites_promotionnelles': false,
      'prospection_pdv': false,
      'verification_fifo': false,
      'rangement_produits': false,
      'pose_affiches': false,
      'pose_materiel_visibilite': false,
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visite - ${widget.selectedPdv.nomPdv}'),
        backgroundColor: const Color(0xFFE53E3E),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Général', icon: Icon(Icons.inventory, size: 20)),
            Tab(text: 'Concurrence', icon: Icon(Icons.business, size: 20)),
            Tab(text: 'Visibilité', icon: Icon(Icons.visibility, size: 20)),
            Tab(text: 'Actions', icon: Icon(Icons.task_alt, size: 20)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Indicateur de progression
          LinearProgressIndicator(
            value: (_currentTabIndex + 1) / 4,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE53E3E)),
          ),
          
          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralTab(),
                _buildConcurrenceTab(),
                _buildVisibiliteTab(),
                _buildActionsTab(),
              ],
            ),
          ),
          
          // Barre de navigation
          _buildNavigationBar(),
        ],
      ),
    );
  }

  // Onglet 1 - Général (Disponibilité et Prix) selon CLAUDE.md
  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Produits Disponibles', Icons.inventory),
          
          // EVAP selon CLAUDE.md
          _buildProductSection(
            'EVAP',
            'evap',
            [
              'BR Gold',
              'BR 150g',
              'BRB 150g', 
              'BR 380g',
              'BRB 380g',
              'Pearl 380g',
            ],
            showPriceCheck: false,
          ),
          
          // IMP selon CLAUDE.md  
          _buildProductSection(
            'IMP',
            'imp',
            [
              'BR 2',
              'BR 16g',
              'BRB 16g',
              'BR 360g',
              'BR 400g Tin',
              'BRB 360g',
              'BR 900g Tin',
            ],
            showPriceCheck: true,
          ),
          
          // SCM selon CLAUDE.md
          _buildProductSection(
            'SCM',
            'scm',
            [],
            showPriceCheck: true,
            isGeneric: true,
          ),
          
          // UHT selon CLAUDE.md
          _buildProductSection(
            'UHT',
            'uht', 
            [],
            showPriceCheck: true,
            isGeneric: true,
          ),
          
          // YAOURT selon CLAUDE.md
          _buildProductSection(
            'YAOURT',
            'yaourt',
            [],
            showPriceCheck: false,
            isGeneric: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProductSection(
    String title,
    String key,
    List<String> products,
    {bool showPriceCheck = false, bool isGeneric = false}
  ) {
    final isPresent = _formData['produits'][key]['present'] == true;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '$title Présent',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: isPresent,
                  activeColor: const Color(0xFFE53E3E),
                  onChanged: (value) {
                    setState(() {
                      _formData['produits'][key]['present'] = value;
                    });
                  },
                ),
              ],
            ),
            
            if (isPresent) ...[
              const SizedBox(height: 16),
              const Divider(),
              
              if (products.isNotEmpty) ...[
                const Text(
                  'Détail produits:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                ...products.map((product) => 
                  _buildProductDetailItem(key, product)
                ),
              ] else if (isGeneric) ...[
                const Text(
                  'Produits présents (générique)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
              
              if (showPriceCheck) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Prix respectés?'),
                    const Spacer(),
                    Switch(
                      value: _formData['produits'][key]['prix_respectes'] == true,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          _formData['produits'][key]['prix_respectes'] = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetailItem(String category, String product) {
    // Normaliser le nom du produit pour la clé
    final productKey = product.toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e');
    
    final currentStatus = _formData['produits'][category][productKey] ?? 'En rupture';
    final isEnRupture = currentStatus == 'En rupture';
    final isPresent = currentStatus == 'Présent';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              product,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          ToggleButtons(
            constraints: const BoxConstraints(minWidth: 80, minHeight: 36),
            borderRadius: BorderRadius.circular(6),
            selectedColor: Colors.white,
            fillColor: Colors.red,
            isSelected: [isEnRupture, isPresent],
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('En rupture', style: TextStyle(fontSize: 11)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Présent', style: TextStyle(fontSize: 11)),
              ),
            ],
            onPressed: (index) {
              setState(() {
                _formData['produits'][category][productKey] = 
                    index == 0 ? 'En rupture' : 'Présent';
              });
            },
          ),
        ],
      ),
    );
  }

  // Onglet 2 - Concurrence selon CLAUDE.md
  Widget _buildConcurrenceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Analyse Concurrence', Icons.business),
          
          // Présence générale concurrents
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Présence de concurrents',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Switch(
                    value: _formData['concurrence']['presence_concurrents'],
                    activeColor: const Color(0xFFE53E3E),
                    onChanged: (value) {
                      setState(() {
                        _formData['concurrence']['presence_concurrents'] = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          if (_formData['concurrence']['presence_concurrents']) ...[
            const SizedBox(height: 16),
            
            // Concurrence EVAP selon CLAUDE.md
            _buildConcurrenceSection(
              'Concurrent EVAP',
              'evap', 
              ['Cowmilk', 'NIDO 150g', 'Autre'],
            ),
            
            // Concurrence IMP selon CLAUDE.md
            _buildConcurrenceSection(
              'Concurrent IMP',
              'imp',
              ['Nido', 'Laity', 'Autre'],
            ),
            
            // Concurrence SCM selon CLAUDE.md
            _buildConcurrenceSection(
              'Concurrent SCM',
              'scm',
              ['Top Saho', 'Autre'],
              showTextInput: true,
            ),
            
            // Concurrence UHT selon CLAUDE.md
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('Concurrent UHT'),
                    const Spacer(),
                    Switch(
                      value: _formData['concurrence']['uht'],
                      activeColor: const Color(0xFFE53E3E),
                      onChanged: (value) {
                        setState(() {
                          _formData['concurrence']['uht'] = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConcurrenceSection(
    String title,
    String key,
    List<String> competitors,
    {bool showTextInput = false}
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...competitors.map((competitor) => 
              _buildCompetitorItem(key, competitor)
            ),
            if (showTextInput) ...[
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nom concurrent (texte libre)',
                  border: OutlineInputBorder(),
                  hintText: 'Saisissez le nom du concurrent...',
                ),
                onChanged: (value) {
                  setState(() {
                    _formData['concurrence'][key]['nom_concurrent'] = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompetitorItem(String category, String competitor) {
    // Normaliser le nom du concurrent pour la clé
    final competitorKey = competitor.toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e');
    
    final currentStatus = _formData['concurrence'][category][competitorKey] ?? 'En rupture';
    final isEnRupture = currentStatus == 'En rupture';
    final isPresent = currentStatus == 'Présent';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              competitor,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          ToggleButtons(
            constraints: const BoxConstraints(minWidth: 80, minHeight: 36),
            borderRadius: BorderRadius.circular(6),
            selectedColor: Colors.white,
            fillColor: Colors.orange,
            isSelected: [isEnRupture, isPresent],
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('En rupture', style: TextStyle(fontSize: 11)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8), 
                child: Text('Présent', style: TextStyle(fontSize: 11)),
              ),
            ],
            onPressed: (index) {
              setState(() {
                _formData['concurrence'][category][competitorKey] = 
                    index == 0 ? 'En rupture' : 'Présent';
              });
            },
          ),
        ],
      ),
    );
  }

  // Onglet 3 - Visibilité selon CLAUDE.md  
  Widget _buildVisibiliteTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Analyse Visibilité', Icons.visibility),
          
          // Visibilité intérieure selon CLAUDE.md
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visibilité intérieure',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Présence de visibilité intérieure'),
                      const Spacer(),
                      Switch(
                        value: _formData['visibilite']['interieure']['presence_visibilite'],
                        activeColor: const Color(0xFFE53E3E),
                        onChanged: (value) {
                          setState(() {
                            _formData['visibilite']['interieure']['presence_visibilite'] = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Visibilité concurrence selon CLAUDE.md
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visibilité concurrence',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      const Text('Présence générale'),
                      const Spacer(),
                      Switch(
                        value: _formData['visibilite']['concurrence']['presence_visibilite'],
                        activeColor: const Color(0xFFE53E3E),
                        onChanged: (value) {
                          setState(() {
                            _formData['visibilite']['concurrence']['presence_visibilite'] = value;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  if (_formData['visibilite']['concurrence']['presence_visibilite']) ...[
                    const Divider(),
                    const Text('Détail par marque:', 
                      style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    
                    _buildVisibilityBrandSection('NIDO', 'nido'),
                    _buildVisibilityBrandSection('LAITY', 'laity'),  
                    _buildVisibilityBrandSection('CANDIA', 'candia'),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityBrandSection(String brand, String key) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(brand, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Text('Extérieur'),
                      Switch(
                        value: _formData['visibilite']['concurrence']['${key}_exterieur'],
                        activeColor: Colors.orange,
                        onChanged: (value) {
                          setState(() {
                            _formData['visibilite']['concurrence']['${key}_exterieur'] = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Text('Intérieur'),
                      Switch(
                        value: _formData['visibilite']['concurrence']['${key}_interieur'],
                        activeColor: Colors.blue,
                        onChanged: (value) {
                          setState(() {
                            _formData['visibilite']['concurrence']['${key}_interieur'] = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Onglet 4 - Actions selon CLAUDE.md (7 actions terrain)
  Widget _buildActionsTab() {
    final actions = [
      {'key': 'referencement_produits', 'label': 'Référencement produits'},
      {'key': 'execution_activites_promotionnelles', 'label': 'Exécution d\'activités promotionnelles'},
      {'key': 'prospection_pdv', 'label': 'Prospection PDV'},
      {'key': 'verification_fifo', 'label': 'Vérification FIFO'},
      {'key': 'rangement_produits', 'label': 'Rangement produits'},
      {'key': 'pose_affiches', 'label': 'Pose d\'affiches'},
      {'key': 'pose_materiel_visibilite', 'label': 'Pose matériel de visibilité'},
    ];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Actions Terrain', Icons.task_alt),
          
          const Text(
            '7 actions terrain avec toggles OUI/NON',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ...actions.map((action) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      action['label']!,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Switch(
                    value: _formData['actions'][action['key']!],
                    activeColor: const Color(0xFFE53E3E),
                    onChanged: (value) {
                      setState(() {
                        _formData['actions'][action['key']!] = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          )),
          
          const SizedBox(height: 24),
          
          // Capture photo obligatoire selon CLAUDE.md
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Documentation visuelle obligatoire',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _capturePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Prendre une photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE53E3E)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE53E3E),
            ),
          ),
        ],
      ),
    );
  }

  // Barre de navigation selon CLAUDE.md
  Widget _buildNavigationBar() {
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
          // Bouton Précédent
          if (_currentTabIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _tabController.animateTo(_currentTabIndex - 1);
                },
                child: const Text('Précédent'),
              ),
            ),
          
          if (_currentTabIndex > 0) const SizedBox(width: 16),
          
          // Bouton Annuler  
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Annuler'),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Bouton Suivant/Sauvegarder
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving 
                  ? null
                  : (_currentTabIndex < 3 ? _nextTab : _saveVisit),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_currentTabIndex < 3 ? 'Suivant' : 'Sauvegarder'),
            ),
          ),
        ],
      ),
    );
  }

  void _nextTab() {
    if (_currentTabIndex < 3) {
      _tabController.animateTo(_currentTabIndex + 1);
    }
  }

  void _capturePhoto() {
    // TODO: Implémenter capture photo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Capture photo à implémenter')),
    );
  }

  // Sauvegarde visite selon CLAUDE.md
  Future<void> _saveVisit() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Créer le modèle VisiteModel selon CLAUDE.md
      final visite = VisiteModel(
        visiteId: const Uuid().v4(),
        pdvId: widget.selectedPdv.pdvId,
        commercial: 'Merchandiser Test', // TODO: Get from auth
        dateVisite: DateTime.now(),
        geolocation: GeolocationData(
          lat: widget.validatedPosition.latitude,
          lng: widget.validatedPosition.longitude,
        ),
        geofenceValidated: true,
        precisionGps: widget.validatedPosition.accuracy,
        produits: ProduitsData.fromJson(_formData['produits']),
        concurrence: ConcurrenceData.fromJson(_formData['concurrence']),
        visibilite: VisibiliteData.fromJson(_formData['visibilite']),
        actions: ActionsData.fromJson(_formData['actions']),
        images: [], // TODO: Add captured photos
        syncStatus: 'pending',
      );

      // Sauvegarder hors-ligne avec sync selon CLAUDE.md
      await _syncService.saveVisiteOffline(visite);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visite sauvegardée avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Retour à l'écran d'accueil
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur sauvegarde: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}