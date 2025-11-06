
import 'package:pos_app/features/sales/domain/entities/sale.dart';
import 'package:pos_app/features/sales/domain/entities/sale_item.dart';
import 'sale_item_model.dart';

class SaleModel extends Sale {
  SaleModel({
    required int id,
    int? customerId,
    required int userId,
    required double totalAmount,
    required double discountAmount,
    required double taxAmount,
    required String paymentMethod,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<SaleItem> items,
  }) : super(
          id: id,
          customerId: customerId,
          userId: userId,
          totalAmount: totalAmount,
          discountAmount: discountAmount,
          taxAmount: taxAmount,
          paymentMethod: paymentMethod,
          status: status,
          createdAt: createdAt,
          updatedAt: updatedAt,
          items: items,
        );

  factory SaleModel.fromJson(Map<String, dynamic> json, List<Map<String, dynamic>> itemsJson) {
    return SaleModel(
      id: json['id'],
      customerId: json['customer_id'],
      userId: json['user_id'],
      totalAmount: json['total_amount'],
      discountAmount: json['discount_amount'],
      taxAmount: json['tax_amount'],
      paymentMethod: json['payment_method'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      items: itemsJson.map((item) => SaleItemModel.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'user_id': userId,
      'total_amount': totalAmount,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
