import '../models/role.dart';

class AuthController {
  AuthController._();
  static final I = AuthController._();

  Role? role;

  /// Demo login: accepts any credentials. Replace with real auth.
  bool login(Role r) {
    role = r;
    return true;
  }

  void logout() => role = null;
}
