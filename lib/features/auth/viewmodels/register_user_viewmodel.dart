import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class RegisterUserViewModel {
  AuthRepository? _repository;

  RegisterUserViewModel([this._repository]);

  AuthRepository get _authRepository => _repository ??= AuthRepository();

  String? validateUserData({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        phone.trim().isEmpty ||
        password.trim().isEmpty) {
      return 'Preencha todos os campos.';
    }

    if (name.trim().length < 3) {
      return 'O nome deve ter pelo menos 3 caracteres.';
    }

    if (!email.contains('@') || !email.contains('.')) {
      return 'Digite um e-mail válido.';
    }

    if (phone.length < 10) {
      return 'Digite um celular válido.';
    }

    if (password.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }

    return null;
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final user = UserModel(
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      password: password.trim(),
    );

    await _authRepository.registerUser(user);
  }
}
