import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_tables.dart';
import '../../features/categories/domain/entities/category.dart';
import '../../features/customers/domain/entities/customer.dart';
import '../../features/coupons/domain/entities/coupon.dart';
import '../../features/sales/domain/entities/sale.dart';

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
    String path = join(await getDatabasesPath(), 'smartpos_v2.db');

    return await openDatabase(
      path,
      version: 6,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Create users table
    await db.execute(DatabaseTables.createUsersTable);
    await db.execute(DatabaseTables.createCategoriesTable);
    await db.execute(DatabaseTables.createProductsTable);
    await db.execute(DatabaseTables.createCustomersTable);
    await db.execute(DatabaseTables.createCouponsTable);
    await db.execute(DatabaseTables.createSalesTable);
    await db.execute(DatabaseTables.createSaleItemsTable);

    // Insert initial/mock data
    await _insertMockData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      try {
        // Check if username column exists in users table
        final userInfo = await db.rawQuery("PRAGMA table_info(users)");
        final userColumns = userInfo.map((col) => col['name']).toList();

        if (!userColumns.contains('username')) {
          print('Adding username column to users table...');
          await db.execute('ALTER TABLE users ADD COLUMN username TEXT UNIQUE');

          // Get all existing users and update usernames
          final users = await db.query('users');
          for (var user in users) {
            final email = user['email'] as String? ?? '';
            final username = email.split('@')[0].toLowerCase();
            try {
              await db.update(
                'users',
                {'username': username},
                where: 'id = ?',
                whereArgs: [user['id']],
              );
            } catch (e) {
              print('Error updating user: $e');
            }
          }
        }

        // Check for missing columns in sales table
        final salesInfo = await db.rawQuery("PRAGMA table_info(sales)");
        final salesColumns = salesInfo.map((col) => col['name']).toList();

        if (!salesColumns.contains('discount_percent')) {
          print('Adding discount_percent to sales table...');
          await db.execute('ALTER TABLE sales ADD COLUMN discount_percent REAL DEFAULT 0');
        }

        if (!salesColumns.contains('coupon_code')) {
          print('Adding coupon_code to sales table...');
          await db.execute('ALTER TABLE sales ADD COLUMN coupon_code TEXT');
        }
        
        // customer_id should already be there from v1, but check just in case
        if (!salesColumns.contains('customer_id')) {
           print('Adding customer_id to sales table...');
           await db.execute('ALTER TABLE sales ADD COLUMN customer_id INTEGER');
        }

        print('Migration to v3 completed successfully');
      } catch (e) {
        print('Error during migration to v3: $e');
      }
    }

    if (oldVersion < 4) {
      try {
        // Check if coupons table exists
        final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='coupons'");
        if (tables.isEmpty) {
          print('Creating coupons table...');
          await db.execute(DatabaseTables.createCouponsTable);
        }

        // Check for is_walk_in in customers table
        final customerInfo = await db.rawQuery("PRAGMA table_info(customers)");
        final customerColumns = customerInfo.map((col) => col['name']).toList();

        if (!customerColumns.contains('is_walk_in')) {
          print('Adding is_walk_in to customers table...');
          await db.execute('ALTER TABLE customers ADD COLUMN is_walk_in INTEGER DEFAULT 0');
        }

        // Check for expiry_date in coupons table
        final couponInfo = await db.rawQuery("PRAGMA table_info(coupons)");
        final couponColumns = couponInfo.map((col) => col['name']).toList();

        if (!couponColumns.contains('expiry_date')) {
          print('Adding expiry_date to coupons table...');
          await db.execute('ALTER TABLE coupons ADD COLUMN expiry_date TEXT');
        }

        print('Migration to v4 completed successfully');
      } catch (e) {
        print('Error during migration to v4: $e');
      }
    }

    if (oldVersion < 5) {
      try {
        // Ensure expiry_date column exists in coupons table
        final couponInfo = await db.rawQuery("PRAGMA table_info(coupons)");
        final couponColumns = couponInfo.map((col) => col['name']).toList();

        if (!couponColumns.contains('expiry_date')) {
          print('V5: Adding expiry_date to coupons table...');
          await db.execute('ALTER TABLE coupons ADD COLUMN expiry_date TEXT');
          print('V5: expiry_date column added successfully');
        }

        print('Migration to v5 completed successfully');
      } catch (e) {
        print('Error during migration to v5: $e');
      }
    }

    if (oldVersion < 6) {
      try {
        print('V6: Ensuring default users exist...');
        await _insertMockData(db);
        print('Migration to v6 completed successfully');
      } catch (e) {
        print('Error during migration to v6: $e');
      }
    }
  }

  Future<void> _insertMockData(Database db) async {
    try {
      final userCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM users')
      ) ?? 0;

      if (userCount == 0) {
        print('Inserting mock data...');

        await db.insert('users', {
          'email': 'admin@smartpos.com',
          'username': 'admin',
          'password': 'password',
          'role': 'Admin',
          'name': 'System Administrator',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        await db.insert('users', {
          'email': 'cashier@smartpos.com',
          'username': 'cashier',
          'password': 'password',
          'role': 'Cashier',
          'name': 'John Cashier',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        print('Mock data inserted successfully');
      }
    } catch (e) {
      print('Error inserting mock data: $e');
    }
  }

  Future<bool> emailExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  Future<bool> usernameExists(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String username,
    required String password,
    required String role,
  }) async {
    try {
      final db = await database;

      if (await emailExists(email) || await usernameExists(username)) {
        return false;
      }

      await db.insert('users', {
        'name': name,
        'email': email,
        'username': username,
        'password': password,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      print('User registered successfully: $username');
      return true;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    return await db.insert('categories', category);
  }

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final maps = await db.query('categories', orderBy: 'name ASC');
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<int> updateCategory(Map<String, dynamic> category) async {
    final db = await database;
    return await db.update(
      'categories',
      category,
      where: 'id = ?',
      whereArgs: [category['id']],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<Category?> getCategoryById(int id) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertCustomer(Map<String, dynamic> customer) async {
    final db = await database;
    return await db.insert('customers', customer);
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final maps = await db.query('customers', where: 'is_walk_in = 0', orderBy: 'name ASC');
    return maps.map((map) => Customer.fromMap(map)).toList();
  }

  Future<int> updateCustomer(Map<String, dynamic> customer) async {
    final db = await database;
    return await db.update(
      'customers',
      customer,
      where: 'id = ?',
      whereArgs: [customer['id']],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  Future<Customer?> getCustomerById(int id) async {
    final db = await database;
    final maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertCoupon(Map<String, dynamic> coupon) async {
    final db = await database;
    return await db.insert('coupons', coupon);
  }

  Future<List<Coupon>> getAllCoupons() async {
    final db = await database;
    final maps = await db.query('coupons', orderBy: 'code ASC');
    return maps.map((map) => Coupon.fromMap(map)).toList();
  }

  Future<int> updateCoupon(Map<String, dynamic> coupon) async {
    final db = await database;
    return await db.update(
      'coupons',
      coupon,
      where: 'id = ?',
      whereArgs: [coupon['id']],
    );
  }

  Future<int> deleteCoupon(int id) async {
    final db = await database;
    return await db.delete('coupons', where: 'id = ?', whereArgs: [id]);
  }

  Future<Coupon?> getCouponByCode(String code) async {
    final db = await database;
    final maps = await db.query(
      'coupons',
      where: 'code = ?',
      whereArgs: [code.toUpperCase()],
    );
    if (maps.isNotEmpty) {
      return Coupon.fromMap(maps.first);
    }
    return null;
  }

  Future<Map<String, dynamic>?> loginUser(String identifier, String password) async {
    try {
      final db = await database;

      final result = await db.query(
        'users',
        where: '(email = ? OR username = ?) AND password = ?',
        whereArgs: [identifier, identifier, password],
      );

      if (result.isNotEmpty) {
        print('User logged in successfully: $identifier');
        return result.first;
      }

      print('Invalid email/username or password');
      return null;
    } catch (e) {
      print('Error logging in user: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    try {
      final db = await database;
      final result = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final db = await database;
      return await db.query('users');
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  Future<bool> updateUser(int id, Map<String, dynamic> values) async {
    try {
      final db = await database;
      values['updated_at'] = DateTime.now().toIso8601String();

      final result = await db.update(
        'users',
        values,
        where: 'id = ?',
        whereArgs: [id],
      );

      return result > 0;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      final db = await database;
      final result = await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result > 0;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getSalesStats(DateTime start, DateTime end) async {
    final db = await database;
    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as count,
        SUM(total_amount) as total
      FROM sales 
      WHERE date BETWEEN ? AND ?
    ''', [startStr, endStr]);

    if (result.isNotEmpty) {
      return {
        'count': result.first['count'] ?? 0,
        'total': result.first['total'] ?? 0.0,
      };
    }
    return {'count': 0, 'total': 0.0};
  }

  Future<List<Map<String, dynamic>>> getTopSellingProducts(int limit) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        p.name,
        SUM(si.quantity) as total_quantity
      FROM sale_items si
      JOIN products p ON si.product_id = p.id
      GROUP BY p.id
      ORDER BY total_quantity DESC
      LIMIT ?
    ''', [limit]);
  }

  Future<List<Map<String, dynamic>>> getLowStockProducts(int limit) async {
    final db = await database;
    return await db.query(
      'products',
      where: 'stock_quantity <= min_stock',
      orderBy: 'stock_quantity ASC',
      limit: limit,
    );
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}




