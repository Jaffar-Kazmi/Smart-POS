import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/presentation/widgets/futuristic_header.dart';
import '../../../../core/presentation/widgets/futuristic_card.dart';
import '../../../../core/presentation/widgets/futuristic_button.dart';
import '../providers/coupon_provider.dart';
import '../../domain/entities/coupon.dart';

class CouponsPage extends StatefulWidget {
  const CouponsPage({super.key});

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CouponProvider>().loadCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final couponProvider = context.watch<CouponProvider>();
    final coupons = couponProvider.coupons;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCouponDialog(context),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          const FuturisticHeader(
            title: 'Manage Coupons',
          ),
          Expanded(
            child: couponProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : coupons.isEmpty
                ? Center(
              child: Text(
                'No coupons found',
                style: TextStyle(color: textColor),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: coupons.length,
              itemBuilder: (context, index) {
                final coupon = coupons[index];
                final now = DateTime.now();
                final isExpired = now.isAfter(coupon.validUntil);
                final notStarted = now.isBefore(coupon.validFrom);

                return FuturisticCard(
                  padding: const EdgeInsets.all(16),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Icon(Icons.local_offer, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(
                      coupon.code,
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon.discountType == 'percentage'
                              ? '${coupon.discountValue}% OFF'
                              : '\$${coupon.discountValue} OFF',
                          style: TextStyle(color: textColor.withOpacity(0.7)),
                        ),
                        Text(
                          'Valid: ${coupon.validFrom.toString().split(' ')[0]} - ${coupon.validUntil.toString().split(' ')[0]}',
                          style: TextStyle(
                            color: isExpired
                                ? Colors.red
                                : (notStarted ? Colors.orange : textColor.withOpacity(0.5)),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: coupon.isActive,
                          onChanged: (value) {
                            context.read<CouponProvider>().updateCoupon(
                              coupon.copyWith(isActive: value),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, coupon),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  void _showCouponDialog(BuildContext context, {Coupon? coupon}) {
    showDialog(
      context: context,
      builder: (context) => _CouponDialog(coupon: coupon),
    );
  }

  void _confirmDelete(BuildContext context, Coupon coupon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Coupon'),
        content: Text('Are you sure you want to delete ${coupon.code}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<CouponProvider>().deleteCoupon(coupon.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coupon deleted successfully'), backgroundColor: Colors.green),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _CouponDialog extends StatefulWidget {
  final Coupon? coupon;

  const _CouponDialog({this.coupon});

  @override
  State<_CouponDialog> createState() => _CouponDialogState();
}

class _CouponDialogState extends State<_CouponDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _discountController;
  late TextEditingController _minPurchaseController;
  String _discountType = 'percentage';
  DateTime _validFrom = DateTime.now();
  DateTime _validUntil = DateTime.now().add(const Duration(days: 30));
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.coupon?.code ?? '');
    _discountController = TextEditingController(text: widget.coupon?.discountValue.toString() ?? '');
    _minPurchaseController = TextEditingController(text: widget.coupon?.minPurchase.toString() ?? '0');
    _discountType = widget.coupon?.discountType ?? 'percentage';
    _validFrom = widget.coupon?.validFrom ?? DateTime.now();
    _validUntil = widget.coupon?.validUntil ?? DateTime.now().add(const Duration(days: 30));
    _isActive = widget.coupon?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _discountController.dispose();
    _minPurchaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.coupon != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Coupon' : 'Add Coupon'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: 'Coupon Code'),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _discountType,
                  decoration: const InputDecoration(labelText: 'Discount Type'),
                  items: const [
                    DropdownMenuItem(value: 'percentage', child: Text('Percentage (%)')),
                    DropdownMenuItem(value: 'fixed', child: Text('Fixed Amount (\$)')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _discountType = value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _discountController,
                  decoration: InputDecoration(
                    labelText: _discountType == 'percentage' ? 'Percentage (%)' : 'Amount (\$)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    final num = double.tryParse(value!);
                    if (num == null || num <= 0) return 'Invalid number';
                    if (_discountType == 'percentage' && num > 100) return 'Max 100%';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _minPurchaseController,
                  decoration: const InputDecoration(labelText: 'Min Purchase Amount'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) return 'Invalid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Valid From'),
                  subtitle: Text(_validFrom.toString().split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final today = DateTime.now();
                    final startToday = DateTime(today.year, today.month, today.day);

                    final initial = _validFrom.isBefore(startToday) ? startToday : _validFrom;

                    final date = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: startToday, // aaj se pehle disable
                      lastDate: today.add(const Duration(days: 365 * 2)),
                      selectableDayPredicate: (day) {
                        final d = DateTime(day.year, day.month, day.day);
                        return !d.isBefore(startToday); // sirf aaj/future
                      },
                    );
                    if (date != null) setState(() => _validFrom = date);
                  },
                ),
                ListTile(
                  title: const Text('Valid Until'),
                  subtitle: Text(_validUntil.toString().split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final start = DateTime(
                      _validFrom.year,
                      _validFrom.month,
                      _validFrom.day,
                    );

                    final initial = _validUntil.isBefore(start) ? start : _validUntil;

                    final date = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: start, // from se pehle disable
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      selectableDayPredicate: (day) {
                        final d = DateTime(day.year, day.month, day.day);
                        return !d.isBefore(start);
                      },
                    );
                    if (date != null) setState(() => _validUntil = date);
                  },
                ),
                SwitchListTile(
                  title: const Text('Active'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),

              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveCoupon,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  Future<void> _saveCoupon() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final couponProvider = context.read<CouponProvider>();
      final coupon = Coupon(
        id: widget.coupon?.id ?? 0,
        code: _codeController.text.toUpperCase(),
        discountType: _discountType,
        discountValue: double.parse(_discountController.text),
        minPurchase: double.tryParse(_minPurchaseController.text) ?? 0,
        validFrom: _validFrom,
        validUntil: _validUntil,
        isActive: _isActive,
        createdAt: widget.coupon?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = widget.coupon == null
          ? await couponProvider.addCoupon(coupon)
          : await couponProvider.updateCoupon(coupon);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.coupon == null ? 'Coupon added successfully' : 'Coupon updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
