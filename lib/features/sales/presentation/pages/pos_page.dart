import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/presentation/widgets/futuristic_header.dart';
import '../../../../core/presentation/widgets/futuristic_card.dart';
import '../../../../core/presentation/widgets/futuristic_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../customers/presentation/providers/customer_provider.dart';
import '../../../coupons/presentation/providers/coupon_provider.dart';
import '../providers/sales_provider.dart';
import '../../../products/domain/entities/product.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../coupons/domain/entities/coupon.dart';
import 'receipt_page.dart';

class POSPage extends StatefulWidget {
  const POSPage({Key? key}) : super(key: key);

  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _barcodeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
      Provider.of<CustomerProvider>(context, listen: false).loadCustomers();
      Provider.of<CouponProvider>(context, listen: false).loadCoupons();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _barcodeController.dispose();
    _barcodeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const FuturisticHeader(title: 'POS Terminal'),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: 16),
                        Expanded(child: _buildProductsGrid()),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 400,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: _buildCartSection(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 200,
          child: TextField(
            controller: _barcodeController,
            focusNode: _barcodeFocusNode,
            decoration: const InputDecoration(
              hintText: 'Scan Barcode',
              prefixIcon: Icon(Icons.qr_code_scanner),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _scanBarcode(value);
                _barcodeController.clear();
                _barcodeFocusNode.requestFocus();
              }
            },
          ),
        ),
      ],
    );
  }

  void _scanBarcode(String barcode) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final product = productProvider.products.firstWhere(
      (p) => p.barcode == barcode,
      orElse: () => Product(
        id: -1,
        name: '',
        description: '',
        price: 0,
        cost: 0,
        stockQuantity: 0,
        minStock: 0,
        categoryId: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (product.id != -1) {
      Provider.of<SalesProvider>(context, listen: false).addToCart(product);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product not found')),
      );
    }
  }

  Widget _buildProductsGrid() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = provider.products.where((p) {
          final query = _searchController.text.toLowerCase();
          return p.name.toLowerCase().contains(query) ||
              (p.barcode?.contains(query) ?? false);
        }).toList();

        if (products.isEmpty) {
          return const Center(child: Text('No products found'));
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return GestureDetector(
              onTap: () => Provider.of<SalesProvider>(context, listen: false)
                  .addToCart(product),
              child: FuturisticCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.inventory_2,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.price.toStringAsFixed(2)}/-',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stock: ${product.stockQuantity}',
                      style: TextStyle(
                        fontSize: 12,
                        color: product.stockQuantity <= product.minStock
                            ? AppColors.error
                            : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCartSection() {
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Current Order',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: salesProvider.cart.isEmpty
                        ? null
                        : () => _showClearCartConfirmation(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: salesProvider.cart.isEmpty
                  ? const Center(
                      child: Text(
                        'Cart is empty',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: salesProvider.cart.length,
                      itemBuilder: (context, index) {
                        final item = salesProvider.cart[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: FuturisticCard(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '${item.product.price.toStringAsFixed(2)} x ${item.quantity}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                                      color: Colors.white70,
                                      onPressed: () => salesProvider.updateCartItemQuantity(
                                          item, item.quantity - 1),
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 20),
                                      color: Colors.white70,
                                      onPressed: () => salesProvider.updateCartItemQuantity(
                                          item, item.quantity + 1),
                                    ),
                                  ],
                                ),
                                Text(
                                  item.subtotal.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            _buildCartSummary(salesProvider),
          ],
        );
      },
    );
  }

  Widget _buildCartSummary(SalesProvider salesProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: Colors.white70)),
              Text(
                '${salesProvider.cartSubtotal.toStringAsFixed(2)}/-',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
            SizedBox(
            width: double.infinity,
            child: FuturisticButton(
              onPressed: salesProvider.cart.isEmpty
                  ? null
                  : () => _showCheckoutDialog(context),
              label: 'Checkout',
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to clear the cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<SalesProvider>(context, listen: false).clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _CheckoutDialog(),
    );
  }
}

class _CheckoutDialog extends StatefulWidget {
  const _CheckoutDialog({Key? key}) : super(key: key);

