import 'package:flutter/material.dart';

class DashboardStats {
  final double todaysSales;
  final int totalProducts;
  final int totalCustomers;
  final int lowStockCount;

  DashboardStats({
    required this.todaysSales,
    required this.totalProducts,
    required this.totalCustomers,
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
  bool _isLoading = false;
  DashboardStats? _dashboardStats;
  List<WeeklySalesData> _weeklySalesData = [];
  List<Transaction> _recentTransactions = [];

  bool get isLoading => _isLoading;
  DashboardStats? get dashboardStats => _dashboardStats;
  List<WeeklySalesData> get weeklySalesData => _weeklySalesData;
  List<Transaction> get recentTransactions => _recentTransactions;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    // Mock data
    _dashboardStats = DashboardStats(
      todaysSales: 1250.75,
      totalProducts: 47,
      totalCustomers: 23,
      lowStockCount: 3,
    );

    _weeklySalesData = [
      WeeklySalesData(date: '2025-10-08', revenue: 245.50, transactions: 8),
      WeeklySalesData(date: '2025-10-09', revenue: 180.25, transactions: 5),
      WeeklySalesData(date: '2025-10-10', revenue: 320.75, transactions: 12),
      WeeklySalesData(date: '2025-10-11', revenue: 290.40, transactions: 9),
      WeeklySalesData(date: '2025-10-12', revenue: 410.20, transactions: 15),
      WeeklySalesData(date: '2025-10-13', revenue: 195.30, transactions: 7),
      WeeklySalesData(date: '2025-10-14', revenue: 189.96, transactions: 6),
    ];

    _recentTransactions = [
      Transaction(
        id: 1,
        totalAmount: 89.99,
        paymentMethod: 'Card',
        status: 'Completed',
        createdAt: DateTime.now().subtract(Duration(hours: 1)),
      ),
      Transaction(
        id: 2,
        totalAmount: 45.50,
        paymentMethod: 'Cash',
        status: 'Completed',
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }
}
