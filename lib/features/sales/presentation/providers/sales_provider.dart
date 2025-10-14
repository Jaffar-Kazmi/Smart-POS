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
      // Create sale items list
      final List<SaleItem> saleItems = _cart.map((cartItem) => SaleItem(
        id: 0,
        saleId: 0,
        productId: cartItem.product.id,
        quantity: cartItem.quantity,
        price: cartItem.product.price,
        subtotal: cartItem.subtotal,
      )).toList();

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
        items: saleItems,
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