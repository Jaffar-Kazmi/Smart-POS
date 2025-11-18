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
      version: 2,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Create users table with ALL columns including username
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )
''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS customers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    address TEXT,
    is_walk_in INTEGER DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )
''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS coupons (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT UNIQUE NOT NULL,
    discount_percent REAL NOT NULL,
    is_active INTEGER DEFAULT 1,
    expiry_date TEXT,
    created_at TEXT NOT NULL
  )
''');



    // Create other tables
    await db.execute(DatabaseTables.createCategoriesTable);
    await db.execute(DatabaseTables.createProductsTable);
    await db.execute(DatabaseTables.createCustomersTable);
    await db.execute(DatabaseTables.createSalesTable);
    await db.execute(DatabaseTables.createSaleItemsTable);
    await db.execute('''
  ALTER TABLE sales ADD COLUMN discount_percent REAL DEFAULT 0
''');

    await db.execute('''
  ALTER TABLE sales ADD COLUMN coupon_code TEXT
''');

    await db.execute('''
  ALTER TABLE sales ADD COLUMN customer_id INTEGER
''');

    // Insert initial/mock data
    await _insertMockData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2 && newVersion >= 2) {
      try {
        // Check if username column exists
        final info = await db.rawQuery("PRAGMA table_info(users)");
        final columnNames = info.map((col) => col['name']).toList();

        if (!columnNames.contains('username')) {
          print('Adding username column to users table...');

          // Add username column
          await db.execute('ALTER TABLE users ADD COLUMN username TEXT UNIQUE');

          // Get all existing users
          final users = await db.query('users');

          // Generate usernames from emails and update
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

          print('Migration completed successfully');
        }
      } catch (e) {
        print('Error during migration: $e');
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

  Category? getCategoryById(int id) async {
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

  Customer? getCustomerById(int id) async {
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

  Coupon? getCouponByCode(String code) async {
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

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

class Sale {
  final int id;
  final int userId;
  final double subtotal;
  final double discountPercent;  // NEW
  final String? couponCode;      // NEW
  final int? customerId;         // NEW
  final double total;
  final String paymentMethod;
  final String cashierName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Sale({
    required this.id,
    required this.userId,
    required this.subtotal,
    required this.total,
    required this.paymentMethod,
    required this.cashierName,
    this.discountPercent = 0.0,
    this.couponCode,
    this.customerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'subtotal': subtotal,
      'discount_percent': discountPercent,
      'coupon_code': couponCode,
      'customer_id': customerId,
      'total': total,
      'payment_method': paymentMethod,
      'cashier_name': cashierName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      subtotal: (map['subtotal'] as num).toDouble(),
      discountPercent: (map['discount_percent'] as num?)?.toDouble() ?? 0.0,
      couponCode: map['coupon_code'] as String?,
      customerId: map['customer_id'] as int?,
      total: (map['total'] as num).toDouble(),
      paymentMethod: map['payment_method'] as String,
      cashierName: map['cashier_name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
