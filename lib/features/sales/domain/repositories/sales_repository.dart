import '../entities/sale.dart';

abstract class SalesRepository {
  Future<List<Sale>> getAllSales();
  Future<void> addSale(Sale sale);
}