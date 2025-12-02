import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reports_provider.dart';
import '../../../sales/presentation/providers/sales_provider.dart';
import '../../../customers/presentation/providers/customer_provider.dart';
import '../../../../core/services/export_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsProvider>().loadStats();
      context.read<SalesProvider>().loadSales();
      context.read<CustomerProvider>().loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final salesProvider = context.watch<SalesProvider>();
    final customerProvider = context.watch<CustomerProvider>();
    final stats = reportsProvider.stats;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            if (reportsProvider.isLoading || stats == null)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  Row(
                    children: [
                      _ReportCard(
                        title: 'Total Revenue',
                        value: stats.totalRevenue.toStringAsFixed(2),
                      ),
                      const SizedBox(width: 16),
                      _ReportCard(
                        title: 'Total Orders',
                        value: stats.totalOrders.toString(),
                      ),
                      const SizedBox(width: 16),
                      _ReportCard(
                        title: 'Today Revenue',
                        value: stats.todayRevenue.toStringAsFixed(2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _ReportCard(
                        title: 'Weekly Revenue',
                        value: stats.weeklyRevenue.toStringAsFixed(2),
                      ),
                      const SizedBox(width: 16),
                      _ReportCard(
                        title: 'Monthly Revenue',
                        value: stats.monthlyRevenue.toStringAsFixed(2),
                      ),
                      const SizedBox(width: 16),
                      _ReportCard(
                        title: 'Total Customers',
                        value: stats.totalCustomers.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 24),
            Expanded(
              child: salesProvider.sales.isEmpty
                  ? const Center(child: Text('No sales yet'))
                  : ListView.builder(
                      itemCount: salesProvider.sales.length,
                      itemBuilder: (context, index) {
                        final sale = salesProvider.sales[index];
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

  Widget _buildHeader(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final salesProvider = context.watch<SalesProvider>();
    final reportsProvider = context.watch<ReportsProvider>();
    final customerProvider = context.watch<CustomerProvider>();
    final stats = reportsProvider.stats;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Reports & Analytics',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 16),
        Chip(
          avatar: const Icon(Icons.person, size: 16),
          label: Text(authProvider.currentUser?.name ?? 'System Administrator'),
        ),
        const Spacer(),
        Tooltip(
          message: 'Export all data to CSV',
          child: OutlinedButton.icon(
            onPressed: () async {
              if (stats == null) return;
              final path = await ExportService.exportComprehensiveSalesReport(
                salesProvider.sales,
                stats,
                customerProvider,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('CSV exported successfully to: $path'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                    showCloseIcon: true,
                  ),
                );
              }
            },
            icon: const Icon(Icons.file_upload),
            label: const Text('Export Report'),
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.red),
          onPressed: () {
            authProvider.logout();
            Navigator.of(context).pushReplacementNamed('/login');
          },
          tooltip: 'Logout',
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;

  const _ReportCard(
      {required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
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
