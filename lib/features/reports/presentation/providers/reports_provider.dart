import 'package:flutter/material.dart';

class ReportsProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> loadReports() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  }
}