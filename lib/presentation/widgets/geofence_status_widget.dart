import 'package:flutter/material.dart';
import '../../core/services/geofencing_service.dart';
import '../../core/themes/app_theme.dart';

class GeofenceStatusWidget extends StatelessWidget {
  final GeofenceValidationResult? geofenceStatus;
  final bool isLoading;

  const GeofenceStatusWidget({
    super.key,
    this.geofenceStatus,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[100],
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Vérification de la position GPS...'),
          ],
        ),
      );
    }

    if (geofenceStatus == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[100],
        child: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.grey),
            SizedBox(width: 12),
            Text('Position GPS non disponible'),
          ],
        ),
      );
    }

    final status = geofenceStatus!;
    final color = status.isValid ? AppTheme.successColor : AppTheme.errorColor;
    final icon = status.isValid ? Icons.check_circle : Icons.error;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      color: color.withOpacity(0.1),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.message,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!status.isValid) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Distance: ${status.distance.toStringAsFixed(0)}m • Précision: ${status.accuracy.toStringAsFixed(1)}m',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!status.isValid)
            TextButton(
              onPressed: () {
                _showGeofenceHelp(context);
              },
              child: const Text('Aide'),
            ),
        ],
      ),
    );
  }

  void _showGeofenceHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Position requise'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pour enregistrer une visite, vous devez être:'),
            SizedBox(height: 12),
            Text('• À moins de 300m du point de vente'),
            Text('• Avec une précision GPS de moins de 10m'),
            SizedBox(height: 12),
            Text('Conseils:'),
            Text('• Sortez à l\'extérieur si possible'),
            Text('• Attendez quelques secondes pour améliorer la précision'),
            Text('• Vérifiez que le GPS est activé'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
}