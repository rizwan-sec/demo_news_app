import 'package:hive/hive.dart';
import '../../../core/errors/failure.dart';
import '../domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._box);

  final Box _box;
  static const _emailKey = 'user_email';

  @override
  String? getLoggedInEmail() => _box.get(_emailKey) as String?;

  @override
  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800)); // fake network delay
    if (password.length < 6) {
      throw const Failure('Password must be at least 6 characters.');
    }
    await _box.put(_emailKey, email);
  }

  @override
  Future<void> logout() => _box.delete(_emailKey);
}