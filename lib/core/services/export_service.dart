import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/products/domain/entities/product.dart';

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
        'Created At',
        'Updated At',
      ]);

      // Add product rows - MAKE SURE ORDER MATCHES HEADERS
      for (var product in products) {
        csvData.add([
          product.id.toString(),                           // ID
          product.name,                                     // Product Name
          product.description,                             // Description
          product.price.toStringAsFixed(2),               // Price
          product.cost.toStringAsFixed(2),                // Cost
          product.stockQuantity.toString(),               // Stock Quantity
          product.minStock.toString(),                    // Min Stock
          product.barcode,                                // Barcode
          product.categoryId.toString(),                  // Category ID
          product.createdAt.toIso8601String(),           // Created At
          product.updatedAt.toIso8601String(),           // Updated At
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
      final fileName = 'products_${DateTime.now().toString().replaceAll(':', '-').split('.')[0]}.csv';
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

  /// Export products summary to CSV (simplified version)
  static Future<String> exportProductsSummaryToCSV(List<Product> products) async {
    try {
      List<List<dynamic>> csvData = [];

      // Add headers
      csvData.add([
        'Product Name',
        'Price',
        'Stock',
        'Min Stock',
        'Status',
      ]);

      // Add product rows
      for (var product in products) {
        final status = product.stockQuantity <= product.minStock ? 'Low Stock' : 'OK';
        csvData.add([
          product.name,                           // Product Name
          product.price.toStringAsFixed(2),      // Price
          product.stockQuantity.toString(),      // Stock
          product.minStock.toString(),           // Min Stock
          status,                                // Status
        ]);
      }

      String csvString = const ListToCsvConverter().convert(csvData);

      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception('Downloads directory not found');
      }

      final fileName = 'products_summary_${DateTime.now().toString().replaceAll(':', '-').split('.')[0]}.csv';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(csvString);

      print('Summary CSV exported to: ${file.path}');
      return file.path;

    } catch (e) {
      print('Error exporting summary CSV: $e');
      rethrow;
    }
  }

  /// Export detailed inventory report
  static Future<String> exportInventoryReportCSV(List<Product> products) async {
    try {
      List<List<dynamic>> csvData = [];

      // Add headers
      csvData.add([
        'SKU/ID',
        'Product',
        'Category',
        'Unit Price',
        'Unit Cost',
        'Current Stock',
        'Reorder Level',
        'Inventory Value',
        'Stock Status',
      ]);

      // Add product rows with calculations
      for (var product in products) {
        final inventoryValue = product.price * product.stockQuantity;
        final status = product.stockQuantity <= product.minStock
            ? 'CRITICAL'
            : product.stockQuantity <= (product.minStock * 1.5)
            ? 'LOW'
            : 'ADEQUATE';

        csvData.add([
          product.id.toString(),
          product.name,
          product.categoryId.toString(),
          product.price.toStringAsFixed(2),
          product.cost.toStringAsFixed(2),
          product.stockQuantity.toString(),
          product.minStock.toString(),
          inventoryValue.toStringAsFixed(2),
          status,
        ]);
      }

      String csvString = const ListToCsvConverter().convert(csvData);

      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception('Downloads directory not found');
      }

      final fileName = 'inventory_report_${DateTime.now().toString().replaceAll(':', '-').split('.')[0]}.csv';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(csvString);

      print('Inventory report exported to: ${file.path}');
      return file.path;

    } catch (e) {
      print('Error exporting inventory report: $e');
      rethrow;
    }
  }
}