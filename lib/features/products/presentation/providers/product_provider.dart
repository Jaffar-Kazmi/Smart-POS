import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../data/repositories/product_repository_impl.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepositoryImpl _repository = ProductRepositoryImpl();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<Product> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Product> get lowStockProducts => _products.where((p) => p.isLowStock).toList();

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _repository.getAllProducts();
      _applyFilter();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void filterProductsByCategory(int? categoryId) {
    if (categoryId == null) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products.where((p) => p.categoryId == categoryId).toList();
    }
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (product.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (product.barcode?.contains(_searchQuery) ?? false);
      }).toList();
    }
  }

  Future<bool> addProduct(Product product) async {
    try {
      await _repository.addProduct(product);
      await loadProducts(); // Refresh the list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      await _repository.updateProduct(product);
      await loadProducts(); // Refresh the list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int productId) async {
    try {
      await _repository.deleteProduct(productId);
      await loadProducts(); // Refresh the list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // New method for real-time stock updates
  void updateProductStock(int productId, int newStock) {
    final productIndex = _products.indexWhere((p) => p.id == productId);
    if (productIndex != -1) {
      _products[productIndex] = _products[productIndex].copyWith(stockQuantity: newStock);
      _applyFilter();
      notifyListeners();
    }
  }
}
