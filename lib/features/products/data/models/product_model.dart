import '../../domain/entities/product.dart';

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
    DateTime? expiryDate,
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
          expiryDate: expiryDate,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: (map['price'] as num).toDouble(),
      cost: (map['cost'] as num).toDouble(),
      stockQuantity: map['stock_quantity'],
      minStock: map['min_stock'],
      categoryId: map['category_id'],
      barcode: map['barcode'],
      imagePath: map['image_path'],
      expiryDate: map['expiry_date'] == null
          ? null
          : DateTime.parse(map['expiry_date']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
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
      'expiry_date': expiryDate?.toIso8601String(),
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
    DateTime? expiryDate,
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
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
