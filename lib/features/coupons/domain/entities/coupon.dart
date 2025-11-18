// lib/features/coupons/domain/entities/coupon.dart

class Coupon {
  final int id;
  final String code;
  final double discountPercent;
  final bool isActive;
  final DateTime? expiryDate;
  final DateTime createdAt;

  Coupon({
    required this.id,
    required this.code,
    required this.discountPercent,
    this.isActive = true,
    this.expiryDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isValid {
    if (!isActive) return false;
    if (expiryDate == null) return true;
    return DateTime.now().isBefore(expiryDate!);
  }

  Coupon copyWith({
    int? id,
    String? code,
    double? discountPercent,
    bool? isActive,
    DateTime? expiryDate,
    DateTime? createdAt,
  }) {
    return Coupon(
      id: id ?? this.id,
      code: code ?? this.code,
      discountPercent: discountPercent ?? this.discountPercent,
      isActive: isActive ?? this.isActive,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'discount_percent': discountPercent,
      'is_active': isActive ? 1 : 0,
      'expiry_date': expiryDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Coupon.fromMap(Map<String, dynamic> map) {
    return Coupon(
      id: map['id'] as int,
      code: map['code'] as String,
      discountPercent: (map['discount_percent'] as num).toDouble(),
      isActive: (map['is_active'] as int?) == 1,
      expiryDate: map['expiry_date'] != null
          ? DateTime.parse(map['expiry_date'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  String toString() => 'Coupon(code: $code, discount: $discountPercent%, valid: $isValid)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Coupon &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              code == other.code;

  @override
  int get hashCode => id.hashCode ^ code.hashCode;
}
