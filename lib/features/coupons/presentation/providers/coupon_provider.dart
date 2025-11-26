// lib/features/coupons/presentation/providers/coupon_provider.dart

import 'package:flutter/foundation.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/coupon.dart';

class CouponProvider extends ChangeNotifier {
  final DatabaseHelper _db;
  List<Coupon> _coupons = [];
  bool _isLoading = false;
  String? _error;

  CouponProvider(this._db);

  List<Coupon> get coupons => _coupons;
  List<Coupon> get validCoupons => _coupons.where((c) {
    final now = DateTime.now();
    return c.isActive &&
        !now.isBefore(c.validFrom) &&
        !now.isAfter(c.validUntil) &&
        (c.usageLimit == null || c.usedCount < c.usageLimit!);
  }).toList();

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCoupons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _coupons = await _db.getAllCoupons();
      _error = null;
    } catch (e) {
      _error = 'Error loading coupons: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCoupon(Coupon coupon) async {
    try {
      final id = await _db.insertCoupon(coupon.toMap());
      _coupons.add(coupon.copyWith(id: id));
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error adding coupon: $e';
      print(_error);
      return false;
    }
  }

  Future<bool> updateCoupon(Coupon coupon) async {
    try {
      await _db.updateCoupon(coupon.toMap());
      final index = _coupons.indexWhere((c) => c.id == coupon.id);
      if (index != -1) {
        _coupons[index] = coupon;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Error updating coupon: $e';
      print(_error);
      return false;
    }
  }

  Future<bool> deleteCoupon(int id) async {
    try {
      await _db.deleteCoupon(id);
      _coupons.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error deleting coupon: $e';
      print(_error);
      return false;
    }
  }

  Coupon? validateCoupon(String code) {
    try {
      final now = DateTime.now();
      final coupon = _coupons.firstWhere(
            (c) => c.code.toUpperCase() == code.toUpperCase() &&
            c.isActive &&
            now.isAfter(c.validFrom) &&
            now.isBefore(c.validUntil) &&
            (c.usageLimit == null || c.usedCount < c.usageLimit!),
      );
      return coupon;
    } catch (e) {
      _error = 'Coupon not found or expired';
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
