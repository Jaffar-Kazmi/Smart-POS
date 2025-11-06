
import 'package:pos_app/features/customers/domain/entities/customer.dart';

class CustomerModel extends Customer {
  CustomerModel({
    required int id,
    required String name,
    String? email,
    String? phone,
    String? address,
    required int loyaltyPoints,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          name: name,
          email: email,
          phone: phone,
          address: address,
          loyaltyPoints: loyaltyPoints,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      loyaltyPoints: json['loyalty_points'],
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
