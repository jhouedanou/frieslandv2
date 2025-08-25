import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../data/models/pdv_model.dart';
import '../../core/services/auth_service.dart';

class PDVManagementPage extends StatefulWidget {
  const PDVManagementPage({super.key});

  @override
  State<PDVManagementPage> createState() => _PDVManagementPageState();
}

class _PDVManagementPageState extends State<PDVManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  // Controllers pour le formulaire
  final _nomController = TextEditingController();
  final _adresseController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _contactController = TextEditingController();
  
  // Variables d'état
  bool _isLoading = false;
  bool _isLocating = false;
  String _selectedType = 'Boutique';
  Position? _currentPosition;
  String? _detectedAddress;
  
  // Types de PDV disponibles
  final List<String> _pdvTypes = [
    'Boutique',
    'Superette', 
    'Épicerie',
    'Mini-Market',
    'Supermarché',
    'Grossiste',
    'Détaillant',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocating = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service de localisation désactivé')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permission de localisation refusée')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission de localisation définitivement refusée'),
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
      });

      // Géocodage inverse pour obtenir l'adresse
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final address = [
            place.street,
            place.locality,
            place.subAdministrativeArea,
            place.administrativeArea,
          ].where((part) => part != null && part.isNotEmpty).join(', ');
          
          setState(() {
            _detectedAddress = address;
            _adresseController.text = address;
          });
        }
      } catch (e) {
        print('Erreur géocodage inverse: $e');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur localisation: $e')),
        );
      }
    } finally {
      setState(() {
        _isLocating = false;
      });
    }
  }

  Future<void> _createPDV() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Localisation requise pour créer un PDV')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Créer le modèle PDV
      final pdv = PDVModel(
        pdvId: DateTime.now().millisecondsSinceEpoch.toString(),
        nomPdv: _nomController.text.trim(),
        canal: 'Moderne',
        categoriePdv: _selectedType,
        sousCategoriePdv: _selectedType,
        region: 'ABIDJAN',
        territoire: 'ABIDJAN SUD',
        zone: _authService.userZone ?? 'ABIDJAN SUD',
        secteur: _authService.userSecteurs?.first ?? 'TREICHVILLE',
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        rayonGeofence: 300.0, // 300m par défaut selon CLAUDE.md
        adressage: _adresseController.text.trim(),
        dateCreation: DateTime.now(),
        ajoutePar: _authService.currentUser?['email'] ?? 'user',
        mdm: 'FR_' + DateTime.now().millisecondsSinceEpoch.toString(),
      );

      // TODO: Intégrer avec l'API backend pour sauvegarder
      // Pour l'instant, simulation de la sauvegarde
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDV "${pdv.nomPdv}" créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Retourner le PDV créé à l'écran précédent
        Navigator.pop(context, pdv);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur création PDV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, Map<String, String>> _getDefaultSchedule() {
    return {
      'lundi': {'ouverture': '07:00', 'fermeture': '19:00'},
      'mardi': {'ouverture': '07:00', 'fermeture': '19:00'},
      'mercredi': {'ouverture': '07:00', 'fermeture': '19:00'},
      'jeudi': {'ouverture': '07:00', 'fermeture': '19:00'},
      'vendredi': {'ouverture': '07:00', 'fermeture': '19:00'},
      'samedi': {'ouverture': '07:00', 'fermeture': '20:00'},
      'dimanche': {'ouverture': '08:00', 'fermeture': '18:00'},
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un PDV'),
        backgroundColor: const Color(0xFFE53E3E),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section localisation
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, 
                                   color: Color(0xFFE53E3E)),
                          const SizedBox(width: 8),
                          const Text(
                            'Localisation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (_isLocating)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_currentPosition != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.check_circle, 
                                       color: Colors.green, size: 16),
                                  SizedBox(width: 4),
                                  Text('Position détectée',
                                       style: TextStyle(
                                         color: Colors.green,
                                         fontWeight: FontWeight.w500,
                                       )),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Précision: ${_currentPosition!.accuracy.toStringAsFixed(0)}m',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning, 
                                         color: Colors.orange, size: 16),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Position non détectée',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _getCurrentLocation,
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Section informations PDV
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.store, color: Color(0xFFE53E3E)),
                          SizedBox(width: 8),
                          Text(
                            'Informations du PDV',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Nom du PDV
                      TextFormField(
                        controller: _nomController,
                        decoration: InputDecoration(
                          labelText: 'Nom du PDV *',
                          hintText: 'Ex: Boutique Central Treichville',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.business),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le nom du PDV est requis';
                          }
                          if (value.trim().length < 3) {
                            return 'Le nom doit avoir au moins 3 caractères';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Type de PDV
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'Type de PDV *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.category),
                        ),
                        items: _pdvTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Adresse
                      TextFormField(
                        controller: _adresseController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Adresse *',
                          hintText: _detectedAddress ?? 'Adresse complète du PDV',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.location_city),
                          suffixIcon: _detectedAddress != null
                              ? IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: _getCurrentLocation,
                                  tooltip: 'Actualiser l\'adresse',
                                )
                              : null,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'L\'adresse est requise';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Téléphone
                      TextFormField(
                        controller: _telephoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Téléphone',
                          hintText: '+225 01 23 45 67 89',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.phone),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            // Validation basique du format téléphone
                            if (value.length < 8) {
                              return 'Numéro de téléphone trop court';
                            }
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Contact principal
                      TextFormField(
                        controller: _contactController,
                        decoration: InputDecoration(
                          labelText: 'Contact principal',
                          hintText: 'Nom du gérant ou responsable',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Section informations commerciales
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.business_center, color: Color(0xFFE53E3E)),
                          SizedBox(width: 8),
                          Text(
                            'Informations commerciales',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Secteur assigné (lecture seule)
                      TextFormField(
                        initialValue: _authService.userSecteurs?.join(', ') ?? 'Non défini',
                        decoration: InputDecoration(
                          labelText: 'Secteur assigné',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.map),
                          suffixIcon: const Icon(Icons.lock),
                        ),
                        enabled: false,
                      ),

                      const SizedBox(height: 16),

                      // Zone assignée (lecture seule)
                      TextFormField(
                        initialValue: _authService.userZone ?? 'Non définie',
                        decoration: InputDecoration(
                          labelText: 'Zone assignée',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.place),
                          suffixIcon: const Icon(Icons.lock),
                        ),
                        enabled: false,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Bouton de création
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _createPDV,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53E3E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add_business),
                  label: Text(
                    _isLoading ? 'Création en cours...' : 'Créer le PDV',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Note informative
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Le PDV sera créé avec un rayon de géofencing de 300m selon les spécifications Bonnet Rouge.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
