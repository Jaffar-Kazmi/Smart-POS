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

    // Auto-print when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _printReceipt(context);
    });

    return Scaffold(
      body: Column(
        children: [
          const FuturisticHeader(title: 'Receipt'),
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
                        const Icon(Icons.check_circle_outline,
                            size: 64, color: Colors.green),
                        const SizedBox(height: 16),
                        const Text(
                          'Payment Successful',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Transaction ID: #${sale.id}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 16),
                        _buildInfoRow('Date', dateFormat.format(sale.createdAt)),
                        _buildInfoRow('Cashier', cashierName),
                        if (customer != null)
                          _buildInfoRow('Customer', customer!.name),
                        _buildInfoRow('Payment Method', sale.paymentMethod),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 16),
                        const Text(
                          'Items',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
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
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                  Text(
                                    '${item.total.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 16),
                        _buildInfoRow('Subtotal',
                            '${sale.subtotal.toStringAsFixed(2)}'),
                        if (sale.discountAmount > 0)
                          _buildInfoRow(
                            'Discount',
                            '-${sale.discountAmount.toStringAsFixed(2)}',
                            color: Colors.greenAccent,
                          ),
                        if (sale.taxAmount > 0)
                          _buildInfoRow(
                            'Tax', '${sale.taxAmount.toStringAsFixed(2)}'),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${sale.finalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
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

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(value,
              style: TextStyle(
                  color: color ?? Colors.white, fontWeight: FontWeight.w500)),
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
