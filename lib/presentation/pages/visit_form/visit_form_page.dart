import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/geofencing_service.dart';
import '../../../domain/entities/pdv.dart';
import '../../widgets/product_section.dart';
import '../../widgets/geofence_status_widget.dart';

class VisitFormPage extends StatefulWidget {
  final PDV? selectedPDV;
  
  const VisitFormPage({Key? key, this.selectedPDV}) : super(key: key);

  @override
  State<VisitFormPage> createState() => _VisitFormPageState();
}

class _VisitFormPageState extends State<VisitFormPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final GeofencingService _geofencingService = GeofencingService();
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _commercialController = TextEditingController();
  final _mdmController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Geofencing
  Position? _currentPosition;
  GeofenceValidationResult? _geofenceStatus;
  bool _isLocationLoading = true;
  
  // Product data
  Map<String, Map<String, String?>> _productData = {
    'EVAP': {
      'present': 'false',
      'br_gold': null,
      'br_160g': null,
      'brb_160g': null,
      'br_400g': null,
      'brb_400g': null,
      'pearl_400g': null,
      'prix_respectes': 'false',
    },
    'IMP': {
      'present': 'false',
      'br_400g': null,
      'br_900g': null,
      'br_2_5kg': null,
      'br_375g': null,
      'brb_400g': null,
      'br_20g': null,
      'brb_25g': null,
      'prix_respectes': 'false',
    },
    'SCM': {
      'present': 'false',
      'br_1kg': null,
      'brb_1kg': null,
      'brb_397g': null,
      'br_397g': null,
      'pearl_1kg': null,
      'prix_respectes': 'false',
    },
    'UHT': {
      'present': 'false',
      'prix_respectes': 'false',
    },
    'YOGHURT': {
      'present': 'false',
      'prix_respectes': 'false',
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      await _geofencingService.initialize();
      _currentPosition = _geofencingService.currentPosition;
      
      if (widget.selectedPDV != null && _currentPosition != null) {
        _geofenceStatus = _geofencingService.validateGeofence(
          widget.selectedPDV!,
          _currentPosition,
        );
        _geofencingService.startMonitoringPDV(widget.selectedPDV!);
        
        // Listen to geofence status changes
        _geofencingService.geofenceStatus.listen((isValid) {
          setState(() {
            if (_geofenceStatus != null) {
              _geofenceStatus = GeofenceValidationResult(
                isValid: isValid,
                distance: _geofenceStatus!.distance,
                message: isValid ? 'Position validée' : 'Hors périmètre',
                accuracy: _geofenceStatus!.accuracy,
              );
            }
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur GPS: $e')),
      );
    } finally {
      setState(() {
        _isLocationLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _geofencingService.stopMonitoring();
    _commercialController.dispose();
    _mdmController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedPDV?.nomPdv ?? 'Nouvelle Visite'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'EVAP'),
            Tab(text: 'IMP'),
            Tab(text: 'SCM'),
            Tab(text: 'UHT'),
            Tab(text: 'YOGHURT'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Geofence status
            if (widget.selectedPDV != null)
              GeofenceStatusWidget(
                geofenceStatus: _geofenceStatus,
                isLoading: _isLocationLoading,
              ),
            
            // General info
            Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _commercialController.text.isEmpty ? null : _commercialController.text,
                          decoration: const InputDecoration(
                            labelText: 'Commercial',
                            border: OutlineInputBorder(),
                          ),
                          items: AppConstants.commercials.map((commercial) {
                            return DropdownMenuItem(
                              value: commercial,
                              child: Text(commercial),
                            );
                          }).toList(),
                          onChanged: (value) {
                            _commercialController.text = value ?? '';
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Sélectionnez un commercial';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _mdmController,
                          decoration: const InputDecoration(
                            labelText: 'MDM',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'MDM requis';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Product tabs
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEVAPSection(),
                  _buildIMPSection(),
                  _buildSCMSection(),
                  _buildUHTSection(),
                  _buildYOGHURTSection(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Annuler'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _canSaveVisit() ? _saveVisit : null,
                child: const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEVAPSection() {
    return ProductSection(
      category: 'EVAP',
      products: const [
        'BR Gold',
        'BR 160g',
        'BRB 160g', 
        'BR 400g',
        'BRB 400g',
        'Pearl 400g',
      ],
      productData: _productData['EVAP']!,
      onProductDataChanged: (data) {
        setState(() {
          _productData['EVAP'] = data;
        });
      },
    );
  }

  Widget _buildIMPSection() {
    return ProductSection(
      category: 'IMP',
      products: const [
        'BR 400g',
        'BR 900g',
        'BR 2.5Kg',
        'BR 375g',
        'BRB 400g',
        'BR 20g',
        'BRB 25g',
      ],
      productData: _productData['IMP']!,
      onProductDataChanged: (data) {
        setState(() {
          _productData['IMP'] = data;
        });
      },
    );
  }

  Widget _buildSCMSection() {
    return ProductSection(
      category: 'SCM',
      products: const [
        'BR 1Kg',
        'BRB 1Kg',
        'BRB 397g',
        'BR 397g',
        'Pearl 1Kg',
      ],
      productData: _productData['SCM']!,
      onProductDataChanged: (data) {
        setState(() {
          _productData['SCM'] = data;
        });
      },
    );
  }

  Widget _buildUHTSection() {
    return ProductSection(
      category: 'UHT',
      products: const [], // Simple presence/price for UHT
      productData: _productData['UHT']!,
      onProductDataChanged: (data) {
        setState(() {
          _productData['UHT'] = data;
        });
      },
      isSimpleSection: true,
    );
  }

  Widget _buildYOGHURTSection() {
    return ProductSection(
      category: 'YOGHURT',
      products: const [], // Simple presence/price for YOGHURT
      productData: _productData['YOGHURT']!,
      onProductDataChanged: (data) {
        setState(() {
          _productData['YOGHURT'] = data;
        });
      },
      isSimpleSection: true,
    );
  }

  bool _canSaveVisit() {
    if (widget.selectedPDV == null) return false;
    if (_geofenceStatus?.isValid != true) return false;
    if (_commercialController.text.isEmpty) return false;
    if (_mdmController.text.isEmpty) return false;
    return true;
  }

  Future<void> _saveVisit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Create visit object and save
      // Implementation will depend on your repository
      
      Navigator.of(context).pop(); // Close loading dialog
      Navigator.of(context).pop(); // Return to previous screen
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visite enregistrée avec succès')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
}