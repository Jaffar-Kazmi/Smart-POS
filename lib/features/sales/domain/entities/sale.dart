import 'sale_item.dart';

class Sale {
  final int id;
  final int? customerId;
  final int userId;
  final double totalAmount;
  final double discountAmount;
  final double taxAmount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SaleItem> items;

  final double discountPercent;
  final String? couponCode;

  Sale({
    required this.id,
    this.customerId,
    required this.userId,
    required this.totalAmount,
    required this.discountAmount,
    required this.taxAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    this.discountPercent = 0.0,
    this.couponCode,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  double get finalAmount => subtotal - discountAmount + taxAmount;
}
