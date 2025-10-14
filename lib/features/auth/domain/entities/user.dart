class User {
  final int id;
  final String email;
  final String role;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isCashier => role.toLowerCase() == 'cashier';
}