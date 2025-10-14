import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_tables.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'smartpos.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onOpen: _insertInitialData,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Create all tables
    await db.execute(DatabaseTables.createUsersTable);
    await db.execute(DatabaseTables.createCategoriesTable);
    await db.execute(DatabaseTables.createProductsTable);
    await db.execute(DatabaseTables.createCustomersTable);
    await db.execute(DatabaseTables.createSalesTable);
    await db.execute(DatabaseTables.createSaleItemsTable);
  }

  Future<void> _insertInitialData(Database db) async {
    // Check if data already exists
    final userCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM users')
    ) ?? 0;

    if (userCount == 0) {
      await _insertMockData(db);
    }
  }

  Future<void> _insertMockData(Database db) async {
    // Insert users
    await db.insert('users', {
      'email': 'admin@smartpos.com',
      'password': 'password',
      'role': 'Admin',
      'name': 'System Administrator',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    await db.insert('users', {
      'email': 'cashier@smartpos.com',
      'password': 'password',
      'role': 'Cashier',
      'name': 'John Cashier',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Insert categories
    List<Map<String, dynamic>> categories = [
      {'name': 'Electronics', 'description': 'Electronic devices and accessories'},
      {'name': 'Clothing', 'description': 'Apparel and fashion items'},
      {'name': 'Home & Garden', 'description': 'Home improvement and garden supplies'},
      {'name': 'Books', 'description': 'Books and educational materials'},
      {'name': 'Sports', 'description': 'Sports equipment and accessories'},
    ];

    for (var category in categories) {
      category['created_at'] = DateTime.now().toIso8601String();
      category['updated_at'] = DateTime.now().toIso8601String();
      await db.insert('categories', category);
    }

    // Insert products
    List<Map<String, dynamic>> products = [
      {
        'name': 'Wireless Bluetooth Headphones',
        'description': 'High-quality wireless headphones with noise cancellation',
        'price': 89.99,
        'cost': 45.00,
        'stock_quantity': 25,
        'min_stock': 5,
        'category_id': 1,
        'barcode': '1234567890123',
        'image_path': '/images/headphones.png',
      },
      {
        'name': 'Cotton T-Shirt',
        'description': 'Comfortable cotton t-shirt in various colors',
        'price': 19.99,
        'cost': 8.00,
        'stock_quantity': 50,
        'min_stock': 10,
        'category_id': 2,
        'barcode': '1234567890124',
        'image_path': '/images/tshirt.png',
      },
      {
        'name': 'LED Desk Lamp',
        'description': 'Adjustable LED desk lamp with USB charging',
        'price': 34.99,
        'cost': 18.00,
        'stock_quantity': 15,
        'min_stock': 3,
        'category_id': 3,
        'barcode': '1234567890125',
        'image_path': '/images/desklamp.png',
      },
      {
        'name': 'Programming Book - Flutter Development',
        'description': 'Complete guide to Flutter app development',
        'price': 49.99,
        'cost': 25.00,
        'stock_quantity': 12,
        'min_stock': 2,
        'category_id': 4,
        'barcode': '1234567890126',
        'image_path': '/images/book.png',
      },
      {
        'name': 'Yoga Mat',
        'description': 'Non-slip yoga mat with carrying strap',
        'price': 29.99,
        'cost': 15.00,
        'stock_quantity': 8,
        'min_stock': 3,
        'category_id': 5,
        'barcode': '1234567890127',
        'image_path': '/images/yogamat.png',
      },
    ];

    for (var product in products) {
      product['created_at'] = DateTime.now().toIso8601String();
      product['updated_at'] = DateTime.now().toIso8601String();
      await db.insert('products', product);
    }

    // Insert customers
    List<Map<String, dynamic>> customers = [
      {
        'name': 'Alice Johnson',
        'email': 'alice.johnson@email.com',
        'phone': '+1-555-0123',
        'address': '123 Main St, Anytown, ST 12345',
        'loyalty_points': 120,
      },
      {
        'name': 'Bob Smith',
        'email': 'bob.smith@email.com',
        'phone': '+1-555-0124',
        'address': '456 Oak Ave, Somewhere, ST 12346',
        'loyalty_points': 85,
      },
      {
        'name': 'Carol Davis',
        'email': 'carol.davis@email.com',
        'phone': '+1-555-0125',
        'address': '789 Pine Rd, Elsewhere, ST 12347',
        'loyalty_points': 200,
      },
    ];

    for (var customer in customers) {
      customer['created_at'] = DateTime.now().toIso8601String();
      customer['updated_at'] = DateTime.now().toIso8601String();
      await db.insert('customers', customer);
    }
  }
}