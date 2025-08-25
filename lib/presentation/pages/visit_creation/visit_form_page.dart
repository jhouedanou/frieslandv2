import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../data/models/pdv_model.dart';
import '../../../data/models/visite_data_models.dart';
import '../../../data/models/visite_model.dart';
import '../../../core/services/sync_service.dart';
import 'package:uuid/uuid.dart';

// Écran 4: Formulaire multi-onglets selon CLAUDE.md
// 4 sections: Général, Concurrence, Visibilité, Actions
class VisitFormPage extends StatefulWidget {
  final PDVModel selectedPDV;

  const VisitFormPage({
    super.key,
    required this.selectedPDV,
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
  
  // Capture photo
  final ImagePicker _picker = ImagePicker();
  final List<File> _capturedImages = [];
  
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
        title: Text('Visite - ${widget.selectedPDV.nomPdv}'),
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
                  Row(
                    children: [
                      const Icon(Icons.camera_alt, color: Color(0xFFE53E3E)),
                      const SizedBox(width: 8),
                      const Text(
                        'Documentation visuelle obligatoire',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Affichage des photos capturées
                  if (_capturedImages.isNotEmpty) ..[
                    Container(
                      height: 100,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _capturedImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _capturedImages[index],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _capturedImages.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _capturePhoto,
                          icon: const Icon(Icons.camera_alt),
                          label: Text('Prendre photo (${_capturedImages.length})'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53E3E),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      if (_capturedImages.isNotEmpty) ..[
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _capturedImages.clear();
                            });
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Effacer'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  // Validation des photos
                  if (_capturedImages.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Au moins une photo est requise',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                            ),
                          ),
                        ],
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

  Future<void> _capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      
      if (photo != null) {
        final imageFile = File(photo.path);
        setState(() {
          _capturedImages.add(imageFile);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo capturée (${_capturedImages.length})'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur capture photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Sauvegarde visite selon CLAUDE.md
  Future<void> _saveVisit() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Obtenir la position actuelle pour la géolocalisation
      Position currentPosition;
      try {
        currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        // Position par défaut si géolocalisation échoue
        currentPosition = Position(
          latitude: widget.selectedPDV.latitude,
          longitude: widget.selectedPDV.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
      
      // Créer le modèle VisiteModel selon CLAUDE.md
      final visite = VisiteModel(
        visiteId: const Uuid().v4(),
        pdvId: widget.selectedPDV.pdvId,
        commercial: 'Merchandiser Test', // TODO: Get from auth
        dateVisite: DateTime.now(),
        geolocation: GeolocationData(
          lat: currentPosition.latitude,
          lng: currentPosition.longitude,
        ),
        geofenceValidated: true,
        precisionGps: currentPosition.accuracy,
        produits: _convertToProduitsData(_formData['produits']),
        concurrence: _convertToConcurrenceData(_formData['concurrence']),
        visibilite: _convertToVisibiliteData(_formData['visibilite']),
        actions: _convertToActionsData(_formData['actions']),
        images: _capturedImages.map((file) => file.path).toList(),
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
  
  // Méthodes de conversion pour éviter les erreurs de type
  ProduitsData _convertToProduitsData(Map<String, dynamic> data) {
    return ProduitsData(
      evap: EvapData(
        present: data['evap']['present'] ?? false,
        brGold: data['evap']['br_gold'],
        br150g: data['evap']['br_150g'],
        brb150g: data['evap']['brb_150g'],
        br380g: data['evap']['br_380g'],
        brb380g: data['evap']['brb_380g'],
        pearl380g: data['evap']['pearl_380g'],
      ),
      imp: ImpData(
        present: data['imp']['present'] ?? false,
        prixRespectes: data['imp']['prix_respectes'] ?? false,
        br2: data['imp']['br_2'],
        br16g: data['imp']['br_16g'],
        brb16g: data['imp']['brb_16g'],
        br360g: data['imp']['br_360g'],
        br400gTin: data['imp']['br_400g_tin'],
        brb360g: data['imp']['brb_360g'],
        br900gTin: data['imp']['br_900g_tin'],
      ),
      scm: ScmData(
        present: data['scm']['present'] ?? false,
        prixRespectes: data['scm']['prix_respectes'] ?? false,
        produits: null,
      ),
      uht: UhtData(
        present: data['uht']['present'] ?? false,
        prixRespectes: data['uht']['prix_respectes'] ?? false,
        produits: null,
      ),
      yaourt: YaourtData(
        present: data['yaourt']['present'] ?? false,
      ),
    );
  }

  ConcurrenceData _convertToConcurrenceData(Map<String, dynamic> data) {
    return ConcurrenceData(
      presenceConcurrents: data['presence_concurrents'] ?? false,
      evap: ConcurrenceEvapData(
        present: data['evap']['present'] ?? false,
        cowmilk: data['evap']['cowmilk'],
        nido150g: data['evap']['nido_150g'],
        autre: data['evap']['autre'],
      ),
      imp: ConcurrenceImpData(
        present: data['imp']['present'] ?? false,
        nido: data['imp']['nido'],
        laity: data['imp']['laity'],
        autre: data['imp']['autre'],
      ),
      scm: ConcurrenceScmData(
        present: data['scm']['present'] ?? false,
        topSaho: data['scm']['top_saho'],
        autre: data['scm']['autre'],
        nomConcurrent: data['scm']['nom_concurrent'],
      ),
      uht: data['uht'] ?? false,
    );
  }

  VisibiliteData _convertToVisibiliteData(Map<String, dynamic> data) {
    return VisibiliteData(
      interieure: VisibiliteInterieureData(
        presenceVisibilite: data['interieure']['presence_visibilite'] ?? false,
      ),
      concurrence: VisibiliteConcurrenceData(
        presenceVisibilite: data['concurrence']['presence_visibilite'] ?? false,
        nidoExterieur: data['concurrence']['nido_exterieur'] ?? false,
        nidoInterieur: data['concurrence']['nido_interieur'] ?? false,
        laityExterieur: data['concurrence']['laity_exterieur'] ?? false,
        laityInterieur: data['concurrence']['laity_interieur'] ?? false,
        candiaExterieur: data['concurrence']['candia_exterieur'] ?? false,
        candiaInterieur: data['concurrence']['candia_interieur'] ?? false,
      ),
    );
  }

  ActionsData _convertToActionsData(Map<String, dynamic> data) {
    return ActionsData(
      referencementProduits: data['referencement_produits'] ?? false,
      executionActivitesPromotionnelles: data['execution_activites_promotionnelles'] ?? false,
      prospectionPdv: data['prospection_pdv'] ?? false,
      verificationFifo: data['verification_fifo'] ?? false,
      rangementProduits: data['rangement_produits'] ?? false,
      poseAffiches: data['pose_affiches'] ?? false,
      poseMaterielVisibilite: data['pose_materiel_visibilite'] ?? false,
    );
  }
}