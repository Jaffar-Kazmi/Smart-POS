import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';

class SettingsProvider extends ChangeNotifier {
  final DatabaseHelper _db;
  int _expiryThreshold = 30;

  SettingsProvider(this._db) {
    _loadSettings();
  }

  int get expiryThreshold => _expiryThreshold;

  Future<void> _loadSettings() async {
    final db = await _db.database;
    final result = await db.query('settings', where: 'key = ?', whereArgs: ['expiry_threshold']);
    if (result.isNotEmpty) {
      _expiryThreshold = int.tryParse(result.first['value'] as String) ?? 30;
    }
    notifyListeners();
  }

  Future<void> updateExpiryThreshold(int days) async {
    _expiryThreshold = days;
    notifyListeners(); // Notify listeners immediately

    final db = await _db.database;
    await db.insert(
      'settings',
      {'key': 'expiry_threshold', 'value': days.toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
