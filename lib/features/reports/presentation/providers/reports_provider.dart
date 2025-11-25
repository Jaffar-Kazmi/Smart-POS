import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';

class ReportsProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper;

  ReportsProvider(this._dbHelper);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadReports() async {
    _isLoading = true;
    notifyListeners();

    // Simulate loading
    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  }
}