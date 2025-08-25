import 'package:flutter/material.dart';
import '../../../data/models/planning_visit_model.dart';
import '../../../data/models/product_model.dart';
import 'order_product_page.dart';

class OrderCategoriesPage extends StatefulWidget {
  final SimplePDV pdv;
  final DateTime orderDate;

  const OrderCategoriesPage({
    super.key,
    required this.pdv,
    required this.orderDate,
  });

  @override
  State<OrderCategoriesPage> createState() => _OrderCategoriesPageState();
}

class _OrderCategoriesPageState extends State<OrderCategoriesPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, List<ProductModel>> _categoriesProducts = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: ProductCategory.all.length,
      vsync: this,
    );
    _loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    // TODO: Charger les produits depuis l'API
    // Pour l'instant, on utilise des données fictives
    for (final category in ProductCategory.all) {
      _categoriesProducts[category] = _getProductsForCategory(category);
    }
    setState(() {});
  }

  List<ProductModel> _getProductsForCategory(String category) {
    // Données d'exemple basées sur les captures d'écran
    switch (category) {
      case ProductCategory.evap:
        return [
          ProductModel(
            id: 1,
            code: 'EVAP-BR-GOLD',
            name: 'EVAP-BR Gold',
            category: category,
            price: 275,
            stockQuantity: 12,
            unit: 'unité',
            description: 'manquant 12',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          ProductModel(
            id: 2,
            code: 'EVAP-BR-160G',
            name: 'EVAP-BR 160g',
            category: category,
            price: 250,
            stockQuantity: 18,
            unit: 'unité',
            description: 'manquant 18',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
      case ProductCategory.yaourt:
        return [
          ProductModel(
            id: 10,
            code: 'YAOURT-BR-YOGOO-NATURE-MINI-90ML',
            name: 'YAOURT-BR Yogoo nature mini 90 ml',
            category: category,
            price: 135,
            stockQuantity: 6,
            unit: 'unité',
            description: 'manquant 6',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commande - ${widget.pdv.nom}'),
        backgroundColor: const Color(0xFFE53E3E),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: ProductCategory.all.map((category) {
            return Tab(
              text: _getCategoryShortName(category),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: ProductCategory.all.map((category) {
          return _buildCategoryView(category);
        }).toList(),
      ),
    );
  }

  String _getCategoryShortName(String category) {
    switch (category) {
      case ProductCategory.evap:
        return 'EVAP';
      case ProductCategory.scm:
        return 'SCM';
      case ProductCategory.imp:
        return 'IMP';
      case ProductCategory.uht:
        return 'UHT';
      case ProductCategory.yaourt:
        return 'YAOURT';
      case ProductCategory.cerealesAuLait:
        return 'CÉRÉALES';
      default:
        return category;
    }
  }

  Widget _buildCategoryView(String category) {
    final products = _categoriesProducts[category] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la catégorie
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
                  ProductCategory.getDisplayName(category),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE53E3E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pour chaque produit $category, ajoutez le nombre de produits visibles dans le magasin et le prix pratiqué',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Bouton "New" pour ajouter des produits
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'New',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Liste des produits de la catégorie
          if (products.isNotEmpty) ...[
            ...products.map((product) => _buildProductCard(product)),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun produit ${_getCategoryShortName(category)} disponible',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Appuyez sur "New" pour ajouter des produits',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Bouton continuer vers la commande
          if (products.isNotEmpty)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderProductPage(
                        pdv: widget.pdv,
                        orderDate: widget.orderDate,
                        category: category,
                        products: products,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53E3E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Commander ${_getCategoryShortName(category)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53E3E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${product.price.toInt()} FCFA',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE53E3E),
                  ),
                ),
              ),
            ],
          ),
          if (product.description != null) ...[
            const SizedBox(height: 8),
            Text(
              product.description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.inventory,
                size: 16,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                'Stock: ${product.stockQuantity} ${product.unit}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
