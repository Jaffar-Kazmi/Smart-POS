
import 'package:pos_app/features/products/domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required int id,
    required String name,
    String? description,
    required double price,
    required double cost,
    required int stockQuantity,
    required int minStock,
    int? categoryId,
    String? barcode,
    String? imagePath,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          name: name,
          description: description,
          price: price,
          cost: cost,
          stockQuantity: stockQuantity,
          minStock: minStock,
          categoryId: categoryId,
          barcode: barcode,
          imagePath: imagePath,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      cost: json['cost'],
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

  @override
  ProductModel copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    double? cost,
    int? stockQuantity,
    int? minStock,
    int? categoryId,
    String? barcode,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStock: minStock ?? this.minStock,
      categoryId: categoryId ?? this.categoryId,
      barcode: barcode ?? this.barcode,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
