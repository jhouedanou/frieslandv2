import 'package:flutter/material.dart';
import '../../../data/models/pdv_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/order_model.dart';
import 'order_summary_page.dart';

class OrderProductPage extends StatefulWidget {
  final PDV pdv;
  final DateTime orderDate;
  final String category;
  final List<ProductModel> products;

  const OrderProductPage({
    super.key,
    required this.pdv,
    required this.orderDate,
    required this.category,
    required this.products,
  });

  @override
  State<OrderProductPage> createState() => _OrderProductPageState();
}

class _OrderProductPageState extends State<OrderProductPage> {
  final Map<int, int> _quantities = {};
  final Map<int, double> _prices = {};
  double _totalDelivered = 0.0;
  double _totalPreOrder = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeQuantitiesAndPrices();
  }

  void _initializeQuantitiesAndPrices() {
    for (final product in widget.products) {
      _quantities[product.id] = 0;
      _prices[product.id] = product.price;
    }
    _calculateTotals();
  }

  void _updateQuantity(int productId, int quantity) {
    setState(() {
      _quantities[productId] = quantity;
      _calculateTotals();
    });
  }

  void _updatePrice(int productId, double price) {
    setState(() {
      _prices[productId] = price;
      _calculateTotals();
    });
  }

  void _calculateTotals() {
    double delivered = 0.0;
    double preOrder = 0.0;

    for (final product in widget.products) {
      final quantity = _quantities[product.id] ?? 0;
      final price = _prices[product.id] ?? 0.0;
      final total = quantity * price;

      if (quantity > 0) {
        delivered += total;
      }
    }

    _totalDelivered = delivered;
    _totalPreOrder = preOrder; // TODO: Calculer les précommandes
  }

  void _proceedToSummary() {
    final orderItems = <OrderItemModel>[];
    
    for (final product in widget.products) {
      final quantity = _quantities[product.id] ?? 0;
      if (quantity > 0) {
        final price = _prices[product.id] ?? 0.0;
        orderItems.add(OrderItemModel(
          id: 0,
          orderId: 0,
          productId: product.id,
          product: product,
          quantity: quantity,
          unitPrice: price,
          totalPrice: quantity * price,
        ));
      }
    }

    if (orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un produit'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSummaryPage(
          pdv: widget.pdv,
          orderDate: widget.orderDate,
          category: widget.category,
          orderItems: orderItems,
          totalDelivered: _totalDelivered,
          totalPreOrder: _totalPreOrder,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('COMMANDE ${widget.category}'),
        backgroundColor: const Color(0xFFE53E3E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de la commande
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
                  Text(
                    'COMMANDE ${widget.category}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE53E3E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PDV: ${widget.pdv.nom}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // Liste des produits
            ...widget.products.map((product) => _buildProductCard(product)),

            const SizedBox(height: 24),

            // Totaux
            _buildTotalsSection(),

            const SizedBox(height: 24),

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
                    onPressed: _proceedToSummary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53E3E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final quantity = _quantities[product.id] ?? 0;
    final price = _prices[product.id] ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (product.description != null) ...[
            const SizedBox(height: 4),
            Text(
              product.description!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Contrôles de quantité
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: quantity > 0 ? () => _updateQuantity(product.id, quantity - 1) : null,
                      icon: const Icon(Icons.remove),
                      color: quantity > 0 ? Colors.black : Colors.grey,
                    ),
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        quantity.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _updateQuantity(product.id, quantity + 1),
                      icon: const Icon(Icons.add),
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${price.toInt()} FCFA',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE53E3E),
                ),
              ),
            ],
          ),

          if (quantity > 0) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Total: ${(quantity * price).toInt()} FCFA',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE53E3E),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalsSection() {
    return Container(
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
          Text(
            'TOTAL ${widget.category} LIVRÉ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'FCFA ${_totalDelivered.toInt()}.00',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE53E3E),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.category} PRÉ-COMMANDE',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'FCFA ${_totalPreOrder.toInt()}.00',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
