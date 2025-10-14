import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';
import '../../../../core/database/database_helper.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<User?> login(String email, String password) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return UserModel.fromJson(result.first);
    }

    return null;
  }

  @override
  Future<void> logout() async {
    // Implement logout logic if needed
  }
}