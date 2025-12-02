import '../../domain/repositories/product_repository.dart';
import '../../domain/entities/product.dart';
import '../models/product_model.dart';
import '../../../../core/database/database_helper.dart';

class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<List<Product>> getAllProducts() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('products');

    return result.map((json) => ProductModel.fromMap(json)).toList();
  }

  @override
  Future<void> addProduct(Product product) async {
    final db = await DatabaseHelper.instance.database;

    await db.insert('products', {
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'cost': product.cost,
      'stock_quantity': product.stockQuantity,
      'min_stock': product.minStock,
      'category_id': product.categoryId,
      'barcode': product.barcode,
      'image_path': product.imagePath,
      'expiry_date': product.expiryDate?.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> updateProduct(Product product) async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
      'products',
      {
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'cost': product.cost,
        'stock_quantity': product.stockQuantity,
        'min_stock': product.minStock,
        'category_id': product.categoryId,
        'barcode': product.barcode,
        'image_path': product.imagePath,
        'expiry_date': product.expiryDate?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  @override
  Future<void> deleteProduct(int productId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('products', where: 'id = ?', whereArgs: [productId]);
  }
}
