import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class ReportsStats {
  final double totalRevenue;
  final int totalOrders;
  final double todayRevenue;
  final double weeklyRevenue;
  final double monthlyRevenue;
  final int totalCustomers;
  final double totalCostOfGoods;
  final double grossProfit;

  ReportsStats({
    required this.totalRevenue,
    required this.totalOrders,
    required this.todayRevenue,
    required this.weeklyRevenue,
    required this.monthlyRevenue,
    required this.totalCustomers,
    required this.totalCostOfGoods,
    required this.grossProfit,
  });
}

class ReportsProvider extends ChangeNotifier {
  final DatabaseHelper _db;
  bool _isLoading = false;
  ReportsStats? _stats;

  ReportsProvider(this._db);

  bool get isLoading => _isLoading;
  ReportsStats? get stats => _stats;

  Future<void> loadStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await _db.database;

      final todayRevenue = await _db.getTodayRevenue();
      final weeklyRevenue = await _db.getWeeklyRevenue();
      final monthlyRevenue = await _db.getMonthlyRevenue();
      final totalCustomers = await _db.getTotalCustomers();
      
      final totalRevenueResult = await db.rawQuery('SELECT SUM(total_amount) as total FROM sales');
      final totalRevenue = (totalRevenueResult.first['total'] as num?)?.toDouble() ?? 0.0;

      final startDate = DateTime(2000).toIso8601String();
      final endDate = DateTime.now().add(const Duration(days: 365)).toIso8601String();
      final totalCostOfGoods = await _db.getTotalCostOfSales(startDate, endDate);
      final grossProfit = totalRevenue - totalCostOfGoods;
      
      final totalOrdersResult = await db.rawQuery('SELECT COUNT(*) as count FROM sales');
      final totalOrders = Sqflite.firstIntValue(totalOrdersResult) ?? 0;

      _stats = ReportsStats(
        todayRevenue: todayRevenue,
        weeklyRevenue: weeklyRevenue,
        monthlyRevenue: monthlyRevenue,
        totalCustomers: totalCustomers,
        totalRevenue: totalRevenue,
        totalOrders: totalOrders,
        totalCostOfGoods: totalCostOfGoods,
        grossProfit: grossProfit,
      );
    } catch (e) {
      print('Error loading report stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
