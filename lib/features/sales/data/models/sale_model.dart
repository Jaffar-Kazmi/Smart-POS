import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';
import 'sale_item_model.dart';

class SaleModel extends Sale {
  SaleModel({
    required super.id,
    super.customerId,
    required super.userId,
    required super.totalAmount,
    required super.discountAmount,
    required super.taxAmount,
    required super.paymentMethod,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.items,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json, List<Map<String, dynamic>> itemsJson) {
    // Convert SaleItemModel list to SaleItem list
    final List<SaleItem> saleItems = itemsJson
        .map((item) => SaleItemModel.fromJson(item))
        .cast<SaleItem>()
        .toList();

    return SaleModel(
      id: json['id'],
      customerId: json['customer_id'],
      userId: json['user_id'],
      totalAmount: json['total_amount']?.toDouble() ?? 0.0,
      discountAmount: json['discount_amount']?.toDouble() ?? 0.0,
      taxAmount: json['tax_amount']?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      items: saleItems,
    );
  }
}
