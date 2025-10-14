import '../../domain/repositories/customer_repository.dart';
import '../../domain/entities/customer.dart';
import '../models/customer_model.dart';
import '../../../../core/database/database_helper.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  @override
  Future<List<Customer>> getAllCustomers() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('customers');

    return result.map((json) => CustomerModel.fromJson(json)).toList();
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    final db = await DatabaseHelper.instance.database;

    await db.insert('customers', {
      'name': customer.name,
      'email': customer.email,
      'phone': customer.phone,
      'address': customer.address,
      'loyalty_points': customer.loyaltyPoints,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
      'customers',
      {
        'name': customer.name,
        'email': customer.email,
        'phone': customer.phone,
        'address': customer.address,
        'loyalty_points': customer.loyaltyPoints,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  @override
  Future<void> deleteCustomer(int customerId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('customers', where: 'id = ?', whereArgs: [customerId]);
  }
}