  @override
  State<_CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<_CheckoutDialog> {
  Customer? _selectedCustomer;
  Coupon? _appliedCoupon;
  String _paymentMethod = 'Cash';

  @override
  Widget build(BuildContext context) {
    final salesProvider = Provider.of<SalesProvider>(context);
    final subtotal = salesProvider.cartSubtotal;
    
    double discountAmount = 0;
    if (_appliedCoupon != null) {
      discountAmount = _appliedCoupon!.calculateDiscount(subtotal);
    }
    
    final total = subtotal - discountAmount;

    return AlertDialog(
      title: const Text('Checkout'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerSelection(),
              const SizedBox(height: 16),
              _buildCouponSection(),
              const SizedBox(height: 16),
              const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPaymentMethodChip('Cash'),
                  const SizedBox(width: 8),
                  _buildPaymentMethodChip('Card'),
                  const SizedBox(width: 8),
                  _buildPaymentMethodChip('Online'),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildSummaryRow('Subtotal', subtotal),
              if (discountAmount > 0)
                _buildSummaryRow(
                  'Discount (${_appliedCoupon?.code ?? ''})',
                  -discountAmount,
                  isDiscount: true,
                ),
              const SizedBox(height: 8),
              _buildSummaryRow('Total', total, isTotal: true),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FuturisticButton(
          onPressed: () => _completeSale(context, discountAmount),
          label: 'Complete Sale',
        ),
      ],
    );
  }

  Widget _buildCustomerSelection() {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, child) {
        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Customer>(
                value: _selectedCustomer,
                decoration: const InputDecoration(
                  labelText: 'Customer (Optional)',
                  prefixIcon: Icon(Icons.person),
                ),
                items: [
                  const DropdownMenuItem<Customer>(
                    value: null,
                    child: Text('Guest Customer'),
                  ),
                  ...customerProvider.customers.map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.name),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCustomer = value;
                    Provider.of<SalesProvider>(context, listen: false)
                        .setSelectedCustomer(value);
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _showAddCustomerDialog(context),
              icon: const Icon(Icons.person_add),
              tooltip: 'Add New Customer',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddCustomerDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    bool isWalkIn = false;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Name is required')),
                );
                return;
              }

              final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
              final newCustomer = Customer(
                id: 0,
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
                email: emailController.text.trim(),
                isWalkIn: isWalkIn,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              await customerProvider.addCustomer(newCustomer);
              
              // Refresh list and select the new customer
              if (mounted) {
                // The provider should have reloaded, but we need to find the new customer
                // Since we don't get the ID back directly from addCustomer in the current implementation,
                // we'll just pick the last one or search by name.
                // Ideally addCustomer should return the ID.
                // For now, let's assume it's the last one added.
                final updatedList = customerProvider.customers;
                if (updatedList.isNotEmpty) {
                   setState(() {
                    _selectedCustomer = updatedList.last;
                     Provider.of<SalesProvider>(context, listen: false)
                        .setSelectedCustomer(_selectedCustomer);
                   });
                }
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    return Consumer<CouponProvider>(
      builder: (context, couponProvider, child) {
        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Coupon>(
                value: _appliedCoupon,
                decoration: const InputDecoration(
                  labelText: 'Apply Coupon',
                  prefixIcon: Icon(Icons.local_offer),
                ),
                items: [
                  const DropdownMenuItem<Coupon>(
                    value: null,
                    child: Text('No Coupon'),
                  ),
                  ...couponProvider.validCoupons.map((c) {
                    final label = c.discountType == 'percentage'
                        ? '${c.code} (${c.discountValue}%)'
                        : '${c.code} (\$${c.discountValue})';
                    return DropdownMenuItem(
                      value: c,
                      child: Text(label),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _appliedCoupon = value;
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentMethodChip(String method) {
    final isSelected = _paymentMethod == method;
    return ChoiceChip(
      label: Text(method),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _paymentMethod = method;
            Provider.of<SalesProvider>(context, listen: false)
                .setPaymentMethod(method);
          });
        }
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount,
      {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
              color: isDiscount ? Colors.greenAccent : Colors.white,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)}/-',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
              color: isDiscount ? Colors.greenAccent : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeSale(BuildContext context, double discountAmount) async {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Capture items before they are cleared
    final cartItems = salesProvider.cart.map((item) => ReceiptItemDisplay(
      productName: item.product.name,
      quantity: item.quantity,
      price: item.product.price,
      total: item.subtotal,
    )).toList();

    salesProvider.setDiscountAmount(discountAmount);
    // Calculate approximate percent for backward compatibility or receipt display if needed
    // But for now we just set 0 or calculate it if needed. 
    // The ReceiptPage might expect discountPercent, so let's calculate it.
    final subtotal = salesProvider.cartSubtotal;
    final discountPercent = subtotal > 0 ? (discountAmount / subtotal) * 100 : 0.0;
    
    salesProvider.setDiscountPercent(discountPercent);
    salesProvider.setCouponCode(_appliedCoupon?.code);
    salesProvider.setSelectedCustomer(_selectedCustomer);
    salesProvider.setPaymentMethod(_paymentMethod);

    final success = await salesProvider.completeSale(
      authProvider.currentUser!.id,
    );

    if (success && mounted) {
      final completedSale = salesProvider.lastSale;
      
      Navigator.of(context).pop(); // Close dialog

      if (completedSale != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReceiptPage(
              sale: completedSale,
              items: cartItems,
              customer: _selectedCustomer,
              cashierName: authProvider.currentUser?.name ?? 'Unknown',
            ),
          ),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sale completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
