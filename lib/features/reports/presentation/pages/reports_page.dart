import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../sales/presentation/providers/sales_provider.dart';
import '../../../customers/presentation/providers/customer_provider.dart';
import '../../../sales/domain/entities/sale.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/export_service.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _getStats();
    Provider.of<CustomerProvider>(context, listen: false).loadCustomers();
    Provider.of<SalesProvider>(context, listen: false).loadSales();
  }

  Future<Map<String, dynamic>> _getStats() async {
    final dbHelper = DatabaseHelper.instance;
    final todayRevenue = await dbHelper.getTodayRevenue();
    final weeklyRevenue = await dbHelper.getWeeklyRevenue();
    final monthlyRevenue = await dbHelper.getMonthlyRevenue();
    final customerCount = await dbHelper.getTotalCustomers();
    return {
      'todayRevenue': todayRevenue,
      'weeklyRevenue': weeklyRevenue,
      'monthlyRevenue': monthlyRevenue,
      'customerCount': customerCount,
    };
  }

  void _exportTodaysReport(SalesProvider salesProvider) {
    final todaySales = salesProvider.sales
        .where((s) => s.createdAt.day == DateTime.now().day)
        .toList();
    ExportService.exportDailyReportToCSV(todaySales).then((path) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to $path')),
      );
    });
  }

  void _exportWeeklyReport(SalesProvider salesProvider) {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final weeklySales =
        salesProvider.sales.where((s) => s.createdAt.isAfter(weekAgo)).toList();
    ExportService.exportWeeklyReportToCSV(weeklySales).then((path) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to $path')),
      );
    });
  }

  void _exportMonthlyReport(SalesProvider salesProvider) {
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    final monthlySales =
        salesProvider.sales.where((s) => s.createdAt.isAfter(monthAgo)).toList();
    ExportService.exportMonthlyReportToCSV(monthlySales).then((path) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to $path')),
      );
    });
  }

  void _exportCustomerReport(CustomerProvider customerProvider) {
    ExportService.exportCustomersToCSV(customerProvider.customers).then((path) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to $path')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final salesProvider = context.watch<SalesProvider>();
    final customerProvider = context.watch<CustomerProvider>();
    final List<Sale> sales = salesProvider.sales;
    final totalRevenue = sales.fold<double>(
      0,
      (sum, s) => sum + s.finalAmount,
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reports & Analytics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            FutureBuilder<Map<String, dynamic>>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching stats'));
                }
                final stats = snapshot.data!;
                return Column(
                  children: [
                    Row(
                      children: [
                        _ReportCard(
                          title: 'Total Revenue',
                          value: totalRevenue.toStringAsFixed(2),
                          onExport: () => _exportTodaysReport(salesProvider),
                        ),
                        const SizedBox(width: 16),
                        _ReportCard(
                          title: 'Total Orders',
                          value: sales.length.toString(),
                          onExport: () => _exportTodaysReport(salesProvider),
                        ),
                        const SizedBox(width: 16),
                        _ReportCard(
                          title: 'Today Revenue',
                          value: (stats['todayRevenue'] as double)
                              .toStringAsFixed(2),
                          onExport: () => _exportTodaysReport(salesProvider),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _ReportCard(
                          title: 'Weekly Revenue',
                          value: (stats['weeklyRevenue'] as double)
                              .toStringAsFixed(2),
                          onExport: () => _exportWeeklyReport(salesProvider),
                        ),
                        const SizedBox(width: 16),
                        _ReportCard(
                          title: 'Monthly Revenue',
                          value: (stats['monthlyRevenue'] as double)
                              .toStringAsFixed(2),
                          onExport: () => _exportMonthlyReport(salesProvider),
                        ),
                        const SizedBox(width: 16),
                        _ReportCard(
                          title: 'Total Customers',
                          value: stats['customerCount'].toString(),
                          onExport: () =>
                              _exportCustomerReport(customerProvider),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: sales.isEmpty
                  ? const Center(child: Text('No sales yet'))
                  : ListView.builder(
                      itemCount: sales.length,
                      itemBuilder: (context, index) {
                        final sale = sales[index];
                        return ListTile(
                          leading: const Icon(Icons.receipt_long),
                          title: Text(
                            'Sale #${sale.id} • ${sale.finalAmount.toStringAsFixed(2)}',
                          ),
                          subtitle: Text(
                            sale.createdAt.toString().split(' ')[0],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onExport;

  const _ReportCard(
      {required this.title, required this.value, required this.onExport});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title),
                  Tooltip(
                    message: 'Export to CSV',
                    child: IconButton(
                      icon: const Icon(Icons.file_upload),
                      onPressed: onExport,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
