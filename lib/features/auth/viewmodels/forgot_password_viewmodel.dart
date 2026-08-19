import '../repositories/auth_repository.dart';

class ForgotPasswordViewModel {
  AuthRepository? _repository;

  ForgotPasswordViewModel([this._repository]);

  AuthRepository get _authRepository => _repository ??= AuthRepository();

  String? validateEmail(String email) {
    if (email.trim().isEmpty) {
      return 'Informe seu e-mail.';
    }

    if (!email.contains('@') || !email.contains('.')) {
      return 'Digite um e-mail válido.';
    }

    return null;
  }

  Future<void> sendResetEmail(String email) async {
    await _authRepository.sendPasswordResetEmail(email: email.trim());
  }
}
