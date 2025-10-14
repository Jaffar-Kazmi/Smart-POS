import '../../domain/repositories/sales_repository.dart';
import '../../domain/entities/sale.dart';
import '../models/sale_model.dart';
import '../../../../core/database/database_helper.dart';

class SalesRepositoryImpl implements SalesRepository {
  @override
  Future<List<Sale>> getAllSales() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('sales', orderBy: 'created_at DESC');

    List<Sale> sales = [];
    for (var saleJson in result) {
      // Get sale items for each sale
      final itemsResult = await db.query(
        'sale_items',
        where: 'sale_id = ?',
        whereArgs: [saleJson['id']],
      );

      final sale = SaleModel.fromJson(saleJson, itemsResult);
      sales.add(sale);
    }

    return sales;
  }

  @override
  Future<void> addSale(Sale sale) async {
    final db = await DatabaseHelper.instance.database;

    // Start transaction
    await db.transaction((txn) async {
      // Insert sale
      final saleId = await txn.insert('sales', {
        'customer_id': sale.customerId,
        'user_id': sale.userId,
        'total_amount': sale.totalAmount,
        'discount_amount': sale.discountAmount,
        'tax_amount': sale.taxAmount,
        'payment_method': sale.paymentMethod,
        'status': sale.status,
        'created_at': sale.createdAt.toIso8601String(),
        'updated_at': sale.updatedAt.toIso8601String(),
      });

      // Insert sale items
      for (var item in sale.items) {
        await txn.insert('sale_items', {
          'sale_id': saleId,
          'product_id': item.productId,
          'quantity': item.quantity,
          'price': item.price,
          'subtotal': item.subtotal,
        });

        // Update product stock
        await txn.rawUpdate(
          'UPDATE products SET stock_quantity = stock_quantity - ? WHERE id = ?',
          [item.quantity, item.productId],
        );
      }
    });
  }
}