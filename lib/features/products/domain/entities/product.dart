class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double cost;
  final int stockQuantity;
  final int minStock;
  final int? categoryId;
  final String? barcode;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.cost,
    required this.stockQuantity,
    required this.minStock,
    this.categoryId,
    this.barcode,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLowStock => stockQuantity < 6;
  double get profit => price - cost;
  double get profitMargin => profit / price * 100;

  Product copyWith({
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
    return Product(
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