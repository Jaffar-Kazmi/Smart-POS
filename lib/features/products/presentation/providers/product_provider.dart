import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

enum ProductFilterType {
  none,
  lowStock,
  expiringSoon,
}

class ProductProvider extends ChangeNotifier {
  final ProductRepositoryImpl _repository = ProductRepositoryImpl();
  SettingsProvider _settingsProvider;

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  ProductFilterType _filterType = ProductFilterType.none;

  Product? _lastDeletedProduct;

  ProductProvider(this._settingsProvider);

  void update(SettingsProvider settingsProvider) {
    _settingsProvider = settingsProvider;
    notifyListeners();
  }

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

  void setFilter(ProductFilterType filter) {
    _filterType = filter;
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
    List<Product> tempProducts = List.from(_products);

    if (_searchQuery.isNotEmpty) {
      tempProducts = tempProducts.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (product.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (product.barcode?.contains(_searchQuery) ?? false);
      }).toList();
    }

    if (_filterType == ProductFilterType.lowStock) {
      tempProducts = tempProducts.where((p) => p.isLowStock).toList();
    } else if (_filterType == ProductFilterType.expiringSoon) {
      final expiryThreshold = _settingsProvider.expiryThreshold;
      final thresholdDate = DateTime.now().add(Duration(days: expiryThreshold));
      tempProducts = tempProducts
          .where((p) =>
              p.expiryDate != null && p.expiryDate!.isBefore(thresholdDate))
          .toList();
    }

    _filteredProducts = tempProducts;
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

  Future<void> deleteProduct(int productId) async {
    final productIndex = _products.indexWhere((p) => p.id == productId);
    if (productIndex == -1) return;

    _lastDeletedProduct = _products[productIndex];
    _products.removeAt(productIndex);
    _applyFilter();
    notifyListeners();
  }

  Future<void> confirmDelete() async {
    if (_lastDeletedProduct != null) {
      try {
        await _repository.deleteProduct(_lastDeletedProduct!.id);
        _lastDeletedProduct = null;
      } catch (e) {
        _error = 'Error deleting product from DB: $e';
        print(_error);
        notifyListeners();
      }
    }
  }

  Future<void> undoDelete() async {
    if (_lastDeletedProduct != null) {
      _products.add(_lastDeletedProduct!);
      _products.sort((a, b) => a.name.compareTo(b.name));
      _applyFilter();
      _lastDeletedProduct = null;
      notifyListeners();
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
