import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  CustomerModel({
    required super.id,
    required super.name,
    super.email,
    super.phone,
    super.address,
    required super.loyaltyPoints,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      loyaltyPoints: json['loyalty_points'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'loyalty_points': loyaltyPoints,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}