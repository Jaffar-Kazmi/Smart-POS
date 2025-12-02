import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/futuristic_header.dart';
import '../../../../core/presentation/widgets/futuristic_card.dart';
import '../../../../core/presentation/widgets/futuristic_button.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../domain/entities/sale.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReceiptItemDisplay {
  final String productName;
  final int quantity;
  final double price;
  final double total;

  ReceiptItemDisplay({
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
  });
}



class ReceiptPage extends StatelessWidget {
  final Sale sale;
  final List<ReceiptItemDisplay> items;
  final Customer? customer;
  final String cashierName;

  const ReceiptPage({
    Key? key,
    required this.sale,
    required this.items,
    this.customer,
    required this.cashierName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final theme = Theme.of(context);

    // Auto-print when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _printReceipt(context);
    });

    return Scaffold(
      body: Column(
        children: [
          const FuturisticHeader(title: 'Receipt', actions: []),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: FuturisticCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 64, color: theme.colorScheme.primary),
                        const SizedBox(height: 16),
                        Text(
                          'Payment Successful',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Transaction ID: #${sale.id}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        _buildInfoRow(context, 'Date', dateFormat.format(sale.createdAt)),
                        _buildInfoRow(context, 'Cashier', cashierName),
                        if (customer != null)
                          _buildInfoRow(context, 'Customer', customer!.name),
                        _buildInfoRow(context, 'Payment Method', sale.paymentMethod),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'Items',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.productName} x${item.quantity}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                  Text(
                                    '${item.total.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        _buildInfoRow(context, 'Subtotal',
                            '${sale.subtotal.toStringAsFixed(2)}'),
                        if (sale.discountAmount > 0)
                          _buildInfoRow(
                            context,
                            'Discount',
                            '-${sale.discountAmount.toStringAsFixed(2)}',
                            color: Colors.green,
                          ),
                        if (sale.taxAmount > 0)
                          _buildInfoRow(
                            context, 'Tax', '${sale.taxAmount.toStringAsFixed(2)}'),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '${sale.finalAmount.toStringAsFixed(2)}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        FuturisticButton(
                          onPressed: () => Navigator.pop(context),
                          label: 'Done',
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => _printReceipt(context),
                          child: const Text('Print Receipt'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {Color? color}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7))),
          Text(value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }

  Future<void> _printReceipt(BuildContext context) async {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        final doc = pw.Document();

        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.roll80,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Text('SmartPOS',
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Center(child: pw.Text('Receipt #${sale.id}')),
                  pw.Divider(),
                  pw.Text('Date: ${dateFormat.format(sale.createdAt)}'),
                  pw.Text('Cashier: $cashierName'),
                  if (customer != null) pw.Text('Customer: ${customer!.name}'),
                  pw.Text('Payment: ${sale.paymentMethod}'),
                  pw.Divider(),
                  pw.Text('Items:'),
                  ...items.map(
                    (item) => pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                            child: pw.Text(
                                '${item.productName} x${item.quantity}')),
                        pw.Text('${item.total.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Subtotal:'),
                      pw.Text('${sale.subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                  if (sale.discountAmount > 0)
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Discount:'),
                        pw.Text('-${sale.discountAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                  if (sale.taxAmount > 0)
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Tax:'),
                        pw.Text('${sale.taxAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('${sale.finalAmount.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Center(child: pw.Text('Thank you for shopping!')),
                ],
              );
            },
          ),
        );

        return doc.save();
      },
    );
  }
}
