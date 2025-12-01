import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../features/products/domain/entities/product.dart';
import '../../features/sales/domain/entities/sale.dart';
import '../../features/customers/domain/entities/customer.dart';

class ExportService {
  /// Export products to CSV file with correct column mapping
  static Future<String> exportProductsToCSV(List<Product> products) async {
    try {
      // Create CSV data
      List<List<dynamic>> csvData = [];

      // Add headers
      csvData.add([
        'ID',
        'Product Name',
        'Description',
        'Price',
        'Cost',
        'Stock Quantity',
        'Min Stock',
        'Barcode',
        'Category ID',
        'Expiry Date',
        'Created At',
        'Updated At',
      ]);

      // Add product rows - MAKE SURE ORDER MATCHES HEADERS
      for (var product in products) {
        csvData.add([
          product.id.toString(), // ID
          product.name, // Product Name
          product.description, // Description
          product.price.toStringAsFixed(2), // Price
          product.cost.toStringAsFixed(2), // Cost
          product.stockQuantity.toString(), // Stock Quantity
          product.minStock.toString(), // Min Stock
          product.barcode, // Barcode
          product.categoryId.toString(), // Category ID
          product.expiryDate != null
              ? DateFormat.yMMMd().format(product.expiryDate!)
              : '',
          product.createdAt.toIso8601String(), // Created At
          product.updatedAt.toIso8601String(), // Updated At
        ]);
      }

      // Convert to CSV string
      String csvString = const ListToCsvConverter().convert(csvData);

      // Get download directory
      final directory = await getDownloadsDirectory();

      if (directory == null) {
        throw Exception('Downloads directory not found');
      }

      // Create file with timestamp
      final fileName =
          'products_${DateTime.now().toString().replaceAll(':', '-').split('.')[0]}.csv';
      final file = File('${directory.path}/$fileName');

      // Write CSV to file
      await file.writeAsString(csvString);

      print('CSV exported successfully to: ${file.path}');
      return file.path;
    } catch (e) {
      print('Error exporting CSV: $e');
      rethrow;
    }
  }

  static Future<String> exportDailyReportToCSV(List<Sale> sales) async {
    return _exportSalesReportToCSV(sales, 'daily_report');
  }

  static Future<String> exportWeeklyReportToCSV(List<Sale> sales) async {
    return _exportSalesReportToCSV(sales, 'weekly_report');
  }

  static Future<String> exportMonthlyReportToCSV(List<Sale> sales) async {
    return _exportSalesReportToCSV(sales, 'monthly_report');
  }

  static Future<String> _exportSalesReportToCSV(
      List<Sale> sales, String reportType) async {
    try {
      List<List<dynamic>> csvData = [];
      csvData.add([
        'Sale ID',
        'Final Amount',
        'Created At',
      ]);

      for (var sale in sales) {
        csvData.add([
          sale.id.toString(),
          sale.finalAmount.toStringAsFixed(2),
          DateFormat.yMMMd().format(sale.createdAt),
        ]);
      }

      String csvString = const ListToCsvConverter().convert(csvData);

      final directory = await getDownloadsDirectory();

      if (directory == null) {
        throw Exception('Downloads directory not found');
      }

      final fileName =
          '${reportType}_${DateTime.now().toString().replaceAll(':', '-').split('.')[0]}.csv';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(csvString);

      print('CSV exported successfully to: ${file.path}');
      return file.path;
    } catch (e) {
      print('Error exporting CSV: $e');
      rethrow;
    }
  }

  static Future<String> exportCustomersToCSV(List<Customer> customers) async {
    try {
      List<List<dynamic>> csvData = [];
      csvData.add([
        'Customer ID',
        'Name',
        'Email',
        'Phone',
      ]);

      for (var customer in customers) {
        csvData.add([
          customer.id.toString(),
          customer.name,
          customer.email,
          customer.phone,
        ]);
      }

      String csvString = const ListToCsvConverter().convert(csvData);

      final directory = await getDownloadsDirectory();

      if (directory == null) {
        throw Exception('Downloads directory not found');
      }

      final fileName =
          'customers_${DateTime.now().toString().replaceAll(':', '-').split('.')[0]}.csv';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(csvString);

      print('CSV exported successfully to: ${file.path}');
      return file.path;
    } catch (e) {
      print('Error exporting CSV: $e');
      rethrow;
    }
  }
}
