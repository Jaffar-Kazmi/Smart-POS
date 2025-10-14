import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reports_provider.dart';
import '../../../../core/constants/app_colors.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportsProvider>(context, listen: false).loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
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
            Expanded(
              child: _buildReportsGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildReportCard(
          title: 'Sales Report',
          subtitle: 'Daily, weekly, and monthly sales',
          icon: Icons.trending_up,
          color: AppColors.primary,
          onTap: () => _showReport('Sales Report'),
        ),
        _buildReportCard(
          title: 'Product Performance',
          subtitle: 'Top selling products',
          icon: Icons.inventory,
          color: AppColors.success,
          onTap: () => _showReport('Product Performance'),
        ),
        _buildReportCard(
          title: 'Customer Analytics',
          subtitle: 'Customer insights and trends',
          icon: Icons.people,
          color: AppColors.secondary,
          onTap: () => _showReport('Customer Analytics'),
        ),
        _buildReportCard(
          title: 'Inventory Report',
          subtitle: 'Stock levels and alerts',
          icon: Icons.warehouse,
          color: AppColors.warning,
          onTap: () => _showReport('Inventory Report'),
        ),
      ],
    );
  }

  Widget _buildReportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReport(String reportType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(reportType),
        content: Text('$reportType functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Export PDF'),
          ),
        ],
      ),
    );
  }
}