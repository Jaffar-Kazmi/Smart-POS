import 'package:flutter/foundation.dart' hide Category;
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/category.dart';

class CategoryProvider extends ChangeNotifier {
  final DatabaseHelper _db;
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  Category? _lastDeletedCategory;
  int? _newCategoryIdForProducts;
  bool _shouldDeleteProducts = false;

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
      final map = category.toMap();
      map.remove('id'); // Remove ID to allow auto-increment
      final id = await _db.insertCategory(map);
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

  Future<int> getProductCountForCategory(int categoryId) async {
    return await _db.getProductCountForCategory(categoryId);
  }

  Future<void> deleteCategory(int id, {int? newCategoryId, bool deleteProducts = false}) async {
    final categoryIndex = _categories.indexWhere((c) => c.id == id);
    if (categoryIndex == -1) return;

    _lastDeletedCategory = _categories[categoryIndex];
    _newCategoryIdForProducts = newCategoryId;
    _shouldDeleteProducts = deleteProducts;

    _categories.removeAt(categoryIndex);
    notifyListeners();
  }

  Future<void> confirmDelete() async {
    if (_lastDeletedCategory != null) {
      try {
        if (_shouldDeleteProducts) {
          await _db.deleteProductsByCategoryId(_lastDeletedCategory!.id);
        } else if (_newCategoryIdForProducts != null) {
          await _db.moveProductsToCategory(_lastDeletedCategory!.id, _newCategoryIdForProducts!);
        }
        await _db.deleteCategory(_lastDeletedCategory!.id);
        _lastDeletedCategory = null;
        _newCategoryIdForProducts = null;
        _shouldDeleteProducts = false;
      } catch (e) {
        _error = 'Error deleting category from DB: $e';
        print(_error);
        notifyListeners();
      }
    }
  }

  Future<void> undoDelete() async {
    if (_lastDeletedCategory != null) {
      _categories.add(_lastDeletedCategory!);
      _categories.sort((a, b) => a.name.compareTo(b.name));
      _lastDeletedCategory = null;
      _newCategoryIdForProducts = null;
      _shouldDeleteProducts = false;
      notifyListeners();
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
