import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class DashboardStats {
  final double todaysSales;
  final int totalProducts;
  final int expiringSoonCount;
  final int lowStockCount;

  DashboardStats({
    required this.todaysSales,
    required this.totalProducts,
    required this.expiringSoonCount,
    required this.lowStockCount,
  });

}

class WeeklySalesData {
  final String date;
  final double revenue;
  final int transactions;

  WeeklySalesData({
    required this.date,
    required this.revenue,
    required this.transactions,
  });
}

class Transaction {
  final int id;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });
}

class DashboardProvider extends ChangeNotifier {
  final DatabaseHelper _db;
  SettingsProvider _settingsProvider;
  bool _isLoading = false;
  DashboardStats? _dashboardStats;
  List<WeeklySalesData> _weeklySalesData = [];
  List<Transaction> _recentTransactions = [];

  DashboardProvider(this._db, this._settingsProvider);

  void update(SettingsProvider settingsProvider) {
    _settingsProvider = settingsProvider;
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  DashboardStats? get dashboardStats => _dashboardStats;
  List<WeeklySalesData> get weeklySalesData => _weeklySalesData;
  List<Transaction> get recentTransactions => _recentTransactions;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await _db.database;

      // 1. Get Today's Sales
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
      
      final todaySalesResult = await db.rawQuery('''
        SELECT SUM(total_amount) as total 
        FROM sales 
        WHERE created_at BETWEEN ? AND ?
      ''', [todayStart, todayEnd]);
      
      final todaysSales = (todaySalesResult.first['total'] as num?)?.toDouble() ?? 0.0;

      // 2. Get Total Products
      final productsResult = await db.rawQuery('SELECT COUNT(*) as count FROM products');
      final totalProducts = Sqflite.firstIntValue(productsResult) ?? 0;

      // 3. Get Expiring Soon Count
      final expiringSoonCount = await _db.getExpiringSoonCount(_settingsProvider.expiryThreshold);

      // 4. Get Low Stock Count
      final lowStockResult = await db.rawQuery('SELECT COUNT(*) as count FROM products WHERE stock_quantity <= min_stock');
      final lowStockCount = Sqflite.firstIntValue(lowStockResult) ?? 0;

      _dashboardStats = DashboardStats(
        todaysSales: todaysSales,
        totalProducts: totalProducts,
        expiringSoonCount: expiringSoonCount,
        lowStockCount: lowStockCount,
      );

      // 5. Get Weekly Sales Data (Last 7 days)
      _weeklySalesData = [];
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final start = DateTime(date.year, date.month, date.day).toIso8601String();
        final end = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();
        
        final dayResult = await db.rawQuery('''
          SELECT SUM(total_amount) as revenue, COUNT(*) as transactions 
          FROM sales 
          WHERE created_at BETWEEN ? AND ?
        ''', [start, end]);

        _weeklySalesData.add(WeeklySalesData(
          date: DateFormat('MM-dd').format(date),
          revenue: (dayResult.first['revenue'] as num?)?.toDouble() ?? 0.0,
          transactions: (dayResult.first['transactions'] as num?)?.toInt() ?? 0,
        ));
      }

      // 6. Get Recent Transactions
      final recentResult = await db.query(
        'sales',
        orderBy: 'created_at DESC',
        limit: 5,
      );

      _recentTransactions = recentResult.map((map) => Transaction(
        id: map['id'] as int,
        totalAmount: map['total_amount'] as double,
        paymentMethod: map['payment_method'] as String,
        status: map['status'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
      )).toList();

    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
