// lib/features/customers/presentation/providers/customer_provider.dart

import 'package:flutter/foundation.dart';

class CustomerProvider extends ChangeNotifier {
  final DatabaseHelper _db;
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _error;

  CustomerProvider(this._db);

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCustomers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _customers = await _db.getAllCustomers();
      _error = null;
    } catch (e) {
      _error = 'Error loading customers: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCustomer(Customer customer) async {
    try {
      final id = await _db.insertCustomer(customer.toMap());
      _customers.add(customer.copyWith(id: id));
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error adding customer: $e';
      print(_error);
      return false;
    }
  }

  Future<bool> updateCustomer(Customer customer) async {
    try {
      await _db.updateCustomer(customer.toMap());
      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = customer;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Error updating customer: $e';
      print(_error);
      return false;
    }
  }

  Future<bool> deleteCustomer(int id) async {
    try {
      await _db.deleteCustomer(id);
      _customers.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error deleting customer: $e';
      print(_error);
      return false;
    }
  }

  Customer? getCustomerById(int? id) {
    if (id == null || id == 0) return Customer.walkIn();
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  String getCustomerName(int? id) {
    if (id == null || id == 0) return 'Walk-in Customer';
    try {
      return _customers.firstWhere((c) => c.id == id).name;
    } catch (e) {
      return 'Unknown';
    }
  }
}
