# Missing Entity and Repository Files

## features/sales/domain/entities/sale_item.dart

```dart
class SaleItem {
  final int id;
  final int saleId;
  final int productId;
  final int quantity;
  final double price;
  final double subtotal;

  SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });
}
```

## features/customers/domain/entities/customer.dart

```dart
class Customer {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final int loyaltyPoints;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    required this.loyaltyPoints,
    required this.createdAt,
    required this.updatedAt,
  });
}
```

## features/sales/data/repositories/sales_repository_impl.dart

```dart
import '../../domain/repositories/sales_repository.dart';
import '../../domain/entities/sale.dart';
import '../models/sale_model.dart';
import '../../../../core/database/database_helper.dart';

class SalesRepositoryImpl implements SalesRepository {
  @override
  Future<List<Sale>> getAllSales() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('sales', orderBy: 'created_at DESC');
    
    List<Sale> sales = [];
    for (var saleJson in result) {
      // Get sale items for each sale
      final itemsResult = await db.query(
        'sale_items',
        where: 'sale_id = ?',
        whereArgs: [saleJson['id']],
      );
      
      final sale = SaleModel.fromJson(saleJson, itemsResult);
      sales.add(sale);
    }
    
    return sales;
  }
  
  @override
  Future<void> addSale(Sale sale) async {
    final db = await DatabaseHelper.instance.database;
    
    // Start transaction
    await db.transaction((txn) async {
      // Insert sale
      final saleId = await txn.insert('sales', {
        'customer_id': sale.customerId,
        'user_id': sale.userId,
        'total_amount': sale.totalAmount,
        'discount_amount': sale.discountAmount,
        'tax_amount': sale.taxAmount,
        'payment_method': sale.paymentMethod,
        'status': sale.status,
        'created_at': sale.createdAt.toIso8601String(),
        'updated_at': sale.updatedAt.toIso8601String(),
      });
      
      // Insert sale items
      for (var item in sale.items) {
        await txn.insert('sale_items', {
          'sale_id': saleId,
          'product_id': item.productId,
          'quantity': item.quantity,
          'price': item.price,
          'subtotal': item.subtotal,
        });
        
        // Update product stock
        await txn.rawUpdate(
          'UPDATE products SET stock_quantity = stock_quantity - ? WHERE id = ?',
          [item.quantity, item.productId],
        );
      }
    });
  }
}
```

## features/sales/domain/repositories/sales_repository.dart

```dart
import '../entities/sale.dart';

abstract class SalesRepository {
  Future<List<Sale>> getAllSales();
  Future<void> addSale(Sale sale);
}
```

## features/sales/data/models/sale_model.dart

```dart
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';
import 'sale_item_model.dart';

class SaleModel extends Sale {
  SaleModel({
    required super.id,
    super.customerId,
    required super.userId,
    required super.totalAmount,
    required super.discountAmount,
    required super.taxAmount,
    required super.paymentMethod,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.items,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json, List<Map<String, dynamic>> itemsJson) {
    return SaleModel(
      id: json['id'],
      customerId: json['customer_id'],
      userId: json['user_id'],
      totalAmount: json['total_amount']?.toDouble() ?? 0.0,
      discountAmount: json['discount_amount']?.toDouble() ?? 0.0,
      taxAmount: json['tax_amount']?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      items: itemsJson.map((item) => SaleItemModel.fromJson(item)).toList(),
    );
  }
}
```

## features/sales/data/models/sale_item_model.dart

```dart
import '../../domain/entities/sale_item.dart';

class SaleItemModel extends SaleItem {
  SaleItemModel({
    required super.id,
    required super.saleId,
    required super.productId,
    required super.quantity,
    required super.price,
    required super.subtotal,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      id: json['id'],
      saleId: json['sale_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      price: json['price']?.toDouble() ?? 0.0,
      subtotal: json['subtotal']?.toDouble() ?? 0.0,
    );
  }
}
```

## features/products/domain/repositories/product_repository.dart

```dart
import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getAllProducts();
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(int productId);
}
```

## features/customers/data/models/customer_model.dart

```dart
import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  CustomerModel({
    required super.id,
    required super.name,
    super.email,
    super.phone,
    super.address,
    required super.loyaltyPoints,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      loyaltyPoints: json['loyalty_points'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'loyalty_points': loyaltyPoints,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
```

