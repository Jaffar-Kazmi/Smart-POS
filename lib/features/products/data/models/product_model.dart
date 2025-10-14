import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.name,
    super.description,
    required super.price,
    required super.cost,
    required super.stockQuantity,
    required super.minStock,
    super.categoryId,
    super.barcode,
    super.imagePath,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price']?.toDouble() ?? 0.0,
      cost: json['cost']?.toDouble() ?? 0.0,
      stockQuantity: json['stock_quantity'],
      minStock: json['min_stock'],
      categoryId: json['category_id'],
      barcode: json['barcode'],
      imagePath: json['image_path'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'cost': cost,
      'stock_quantity': stockQuantity,
      'min_stock': minStock,
      'category_id': categoryId,
      'barcode': barcode,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}