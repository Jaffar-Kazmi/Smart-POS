class Customer {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final int loyaltyPoints;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    required this.loyaltyPoints,
    required this.createdAt,
    required this.updatedAt,
  });
}