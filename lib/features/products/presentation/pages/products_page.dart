import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/product_provider.dart';
import '../../domain/entities/product.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/export_service.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../../core/presentation/widgets/futuristic_card.dart';
import '../../../../core/presentation/widgets/futuristic_header.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FuturisticHeader(
            title: 'Products & Inventory',
            actions: [
              if (isAdmin)
                Tooltip(
                  message: 'Export all products to CSV',
                  child: OutlinedButton.icon(
                    onPressed: _exportProductsToCSV,
                    icon: const Icon(Icons.file_upload),
                    label: const Text('Export'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchBar(),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCategoryFilter(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildProductsList(isAdmin),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? Tooltip(
              message: 'Add new product',
              child: FloatingActionButton(
                onPressed: () => _showAddProductDialog(),
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by product name or barcode...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? Tooltip(
                message: 'Clear search',
                child: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<ProductProvider>(context, listen: false)
                        .searchProducts('');
                    setState(() {});
                  },
                ),
              )
            : null,
      ),
      onChanged: (value) {
        Provider.of<ProductProvider>(context, listen: false).searchProducts(value);
        setState(() {});
      },
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Category:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
            final specialFilters = ['Low Stock', 'Expiring Soon'];
            final categories = [
              'All',
              ...specialFilters,
              ...categoryProvider.categories.map((c) => c.name)
            ];
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                        _applyFilters();
                      },
                      selectedColor: Theme.of(context).colorScheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  void _applyFilters() {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final searchText = _searchController.text.toLowerCase();

    if (_selectedCategory == 'Low Stock') {
      provider.setFilter(ProductFilterType.lowStock);
    } else if (_selectedCategory == 'Expiring Soon') {
      provider.setFilter(ProductFilterType.expiringSoon);
    } else {
      provider.setFilter(ProductFilterType.none);
    }

    if (searchText.isNotEmpty) {
      provider.searchProducts(searchText);
    }
  }

  int _getCategoryId(String categoryName) {
    if (categoryName == 'All') return 0;
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final category = categoryProvider.categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => Category(id: 0, name: ''),
    );
    return category.id;
  }

  Widget _buildProductsList(bool isAdmin) {
    return Consumer2<ProductProvider, SettingsProvider>(
      builder: (context, productProvider, settingsProvider, child) {
        if (productProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = productProvider.products;

        // Apply category filter on the UI side if backend doesn't support it
        final filteredProducts = _selectedCategory == 'All' ||
                _selectedCategory == 'Low Stock' ||
                _selectedCategory == 'Expiring Soon'
            ? products
            : products
                .where((p) => p.categoryId == _getCategoryId(_selectedCategory))
                .toList();

        if (filteredProducts.isEmpty) {
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
                  _selectedCategory == 'All'
                      ? 'No products found'
                      : 'No products in $_selectedCategory',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (_searchController.text.isNotEmpty)
                  Text(
                    'Try different search terms',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            final isExpiring = product.expiryDate != null &&
                product.expiryDate!.isBefore(DateTime.now()
                    .add(Duration(days: settingsProvider.expiryThreshold)));

            return FuturisticCard(
              padding: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price: ${product.price.toStringAsFixed(2)}/-'),
                    Text(
                      'Stock: ${product.stockQuantity} units',
                      style: TextStyle(
                        color: product.stockQuantity <= product.minStock
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (product.barcode?.isNotEmpty ?? false)
                      Text(
                        'Barcode: ${product.barcode}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    if (product.expiryDate != null)
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                              fontSize: 11,
                              color: isExpiring
                                  ? Colors.red.shade300
                                  : Colors.grey[600]),
                          children: [
                            const TextSpan(text: 'Expiry: '),
                            TextSpan(
                                text: DateFormat.yMMMd()
                                    .format(product.expiryDate!)),
                          ],
                        ),
                      ),
                  ],
                ),
                trailing: isAdmin
                    ? Tooltip(
                        message: 'More options',
                        child: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditProductDialog(product);
                            } else if (value == 'delete') {
                              _deleteProduct(context, product);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red, size: 20),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Icon(Icons.lock, color: Colors.grey),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => _ProductDialog(
        onSave: (product) async {
          final productProvider =
              Provider.of<ProductProvider>(context, listen: false);
          await productProvider.addProduct(product);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product added successfully')),
            );
          }
        },
      ),
    );
  }

  void _showEditProductDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => _ProductDialog(
        product: product,
        onSave: (updatedProduct) {
          final productProvider =
              Provider.of<ProductProvider>(context, listen: false);
          productProvider.updateProduct(updatedProduct);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product updated successfully')),
            );
          }
        },
      ),
    );
  }

  Future<void> _deleteProduct(BuildContext context, Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final provider = context.read<ProductProvider>();
      await provider.deleteProduct(product.id);

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                content: Text('Product "${product.name}" deleted'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () => provider.undoDelete(),
                ),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            )
            .closed
            .then((reason) {
          if (reason != SnackBarClosedReason.action) {
            provider.confirmDelete();
          }
        });
      }
    }
  }

  Future<void> _exportProductsToCSV() async {
    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final products = productProvider.products;

      if (products.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No products to export')),
          );
        }
        return;
      }

      print('📦 Exporting ${products.length} products...');

      final filePath = await ExportService.exportProductsToCSV(products);

      print('Export complete: $filePath');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported to path: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Export error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _ProductDialog extends StatefulWidget {
  final Product? product;
  final Function(Product product) onSave;

  const _ProductDialog({
    this.product,
    required this.onSave,
  });

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _costController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;
  late TextEditingController _barcodeController;
  late DateTime? _expiryDate;
  int _selectedCategoryId = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _costController =
        TextEditingController(text: widget.product?.cost.toString() ?? '');
    _stockController = TextEditingController(
        text: widget.product?.stockQuantity.toString() ?? '');
    _minStockController = TextEditingController(
        text: widget.product?.minStock.toString() ?? '');
    _barcodeController =
        TextEditingController(text: widget.product?.barcode ?? '');
    _expiryDate = widget.product?.expiryDate;

    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    if (widget.product != null) {
      _selectedCategoryId = widget.product!.categoryId ?? 1;
    } else if (categoryProvider.categories.isNotEmpty) {
      _selectedCategoryId = categoryProvider.categories.first.id;
    } else {
      _selectedCategoryId = -1; // Default to "Add new" if no categories exist
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price *',
                          border: OutlineInputBorder(),
                          suffixText: '/-',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _costController,
                        decoration: const InputDecoration(
                          labelText: 'Cost *',
                          border: OutlineInputBorder(),
                          suffixText: '/-',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Invalid number';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(
                          labelText: 'Stock Quantity *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _minStockController,
                        decoration: const InputDecoration(
                          labelText: 'Min Stock *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _barcodeController,
                  decoration: const InputDecoration(
                    labelText: 'Barcode',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Tooltip(
                  message: 'Select the product\'s expiry date',
                  child: ListTile(
                    title: Text(_expiryDate == null
                        ? 'Select Expiry Date'
                        : DateFormat.yMMMd().format(_expiryDate!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectExpiryDate(context),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: [
                    ...context.watch<CategoryProvider>().categories.map(
                          (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                        ),
                    const DropdownMenuItem<int>(
                      value: -1,
                      child: Text('+ Add new category'),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value == -1) {
                      final newId = await _showAddCategoryDialog(context);
                      if (newId != null) {
                        setState(() => _selectedCategoryId = newId);
                      }
                    } else if (value != null) {
                      setState(() => _selectedCategoryId = value);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(widget.product == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final product = Product(
        id: widget.product?.id ?? 0,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        cost: double.parse(_costController.text),
        stockQuantity: int.parse(_stockController.text),
        minStock: int.parse(_minStockController.text),
        barcode: _barcodeController.text.trim(),
        categoryId: _selectedCategoryId,
        expiryDate: _expiryDate,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSave(product);

      Navigator.pop(context);
    }
  }

  Future<int?> _showAddCategoryDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Category'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Category name *',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter category name';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final categoryProvider = ctx.read<CategoryProvider>();
                final category = Category(
                  id: 0,
                  name: nameController.text.trim(),
                );

                await categoryProvider.addCategory(category);

                if (ctx.mounted) {
                  final newId = categoryProvider.categories.last.id;
                  Navigator.pop(ctx, newId);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
