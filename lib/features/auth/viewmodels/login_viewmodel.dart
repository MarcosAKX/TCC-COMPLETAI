import '../repositories/auth_repository.dart';

class LoginViewModel {
  AuthRepository? _repository;

  LoginViewModel([this._repository]);

  AuthRepository get _authRepository => _repository ??= AuthRepository();

  String? validateLogin({required String email, required String password}) {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return 'Preencha e-mail e senha.';
    }

    if (!email.contains('@') || !email.contains('.')) {
      return 'Digite um e-mail válido.';
    }

    if (password.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }

    return null;
  }

  Future<void> login({required String email, required String password}) async {
    await _authRepository.login(email: email.trim(), password: password.trim());
  }
}
