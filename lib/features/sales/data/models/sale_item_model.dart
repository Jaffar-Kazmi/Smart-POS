import '../../domain/entities/sale_item.dart';

class SaleItemModel extends SaleItem {
  SaleItemModel({
    required super.id,
    required super.saleId,
    required super.productId,
    required super.quantity,
    required super.price,
    required super.subtotal,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      id: json['id'],
      saleId: json['sale_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      price: json['price']?.toDouble() ?? 0.0,
      subtotal: json['subtotal']?.toDouble() ?? 0.0,
    );
  }
}