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

  bool get isLowStock => stockQuantity <= minStock;
  double get profit => price - cost;
  double get profitMargin => profit / price * 100;
}