import 'package:flutter/material.dart';
import '../../../products/presentation/providers/product_provider.dart';
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
  ProductProvider _productProvider;

  List<Sale> _sales = [];
  List<CartItem> _cart = [];
  Customer? _selectedCustomer;
  double _discountAmount = 0;
  double _discountPercent = 0;
  String? _couponCode;
  String _paymentMethod = 'Cash';
  bool _isLoading = false;
  String? _error;
  Sale? _lastSale;

  SalesProvider(this._productProvider);

  void update(ProductProvider productProvider) {
    _productProvider = productProvider;
    notifyListeners();
  }

  List<Sale> get sales => _sales;
  List<CartItem> get cart => _cart;
  Customer? get selectedCustomer => _selectedCustomer;
  double get discountAmount => _discountAmount;
  double get discountPercent => _discountPercent;
  String? get couponCode => _couponCode;
  String get paymentMethod => _paymentMethod;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Sale? get lastSale => _lastSale;

  double get cartSubtotal => _cart.fold(0, (sum, item) => sum + item.subtotal);
  double get cartTotal => cartSubtotal - _discountAmount;

  int getCartItemQuantity(int productId) {
    final index = _cart.indexWhere((item) => item.product.id == productId);
    return index >= 0 ? _cart[index].quantity : 0;
  }

  void addToCart(Product product) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    int currentQuantity = index >= 0 ? _cart[index].quantity : 0;

    if (currentQuantity + 1 > product.stockQuantity) {
      _error = 'Insufficient stock for ${product.name}. Available: ${product.stockQuantity}';
      notifyListeners();
      return;
    }

    if (index >= 0) {
      _cart[index].quantity++;
    } else {
      _cart.add(CartItem(product: product));
    }
    _error = null;
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _cart.remove(item);
    notifyListeners();
  }

  void updateCartItemQuantity(CartItem item, int quantity) {
    if (quantity <= 0) {
      removeFromCart(item);
    } else {
      if (quantity > item.product.stockQuantity) {
        _error = 'Insufficient stock for ${item.product.name}. Available: ${item.product.stockQuantity}';
        notifyListeners();
        return;
      }
      item.quantity = quantity;
      _error = null;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setSelectedCustomer(Customer? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _selectedCustomer = null;
    _discountAmount = 0;
    _discountPercent = 0;
    _couponCode = null;
    _paymentMethod = 'Cash';
    notifyListeners();
  }

  void setDiscountAmount(double amount) {
    _discountAmount = amount;
    notifyListeners();
  }

  void setDiscountPercent(double percent) {
    _discountPercent = percent;
    notifyListeners();
  }

  void setCouponCode(String? code) {
    _couponCode = code;
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
        discountPercent: _discountPercent,
        couponCode: _couponCode,
      );

      await _repository.addSale(sale);
      _lastSale = sale; // Store last sale

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
