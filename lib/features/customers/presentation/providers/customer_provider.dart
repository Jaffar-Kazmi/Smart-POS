import 'package:flutter/foundation.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/customer.dart';

class CustomerProvider extends ChangeNotifier {
  final DatabaseHelper _db;
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _error;

  Customer? _lastDeletedCustomer;

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
      final map = customer.toMap();
      map.remove('id'); // Remove ID to allow auto-increment
      final id = await _db.insertCustomer(map);
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

  Future<void> deleteCustomer(int id) async {
    final customerIndex = _customers.indexWhere((c) => c.id == id);
    if (customerIndex == -1) return;

    _lastDeletedCustomer = _customers[customerIndex];
    _customers.removeAt(customerIndex);
    notifyListeners();
  }

  Future<void> confirmDelete() async {
    if (_lastDeletedCustomer != null) {
      try {
        await _db.deleteCustomer(_lastDeletedCustomer!.id);
        _lastDeletedCustomer = null;
      } catch (e) {
        _error = 'Error deleting customer from DB: $e';
        print(_error);
        notifyListeners();
      }
    }
  }

  Future<void> undoDelete() async {
    if (_lastDeletedCustomer != null) {
      _customers.add(_lastDeletedCustomer!);
      _customers.sort((a, b) => a.name.compareTo(b.name));
      _lastDeletedCustomer = null;
      notifyListeners();
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
