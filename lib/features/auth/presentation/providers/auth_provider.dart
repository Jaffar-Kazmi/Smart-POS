import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../core/database/database_helper.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepositoryImpl _repository = AuthRepositoryImpl();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role.toLowerCase() == 'admin';
  bool get isCashier => _currentUser?.role.toLowerCase() == 'cashier';

  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userMap = await DatabaseHelper.instance.loginUser(identifier, password);

      if (userMap != null) {
        _currentUser = User(
          id: userMap['id'],
          email: userMap['email'],
          role: userMap['role'],
          name: userMap['name'],
          createdAt: DateTime.parse(userMap['created_at']),
          updatedAt: DateTime.parse(userMap['updated_at']),
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email/username or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String username,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool usernameExists = await DatabaseHelper.instance.usernameExists(username);
      if (usernameExists) {
        _error = 'Username already taken';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      bool emailExists = await DatabaseHelper.instance.emailExists(email);
      if (emailExists) {
        _error = 'Email already registered';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      bool success = await DatabaseHelper.instance.registerUser(
        name: name,
        email: email,
        username: username,
        password: password,
        role: role,
      );

      if (success) {
        _isLoading = false;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to register user';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<User> _allUsers = [];
  List<User> get allUsers => _allUsers;

  Future<void> loadAllUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final usersData = await DatabaseHelper.instance.getAllUsers();
      _allUsers = usersData.map((data) => User(
        id: data['id'],
        email: data['email'],
        role: data['role'],
        name: data['name'],
        username: data['username'] ?? '',
        createdAt: DateTime.parse(data['created_at']),
        updatedAt: DateTime.parse(data['updated_at']),
      )).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      final success = await DatabaseHelper.instance.deleteUser(id);
      if (success) {
        _allUsers.removeWhere((u) => u.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(User user, String? password) async {
    try {
      final Map<String, dynamic> values = {
        'name': user.name,
        'email': user.email,
        'username': user.username,
        'role': user.role,
      };
      if (password != null && password.isNotEmpty) {
        values['password'] = password;
      }

      final success = await DatabaseHelper.instance.updateUser(user.id, values);
      if (success) {
        final index = _allUsers.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _allUsers[index] = user;
          notifyListeners();
        }
        // Update current user if it's the same user
        if (_currentUser?.id == user.id) {
          _currentUser = user;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }
}
