class SaleItem {
  final int id;
  final int saleId;
  final int productId;
  final int quantity;
  final double price;
  final double subtotal;

  SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });
}