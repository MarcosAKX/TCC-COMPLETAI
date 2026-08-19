import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/auth_surface_card.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../viewmodels/forgot_password_viewmodel.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final ForgotPasswordViewModel _viewModel = ForgotPasswordViewModel();

  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  Future<void> _sendResetEmail() async {
    final errorMessage = _viewModel.validateEmail(_emailController.text);

    if (errorMessage != null) {
      _showMessage(errorMessage);
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      await _viewModel.sendResetEmail(_emailController.text);

      if (!mounted) return;

      _showMessage('E-mail de recuperação enviado com sucesso!');

      Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      _showMessage(_resetErrorMessage(error));
    } catch (_) {
      if (!mounted) return;

      _showMessage('Não foi possível enviar o e-mail. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _resetErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Digite um e-mail válido.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde um pouco e tente novamente.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      default:
        return 'Não foi possível enviar o e-mail de recuperação.';
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(title: const Text('Recuperar Senha')),

      body: ResponsiveContent(
        maxWidth: 440,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        scrollable: true,
        child: AuthSurfaceCard(
          child: Column(
            children: [
              const Icon(Icons.lock_reset, size: 52, color: AppTheme.primary),

              const SizedBox(height: 16),

              Text(
                'Esqueceu sua senha?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textLight,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Informe seu e-mail para receber o link de recuperação.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
              ),

              const SizedBox(height: 32),

              CustomTextField(
                label: 'E-mail',
                hint: 'E-mail',
                icon: Icons.email_outlined,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 28),

              CustomButton(
                key: const Key('auth-primary-action'),
                text: 'Enviar e-mail',
                isLoading: _isLoading,
                onPressed: _sendResetEmail,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
