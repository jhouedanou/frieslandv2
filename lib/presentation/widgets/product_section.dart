import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/themes/app_theme.dart';

class ProductSection extends StatelessWidget {
  final String category;
  final List<String> products;
  final Map<String, String?> productData;
  final Function(Map<String, String?>) onProductDataChanged;
  final bool isSimpleSection;

  const ProductSection({
    Key? key,
    required this.category,
    required this.products,
    required this.productData,
    required this.onProductDataChanged,
    this.isSimpleSection = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catégorie $category',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Category presence
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Présence $category',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Présent'),
                          value: 'true',
                          groupValue: productData['present'],
                          onChanged: (value) {
                            final newData = Map<String, String?>.from(productData);
                            newData['present'] = value;
                            onProductDataChanged(newData);
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Absent'),
                          value: 'false',
                          groupValue: productData['present'],
                          onChanged: (value) {
                            final newData = Map<String, String?>.from(productData);
                            newData['present'] = value;
                            onProductDataChanged(newData);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Product details (if category is present and not simple section)
          if (productData['present'] == 'true' && !isSimpleSection) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Détail des produits',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...products.map((product) => _buildProductItem(product)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Prix respectés (if category is present)
          if (productData['present'] == 'true') ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prix respectés',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Oui'),
                            value: 'true',
                            groupValue: productData['prix_respectes'],
                            onChanged: (value) {
                              final newData = Map<String, String?>.from(productData);
                              newData['prix_respectes'] = value;
                              onProductDataChanged(newData);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Non'),
                            value: 'false',
                            groupValue: productData['prix_respectes'],
                            onChanged: (value) {
                              final newData = Map<String, String?>.from(productData);
                              newData['prix_respectes'] = value;
                              onProductDataChanged(newData);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Photo section
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Photos $category',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Take photo from camera
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Prendre photo'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Select from gallery
                          },
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Galerie'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(String product) {
    final key = product.toLowerCase().replaceAll(' ', '_').replaceAll('.', '_');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildStatusChip(
                AppConstants.disponiblePrixRespecte,
                productData[key],
                key,
                Colors.green,
              ),
              _buildStatusChip(
                AppConstants.disponiblePrixNonRespecte,
                productData[key],
                key,
                Colors.orange,
              ),
              _buildStatusChip(
                AppConstants.presentPrixRespecte,
                productData[key],
                key,
                Colors.lightGreen,
              ),
              _buildStatusChip(
                AppConstants.enRupture,
                productData[key],
                key,
                Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, String? currentValue, String key, Color color) {
    final isSelected = currentValue == status;
    
    return FilterChip(
      label: Text(
        status,
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: color.withOpacity(0.1),
      onSelected: (selected) {
        if (selected) {
          final newData = Map<String, String?>.from(productData);
          newData[key] = status;
          onProductDataChanged(newData);
        }
      },
    );
  }
}