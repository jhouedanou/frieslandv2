import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../data/models/pdv_model.dart';
import '../../../data/models/order_model.dart';

class OrderSummaryPage extends StatefulWidget {
  final PDV pdv;
  final DateTime orderDate;
  final String category;
  final List<OrderItemModel> orderItems;
  final double totalDelivered;
  final double totalPreOrder;

  const OrderSummaryPage({
    super.key,
    required this.pdv,
    required this.orderDate,
    required this.category,
    required this.orderItems,
    required this.totalDelivered,
    required this.totalPreOrder,
  });

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  String _invoiceNumber = '';
  bool _isOrderCompleted = false;
  String? _signature;

  @override
  void initState() {
    super.initState();
    _generateInvoiceNumber();
  }

  void _generateInvoiceNumber() {
    final now = DateTime.now();
    _invoiceNumber = '${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year.toString().substring(2)}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }

  double get _grandTotal => widget.totalDelivered + widget.totalPreOrder;

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'FRIESLAND BONNET ROUGE',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'FACTURE',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Informations de la facture
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('RÉCAPITULATIF'),
                    pw.SizedBox(height: 10),
                    pw.Text('Numéro de facture: $_invoiceNumber'),
                    pw.Text('PDV: ${widget.pdv.nom}'),
                    pw.Text('Date: ${widget.orderDate.day}/${widget.orderDate.month}/${widget.orderDate.year}'),
                    pw.Text('Catégorie: ${widget.category}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Tableau des produits
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // En-tête du tableau
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Produit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Quantité', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Prix unitaire', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Lignes des produits
                  ...widget.orderItems.map((item) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(item.product.name),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(item.quantity.toString()),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${item.unitPrice.toInt()} FCFA'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${item.totalPrice.toInt()} FCFA'),
                      ),
                    ],
                  )),
                ],
              ),
              pw.SizedBox(height: 20),

              // Totaux
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('TOTAL LIVRÉ: ${widget.totalDelivered.toInt()} FCFA'),
                    pw.Text('TOTAL PRÉ-COMMANDE: ${widget.totalPreOrder.toInt()} FCFA'),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'GRAND TOTAL: ${_grandTotal.toInt()} FCFA',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  void _saveOrder() {
    // TODO: Enregistrer la commande dans la base de données
    setState(() {
      _isOrderCompleted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Commande enregistrée avec succès'),
        backgroundColor: Colors.green,
      ),
    );

    // Retourner à l'écran principal après 2 secondes
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.popUntil(context, (route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Récapitulatif'),
        backgroundColor: const Color(0xFFE53E3E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête du récapitulatif
            Container(
              width: double.infinity,
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
                  const Text(
                    'RÉCAPITULATIF',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE53E3E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Numéro de facture :', _invoiceNumber),
                  const SizedBox(height: 8),
                  _buildInfoRow('PDV :', widget.pdv.nom),
                  const SizedBox(height: 8),
                  _buildInfoRow('Date :', '${widget.orderDate.day}/${widget.orderDate.month}/${widget.orderDate.year}'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Catégorie :', widget.category),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Totaux
            Container(
              width: double.infinity,
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
                  _buildTotalRow('TOTAL LIVRÉ', widget.totalDelivered),
                  const SizedBox(height: 8),
                  _buildTotalRow('TOTAL PRÉ-COMMANDE *', widget.totalPreOrder),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildTotalRow('GRAND TOTAL *', _grandTotal, isGrandTotal: true),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Zone de signature
            Container(
              width: double.infinity,
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
                  const Text(
                    'Signature',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap to unlock',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Question commande complétée
            Container(
              width: double.infinity,
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
                  const Text(
                    'Commande complétée',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _isOrderCompleted = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _isOrderCompleted ? Colors.white : Colors.grey[100],
                            side: BorderSide(
                              color: _isOrderCompleted ? Colors.grey[300]! : Colors.grey[400]!,
                            ),
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('NON'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isOrderCompleted = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isOrderCompleted ? const Color(0xFFE53E3E) : Colors.grey[200],
                            foregroundColor: _isOrderCompleted ? Colors.white : Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('OUI'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE53E3E)),
                      foregroundColor: const Color(0xFFE53E3E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Prev'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      foregroundColor: Colors.grey[600],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isOrderCompleted ? _saveOrder : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isOrderCompleted ? const Color(0xFFE53E3E) : Colors.grey[300],
                      foregroundColor: _isOrderCompleted ? Colors.white : Colors.grey[500],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bouton PDF
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _generatePDF,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Générer PDF'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE53E3E)),
                  foregroundColor: const Color(0xFFE53E3E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isGrandTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isGrandTotal ? 16 : 14,
            fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w500,
            color: isGrandTotal ? const Color(0xFFE53E3E) : Colors.black87,
          ),
        ),
        Text(
          'FCFA ${amount.toInt()}.00',
          style: TextStyle(
            fontSize: isGrandTotal ? 16 : 14,
            fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w500,
            color: isGrandTotal ? const Color(0xFFE53E3E) : Colors.black87,
          ),
        ),
      ],
    );
  }
}
