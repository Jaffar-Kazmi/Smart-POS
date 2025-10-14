import 'package:flutter/material.dart';
import '../../domain/entities/customer.dart';
import '../../data/repositories/customer_repository_impl.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerRepositoryImpl _repository = CustomerRepositoryImpl();

  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _error;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCustomers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _customers = await _repository.getAllCustomers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCustomer(Customer customer) async {
    try {
      await _repository.addCustomer(customer);
      await loadCustomers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCustomer(Customer customer) async {
    try {
      await _repository.updateCustomer(customer);
      await loadCustomers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCustomer(int customerId) async {
    try {
      await _repository.deleteCustomer(customerId);
      await loadCustomers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}