## features/customers/data/repositories/customer_repository_impl.dart

```dart
import '../../domain/repositories/customer_repository.dart';
import '../../domain/entities/customer.dart';
import '../models/customer_model.dart';
import '../../../../core/database/database_helper.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  @override
  Future<List<Customer>> getAllCustomers() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('customers');
    
    return result.map((json) => CustomerModel.fromJson(json)).toList();
  }
  
  @override
  Future<void> addCustomer(Customer customer) async {
    final db = await DatabaseHelper.instance.database;
    
    await db.insert('customers', {
      'name': customer.name,
      'email': customer.email,
      'phone': customer.phone,
      'address': customer.address,
      'loyalty_points': customer.loyaltyPoints,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
  
  @override
  Future<void> updateCustomer(Customer customer) async {
    final db = await DatabaseHelper.instance.database;
    
    await db.update(
      'customers',
      {
        'name': customer.name,
        'email': customer.email,
        'phone': customer.phone,
        'address': customer.address,
        'loyalty_points': customer.loyaltyPoints,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }
  
  @override
  Future<void> deleteCustomer(int customerId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('customers', where: 'id = ?', whereArgs: [customerId]);
  }
}
```

## features/customers/domain/repositories/customer_repository.dart

```dart
import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getAllCustomers();
  Future<void> addCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<void> deleteCustomer(int customerId);
}
```

=======================================================================

# Missing Page Files

