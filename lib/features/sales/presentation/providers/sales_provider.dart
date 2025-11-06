
import 'package:flutter/material.dart';
import 'package:pos_app/features/products/presentation/providers/product_provider.dart';
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
  final ProductProvider _productProvider;

  List<Sale> _sales = [];
  List<CartItem> _cart = [];
  Customer? _selectedCustomer;
  double _discountAmount = 0;
  String _paymentMethod = 'Cash';
  bool _isLoading = false;
  String? _error;

  SalesProvider(this._productProvider);

  List<Sale> get sales => _sales;
  List<CartItem> get cart => _cart;
  Customer? get selectedCustomer => _selectedCustomer;
  double get discountAmount => _discountAmount;
  String get paymentMethod => _paymentMethod;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get cartSubtotal => _cart.fold(0, (sum, item) => sum + item.subtotal);
  double get cartTotal => cartSubtotal - _discountAmount;

  int getCartItemQuantity(int productId) {
    try {
      return _cart.firstWhere((item) => item.product.id == productId).quantity;
    } catch (e) {
      return 0;
    }
  }

  void addToCart(Product product) {
    _error = null;

    final productInState = _productProvider.products.firstWhere((p) => p.id == product.id);
    final cartQuantity = getCartItemQuantity(product.id);

    if (cartQuantity >= productInState.stockQuantity) {
      _error = 'Cannot add more items than available in stock.';
      notifyListeners();
      return;
    }

    final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
    if (existingIndex != -1) {
      _cart[existingIndex].quantity++;
    } else {
      _cart.add(CartItem(product: productInState));
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
      final product = _cart[index].product;
      final productInState = _productProvider.products.firstWhere((p) => p.id == product.id);

      if (quantity > productInState.stockQuantity) {
        _error = 'Cannot set quantity higher than available stock.';
        notifyListeners();
        return;
      }

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

  void clearError() {
    _error = null;
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
      final List<SaleItem> saleItems = _cart.map((cartItem) => SaleItem(
        id: 0,
        saleId: 0,
        productId: cartItem.product.id,
        quantity: cartItem.quantity,
        price: cartItem.product.price,
        subtotal: cartItem.subtotal,
      )).toList();

      final sale = Sale(
        id: 0,
        customerId: _selectedCustomer?.id,
        userId: userId,
        totalAmount: cartTotal,
        discountAmount: _discountAmount,
        taxAmount: 0,
        paymentMethod: _paymentMethod,
        status: 'Completed',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: saleItems,
      );

      await _repository.addSale(sale);

      // Update product stock in the UI
      for (var item in sale.items) {
        final product = _productProvider.products.firstWhere((p) => p.id == item.productId);
        _productProvider.updateProductStock(item.productId, product.stockQuantity - item.quantity);
      }

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
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
