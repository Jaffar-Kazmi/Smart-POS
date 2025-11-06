import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';

class UserManagementProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await DatabaseHelper.instance.getAllUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      final success = await DatabaseHelper.instance.deleteUser(userId);
      if (success) {
        await loadUsers();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
