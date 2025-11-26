// lib/features/receipt/presentation/pages/receipt_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../sales/domain/entities/sale.dart';
import '../../../customers/domain/entities/customer.dart';

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
    required this.sale,
    required this.items,
    required this.cashierName,
    this.customer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final discountAmount = sale.subtotal * (sale.discountPercent / 100);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Receipt Header
            Center(
              child: Column(
                children: [
                  Text(
                    'SmartPOS',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Professional POS System',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),

            // Receipt Info
            _infoRow('Receipt #', sale.id.toString()),
            _infoRow(
              'Date',
              DateFormat('dd MMM yyyy, hh:mm a').format(sale.createdAt),
            ),
            _infoRow('Cashier', cashierName),
            _infoRow(
              'Customer',
              customer?.name ?? 'Walk-in Customer',
            ),
            if (customer?.phone != null) _infoRow('Phone', customer!.phone!),
            const Divider(),
            const SizedBox(height: 16),

            // Items Header
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Item',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Qty',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Price',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),

            // Items List
            ...items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${item.price.toStringAsFixed(2)}/-',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.quantity.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${item.total.toStringAsFixed(2)}/-',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 16),
            const Divider(thickness: 2),

            // Totals
            _totalRow(
              context,
              'Subtotal:',
              '${sale.subtotal.toStringAsFixed(2)}/-',
            ),
            if (sale.discountPercent > 0) ...[
              const SizedBox(height: 8),
              _totalRow(
              context,
                'Discount (${sale.discountPercent}%):',
                '-${discountAmount.toStringAsFixed(2)}/-',
                isDiscount: true,
              ),
            ],
            if (sale.couponCode != null && sale.couponCode!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _totalRow(
                context,
                'Coupon (${sale.couponCode}):',
                '-${discountAmount.toStringAsFixed(2)}/-', // This might need adjustment if coupon logic is different
                isDiscount: true,
              ),
            ],
            const SizedBox(height: 8),
            Divider(thickness: 2, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),

            // Total Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  '${sale.totalAmount.toStringAsFixed(2)}/-',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Thank you message
            Center(
              child: Column(
                children: [
                  Text(
                    'Thank you for your business!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Visit us again soon',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Print functionality coming soon'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Print'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _totalRow(
      BuildContext context,
      String label,
      String value, {
        bool isDiscount = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDiscount ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }
}
