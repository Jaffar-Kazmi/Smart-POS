// lib/features/categories/presentation/providers/category_provider.dart

import 'package:flutter/foundation.dart';

class CategoryProvider extends ChangeNotifier {
  final DatabaseHelper _db;
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  CategoryProvider(this._db);

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _db.getAllCategories();
      _error = null;
    } catch (e) {
      _error = 'Error loading categories: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCategory(Category category) async {
    try {
      final id = await _db.insertCategory(category.toMap());
      _categories.add(category.copyWith(id: id));
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error adding category: $e';
      print(_error);
      return false;
    }
  }

  Future<bool> updateCategory(Category category) async {
    try {
      await _db.updateCategory(category.toMap());
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Error updating category: $e';
      print(_error);
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      await _db.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error deleting category: $e';
      print(_error);
      return false;
    }
  }

  Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  String getCategoryName(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id).name;
    } catch (e) {
      return 'Unknown';
    }
  }
}