## features/products/presentation/pages/products_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildProductsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          'Products & Inventory',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Consumer<ProductProvider>(
          builder: (context, provider, child) {
            final lowStockCount = provider.lowStockProducts.length;
            if (lowStockCount > 0) {
              return Chip(
                label: Text('$lowStockCount Low Stock'),
                backgroundColor: AppColors.warning.withOpacity(0.1),
                labelStyle: TextStyle(color: AppColors.warning),
                avatar: Icon(Icons.warning, size: 16, color: AppColors.warning),
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

  Widget _buildProductsList() {
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
                  child: Icon(
                    Icons.image,
                    color: Colors.grey[400],
                  ),
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.description != null)
                      Text(product.description!),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Stock: ${product.stockQuantity}',
                          style: TextStyle(
                            color: product.isLowStock 
                              ? AppColors.error 
                              : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
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
                ),
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
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: const Text('Add product functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${product.name}'),
        content: const Text('Edit product functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<ProductProvider>(context, listen: false)
                  .deleteProduct(product.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
```

## features/customers/presentation/pages/customers_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import '../../../../core/constants/app_colors.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({Key? key}) : super(key: key);

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerProvider>(context, listen: false).loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildCustomersList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomerDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildCustomersList() {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, child) {
        if (customerProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final customers = customerProvider.customers;
        if (customers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No customers found',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final customer = customers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    customer.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  customer.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (customer.email != null)
                      Text(customer.email!),
                    if (customer.phone != null)
                      Text(customer.phone!),
                    Text('Loyalty Points: ${customer.loyaltyPoints}'),
                  ],
                ),
                trailing: PopupMenuButton(
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
                      _showEditCustomerDialog(customer);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(customer);
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Customer'),
        content: const Text('Add customer functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCustomerDialog(customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${customer.name}'),
        content: const Text('Edit customer functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${customer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
```

## features/reports/presentation/pages/reports_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reports_provider.dart';
import '../../../../core/constants/app_colors.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportsProvider>(context, listen: false).loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reports & Analytics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _buildReportsGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildReportCard(
          title: 'Sales Report',
          subtitle: 'Daily, weekly, and monthly sales',
          icon: Icons.trending_up,
          color: AppColors.primary,
          onTap: () => _showReport('Sales Report'),
        ),
        _buildReportCard(
          title: 'Product Performance',
          subtitle: 'Top selling products',
          icon: Icons.inventory,
          color: AppColors.success,
          onTap: () => _showReport('Product Performance'),
        ),
        _buildReportCard(
          title: 'Customer Analytics',
          subtitle: 'Customer insights and trends',
          icon: Icons.people,
          color: AppColors.secondary,
          onTap: () => _showReport('Customer Analytics'),
        ),
        _buildReportCard(
          title: 'Inventory Report',
          subtitle: 'Stock levels and alerts',
          icon: Icons.warehouse,
          color: AppColors.warning,
          onTap: () => _showReport('Inventory Report'),
        ),
      ],
    );
  }

  Widget _buildReportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReport(String reportType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(reportType),
        content: Text('$reportType functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Export PDF'),
          ),
        ],
      ),
    );
  }
}
```

## Updated features/customers/presentation/providers/customer_provider.dart

```dart
import 'package:flutter/material.dart';
import '../../domain/entities/customer.dart';
import '../../data/repositories/customer_repository_impl.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerRepositoryImpl _repository = CustomerRepositoryImpl();
  
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _error;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCustomers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _customers = await _repository.getAllCustomers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCustomer(Customer customer) async {
    try {
      await _repository.addCustomer(customer);
      await loadCustomers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCustomer(Customer customer) async {
    try {
      await _repository.updateCustomer(customer);
      await loadCustomers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCustomer(int customerId) async {
    try {
      await _repository.deleteCustomer(customerId);
      await loadCustomers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
```

## Fixed main.dart (CardTheme issue)

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/database/database_helper.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/products/presentation/providers/product_provider.dart';
import 'features/sales/presentation/providers/sales_provider.dart';
import 'features/customers/presentation/providers/customer_provider.dart';
import 'features/reports/presentation/providers/reports_provider.dart';
import 'shared/navigation/app_router.dart';
import 'core/constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize sqflite for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // Desktop window configuration
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(1000, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      windowButtonVisibility: true,
      title: 'SmartPOS Desktop',
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  
  // Initialize database
  await DatabaseHelper.instance.database;
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
      ],
      child: MaterialApp.router(
        title: 'SmartPOS Desktop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
          cardTheme: CardThemeData(  // Fixed: Use CardThemeData instead of CardTheme
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ),
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
```

===========================================================================================

# Updated Sales Provider - Fixed Version

## features/sales/presentation/providers/sales_provider.dart

```dart
import 'package:flutter/material.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';
import '../../../products/domain/entities/product.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../data/repositories/sales_repository_impl.dart';

class CartItem {
  final Product product;
  int quantity;
  
  CartItem({required this.product, this.quantity = 1});
  
  double get subtotal => product.price * quantity;
}

class SalesProvider extends ChangeNotifier {
  final SalesRepositoryImpl _repository = SalesRepositoryImpl();
  
  List<Sale> _sales = [];
  List<CartItem> _cart = [];
  Customer? _selectedCustomer;
  double _discountAmount = 0;
  String _paymentMethod = 'Cash';
  bool _isLoading = false;
  String? _error;

  List<Sale> get sales => _sales;
  List<CartItem> get cart => _cart;
  Customer? get selectedCustomer => _selectedCustomer;
  double get discountAmount => _discountAmount;
  String get paymentMethod => _paymentMethod;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get cartSubtotal => _cart.fold(0, (sum, item) => sum + item.subtotal);
  double get cartTotal => cartSubtotal - _discountAmount;

  void addToCart(Product product) {
    final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex != -1) {
      _cart[existingIndex].quantity++;
    } else {
      _cart.add(CartItem(product: product));
    }
    
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _cart.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateCartItemQuantity(int productId, int quantity) {
    final index = _cart.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (quantity > 0) {
        _cart[index].quantity = quantity;
      } else {
        _cart.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    _selectedCustomer = null;
    _discountAmount = 0;
    _paymentMethod = 'Cash';
    notifyListeners();
  }

  void setSelectedCustomer(Customer? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  void setDiscountAmount(double amount) {
    _discountAmount = amount;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  Future<bool> completeSale(int userId) async {
    if (_cart.isEmpty) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create sale object
      final sale = Sale(
        id: 0, // Will be assigned by database
        customerId: _selectedCustomer?.id,
        userId: userId,
        totalAmount: cartTotal,
        discountAmount: _discountAmount,
        taxAmount: 0, // You can calculate tax here
        paymentMethod: _paymentMethod,
        status: 'Completed',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: _cart.map((cartItem) => SaleItem(
          id: 0,
          saleId: 0,
          productId: cartItem.product.id,
          quantity: cartItem.quantity,
          price: cartItem.product.price,
          subtotal: cartItem.subtotal,
        )).toList(),
      );

      await _repository.addSale(sale);
      clearCart();
      await loadSales();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadSales() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sales = await _repository.getAllSales();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
```