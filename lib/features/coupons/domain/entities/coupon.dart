// lib/features/coupons/domain/entities/coupon.dart

class Coupon {
  final int id;
  final String code;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;
  final double minPurchase;
  final double? maxDiscount;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final int? usageLimit;
  final int usedCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Coupon({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minPurchase = 0,
    this.maxDiscount,
    required this.validFrom,
    required this.validUntil,
    this.isActive = true,
    this.usageLimit,
    this.usedCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate actual discount amount for a given purchase
  double calculateDiscount(double purchaseAmount) {
    if (!isActive || purchaseAmount < minPurchase) {
      return 0;
    }

    final now = DateTime.now();
    if (now.isBefore(validFrom) || now.isAfter(validUntil)) {
      return 0;
    }

    if (usageLimit != null && usedCount >= usageLimit!) {
      return 0;
    }

    double discount;
    if (discountType == 'percentage') {
      discount = purchaseAmount * (discountValue / 100);
    } else {
      discount = discountValue;
    }

    if (maxDiscount != null && discount > maxDiscount!) {
      discount = maxDiscount!;
    }

    return discount;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'discount_type': discountType,
      'discount_value': discountValue,
      'min_purchase': minPurchase,
      'max_discount': maxDiscount,
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'usage_limit': usageLimit,
      'used_count': usedCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Coupon.fromMap(Map<String, dynamic> map) {
    return Coupon(
      id: map['id'] as int,
      code: map['code'] as String,
      discountType: map['discount_type'] as String,
      discountValue: (map['discount_value'] as num).toDouble(),
      minPurchase: (map['min_purchase'] as num?)?.toDouble() ?? 0,
      maxDiscount: (map['max_discount'] as num?)?.toDouble(),
      validFrom: DateTime.parse(map['valid_from'] as String),
      validUntil: DateTime.parse(map['valid_until'] as String),
      isActive: (map['is_active'] as int) == 1,
      usageLimit: map['usage_limit'] as int?,
      usedCount: map['used_count'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Coupon copyWith({
    int? id,
    String? code,
    String? discountType,
    double? discountValue,
    double? minPurchase,
    double? maxDiscount,
    DateTime? validFrom,
    DateTime? validUntil,
    bool? isActive,
    int? usageLimit,
    int? usedCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Coupon(
      id: id ?? this.id,
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minPurchase: minPurchase ?? this.minPurchase,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      isActive: isActive ?? this.isActive,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
