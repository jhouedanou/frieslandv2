import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportService {
  static const String supportPhoneNumber = '+2250748348221';
  
  /// Capture une capture d'écran et l'envoie via WhatsApp
  static Future<void> sendSupportMessage({
    required BuildContext context,
    required GlobalKey screenshotKey,
    String? customMessage,
  }) async {
    try {
      // Capture de l'écran
      final screenshot = await _captureScreenshot(screenshotKey);
      
      // Message par défaut
      final message = customMessage ?? 
          'Bonjour,\n\nJ\'ai besoin d\'aide avec l\'application Friesland Bonnet Rouge.\n\nMerci pour votre support.';
      
      // Si capture réussie, envoyer via WhatsApp
      if (screenshot != null) {
        await _sendWhatsAppMessage(message);
        
        // Afficher confirmation
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Message envoyé au support technique'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'envoi du message support: $e');
      
      // Fallback: ouvrir WhatsApp sans image
      await _sendWhatsAppMessage(customMessage ?? 'Besoin d\'aide avec l\'application Friesland');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la capture d\'écran, message texte envoyé'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
  
  /// Capture une capture d'écran du widget
  static Future<File?> _captureScreenshot(GlobalKey screenshotKey) async {
    try {
      RenderRepaintBoundary? boundary = screenshotKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        debugPrint('Boundary non trouvé pour la capture d\'écran');
        return null;
      }
      
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        debugPrint('Impossible de convertir l\'image en ByteData');
        return null;
      }
      
      Uint8List pngBytes = byteData.buffer.asUint8List();
      
      // Sauvegarder temporairement
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/support_screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);
      
      debugPrint('Capture d\'écran sauvegardée: $imagePath');
      return imageFile;
    } catch (e) {
      debugPrint('Erreur lors de la capture d\'écran: $e');
      return null;
    }
  }
  
  /// Envoie un message WhatsApp
  static Future<void> _sendWhatsAppMessage(String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = 'https://wa.me/$supportPhoneNumber?text=$encodedMessage';
    
    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback: essayer l'URL directe WhatsApp
        final fallbackUrl = 'whatsapp://send?phone=$supportPhoneNumber&text=$encodedMessage';
        final fallbackUri = Uri.parse(fallbackUrl);
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri);
        } else {
          throw Exception('WhatsApp n\'est pas disponible sur cet appareil');
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'ouverture de WhatsApp: $e');
      throw e;
    }
  }
  
  /// Affiche un dialogue de contact support
  static Future<void> showSupportDialog({
    required BuildContext context,
    required GlobalKey screenshotKey,
  }) async {
    final messageController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.support_agent,
                color: const Color(0xFFE53E3E),
              ),
              const SizedBox(width: 8),
              const Text(
                'Support Technique',
                style: TextStyle(
                  color: Color(0xFFE53E3E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Décrivez votre problème ou votre question:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tapez votre message ici...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE53E3E)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Une capture d\'écran sera automatiquement jointe à votre message.',
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await sendSupportMessage(
                  context: context,
                  screenshotKey: screenshotKey,
                  customMessage: messageController.text.isNotEmpty 
                    ? messageController.text 
                    : null,
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('Envoyer'),
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
}
