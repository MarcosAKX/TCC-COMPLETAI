import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _service = AuthService();

  Future<void> registerUser(UserModel user) async {
    await _service.registerUser(user);
  }

  Future<void> login({required String email, required String password}) async {
    await _service.login(email: email, password: password);
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _service.sendPasswordResetEmail(email: email);
  }
}
