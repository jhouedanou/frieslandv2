import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/kpi_card.dart';
import '../../../data/models/pdv_model.dart';
import '../../../core/services/auth_service.dart';
import 'order_categories_page.dart';

class OrderMainPage extends StatefulWidget {
  const OrderMainPage({super.key});

  @override
  State<OrderMainPage> createState() => _OrderMainPageState();
}

class _OrderMainPageState extends State<OrderMainPage> {
  PDV? _selectedPDV;
  DateTime _orderDate = DateTime.now();
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_orderDate);
    _getCurrentLocationPDV();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }

  void _getCurrentLocationPDV() {
    // TODO: Implémenter la détection automatique du PDV basée sur la géolocalisation
    // Pour l'instant, on sélectionne le premier PDV disponible
    setState(() {
      _selectedPDV = PDV(
        id: 1,
        nom: 'Allassane',
        adresse: 'Treichville, Abidjan',
        latitude: 5.2555,
        longitude: -3.9595,
        telephone: '',
        email: '',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: 'Boutique C',
      );
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _orderDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_orderDate),
      );
      
      if (time != null) {
        setState(() {
          _orderDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
          _dateController.text = _formatDate(_orderDate);
        });
      }
    }
  }

  void _proceedToCategories() {
    if (_selectedPDV == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un PDV'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderCategoriesPage(
          pdv: _selectedPDV!,
          orderDate: _orderDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Commande'),
        backgroundColor: const Color(0xFFE53E3E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec informations générales
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFFE53E3E),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Général',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE53E3E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Date de commande
                  const Text(
                    'Date de commande',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE53E3E)),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                      fillColor: Colors.grey[50],
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Sélection PDV
                  const Text(
                    'PDV Sélection *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<PDV>(
                    value: _selectedPDV,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE53E3E)),
                      ),
                      fillColor: Colors.grey[50],
                      filled: true,
                    ),
                    items: [
                      // TODO: Charger les PDV depuis l'API
                      DropdownMenuItem(
                        value: _selectedPDV,
                        child: Text(_selectedPDV?.nom ?? 'Allassane'),
                      ),
                    ],
                    onChanged: (PDV? newValue) {
                      setState(() {
                        _selectedPDV = newValue;
                      });
                    },
                    hint: const Text('Sélectionner un PDV'),
                  ),
                  
                  if (_selectedPDV != null) ...[
                    const SizedBox(height: 20),
                    
                    // Distance au PDV
                    const Text(
                      'Distance au PDV en metres',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: '289.318',
                      readOnly: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        fillColor: Colors.grey[100],
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Sous-catégorie PDV
                    const Text(
                      'PDV Sous-catégorie',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: _selectedPDV!.category,
                      readOnly: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        fillColor: Colors.grey[100],
                        filled: true,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Bouton continuer
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _proceedToCategories,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53E3E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Continuer vers les Disponibilités',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
