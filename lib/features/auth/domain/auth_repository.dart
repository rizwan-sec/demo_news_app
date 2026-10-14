abstract class AuthRepository {
  String? getLoggedInEmail();
  Future<void> login(String email, String password);
  Future<void> logout();
}