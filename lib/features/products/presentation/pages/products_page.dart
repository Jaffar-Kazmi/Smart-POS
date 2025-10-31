
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/features/auth/presentation/providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/product.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(isAdmin),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildProductsList(isAdmin),
            ),
          ],
        ),
      ),
      // Only show add button for Admin
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddProductDialog(),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildHeader(bool isAdmin) {
    return Row(
      children: [
        Text(
          'Products & Inventory',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        if (isAdmin) // Only show low stock chip to admin
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              final lowStockCount = provider.lowStockProducts.length;
              if (lowStockCount > 0) {
                return Chip(
                  label: Text('$lowStockCount Low Stock'),
                  backgroundColor: AppColors.warning.withOpacity(0.1),
                  labelStyle: const TextStyle(color: AppColors.warning),
                  avatar: const Icon(Icons.warning, size: 16, color: AppColors.warning),
                );
              }
              return Container();
            },
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search products by name, description, or barcode...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      onChanged: (value) {
        Provider.of<ProductProvider>(context, listen: false).searchProducts(value);
      },
    );
  }

  Widget _buildProductsList(bool isAdmin) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = productProvider.products;
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No products found',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.image,
                    color: Colors.grey,
                  ),
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.description != null)
                      Text(
                        product.description!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Stock: ${product.stockQuantity}',
                          style: TextStyle(
                            color: product.isLowStock ? AppColors.error : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: isAdmin
                    ? PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditProductDialog(product);
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(product);
                          }
                        },
                      )
                    : const Icon(Icons.lock, color: Colors.grey), // Read-only indicator
              ),
            );
          },
        );
      },
    );
  }

  void _showAddProductDialog() {
    // Implementation for adding a product
  }

  void _showEditProductDialog(Product product) {
    // Implementation for editing a product
  }

  void _showDeleteConfirmation(Product product) {
    // Implementation for deleting a product
  }
}
