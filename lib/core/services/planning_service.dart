import 'package:flutter/material.dart';
import '../../data/models/pdv_model.dart';
import '../../data/models/visite_model.dart';

class PlanningService {
  /// Obtient le planning du jour actuel
  static Future<List<VisiteModel>> getDayPlanning([DateTime? date]) async {
    final targetDate = date ?? DateTime.now();
    
    // TODO: Remplacer par un appel API réel
    // Pour l'instant, on retourne des données factices
    return [
      VisiteModel(
        id: 1,
        pdvId: 1,
        pdvName: 'Allassane - Treichville',
        visitDate: targetDate.copyWith(hour: 9, minute: 0),
        status: 'PLANNED',
        merchandiserName: 'Commercial ABC',
        notes: 'Visite de routine - Vérification stock',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      VisiteModel(
        id: 2,
        pdvId: 2,
        pdvName: 'Boutique Centrale - Marcory',
        visitDate: targetDate.copyWith(hour: 11, minute: 30),
        status: 'PLANNED',
        merchandiserName: 'Commercial ABC',
        notes: 'Livraison nouveaux produits',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      VisiteModel(
        id: 3,
        pdvId: 3,
        pdvName: 'Supermarché Express - Koumassi',
        visitDate: targetDate.copyWith(hour: 14, minute: 15),
        status: 'PLANNED',
        merchandiserName: 'Commercial ABC',
        notes: 'Formation équipe + merchandising',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      VisiteModel(
        id: 4,
        pdvId: 4,
        pdvName: 'Épicerie du Marché - Adjamé',
        visitDate: targetDate.copyWith(hour: 16, minute: 45),
        status: 'PLANNED',
        merchandiserName: 'Commercial ABC',
        notes: 'Négociation espace de vente',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
  
  /// Trouve le PDV le plus proche basé sur la géolocalisation
  static Future<PDV?> findClosestPDV({
    double? userLatitude,
    double? userLongitude,
  }) async {
    // TODO: Implémenter la logique de géolocalisation réelle
    // Pour l'instant, on retourne un PDV fictif
    return PDV(
      id: 1,
      nom: 'Allassane',
      adresse: 'Treichville, Abidjan',
      latitude: 5.2555,
      longitude: -3.9595,
      telephone: '+225 XX XX XX XX',
      email: 'allassane@example.com',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      category: 'Boutique C',
    );
  }
  
  /// Affiche un popup pour recommander la visite du PDV le plus proche
  static Future<void> showClosestPDVRecommendation(BuildContext context) async {
    final closestPDV = await findClosestPDV();
    
    if (closestPDV == null || !context.mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53E3E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFFE53E3E),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'PDV le plus proche',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE53E3E),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nous recommandons de commencer votre tournée par:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      closestPDV.nom,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            closestPDV.adresse,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53E3E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        closestPDV.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFE53E3E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.directions_walk,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Distance: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '289 m', // TODO: Calculer la vraie distance
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Peut-être plus tard',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Naviguer vers la page de création de visite avec ce PDV pré-sélectionné
              },
              icon: const Icon(Icons.add_task),
              label: const Text('Commencer la visite'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// Affiche un popup pour planifier une visite
  static Future<void> showVisitPlanningDialog(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53E3E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.schedule,
                      color: Color(0xFFE53E3E),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Planifier une visite',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE53E3E),
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sélectionnez la date et l\'heure de votre visite:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Sélecteur de date
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Color(0xFFE53E3E),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Sélecteur d'heure
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Heure',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setState(() {
                                selectedTime = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Color(0xFFE53E3E),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Annuler',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // TODO: Enregistrer la planification
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Visite planifiée pour le ${selectedDate.day}/${selectedDate.month}/${selectedDate.year} à ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Confirmer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53E3E),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
