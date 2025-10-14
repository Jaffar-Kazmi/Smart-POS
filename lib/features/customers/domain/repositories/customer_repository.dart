import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getAllCustomers();
  Future<void> addCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<void> deleteCustomer(int customerId);
}