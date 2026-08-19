import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../user/views/station_list_page.dart';
import '../viewmodels/register_user_viewmodel.dart';
import 'package:flutter/services.dart';

class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({super.key});

  @override
  State<RegisterUserPage> createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  final RegisterUserViewModel _viewModel = RegisterUserViewModel();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _registerUser() async {
    final errorMessage = _viewModel.validateUserData(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _viewModel.register(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso!')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(builder: (_) => const StationListPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_registrationErrorMessage(error))));
    } on FirebaseException catch (error) {
      debugPrint(
        'Falha no Firestore durante o cadastro: '
        '${error.code} - ${error.message}',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_firestoreErrorMessage(error))));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível criar a conta. Tente novamente.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _registrationErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'invalid-email':
        return 'Digite um e-mail válido.';
      case 'weak-password':
        return 'Escolha uma senha mais forte.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      default:
        return 'Não foi possível criar a conta.';
    }
  }

  String _firestoreErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'O Firestore recusou o cadastro. Publique as regras de segurança e tente novamente.';
      case 'not-found':
        return 'O banco Firestore ainda não foi criado no projeto Firebase.';
      case 'unavailable':
        return 'O Firestore está indisponível. Verifique sua conexão e tente novamente.';
      case 'failed-precondition':
        return 'O Firestore ainda não está configurado corretamente.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      default:
        return 'Não foi possível salvar o perfil no Firestore (${error.code}).';
    }
  }

  @override
  void dispose() {
    // Libera os controllers da memória quando a tela é fechada.
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(title: const Text('Cadastro - Usuário')),

      body: ResponsiveContent(
        maxWidth: 440,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        scrollable: true,
        child: Column(
          children: [
            const Icon(
              Icons.person_add_alt_1_rounded,
              size: 52,
              color: AppTheme.primary,
            ),

            const SizedBox(height: 16),

            Text(
              'Torne-se um Usuário',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Junte-se ao Completai! e economize agora.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
            ),

            const SizedBox(height: 32),

            CustomTextField(
              label: 'Nome completo',
              hint: 'Nome completo',
              icon: Icons.person_outline,
              controller: _nameController,
            ),

            const SizedBox(height: 16),

            CustomTextField(
              label: 'E-mail',
              hint: 'E-mail',
              icon: Icons.email_outlined,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            CustomTextField(
              label: 'Celular',
              hint: '(17)99999-9999',
              icon: Icons.phone_outlined,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
            ),

            const SizedBox(height: 16),

            CustomTextField(
              label: 'Senha',
              hint: '********',
              icon: Icons.lock_outline,
              controller: _passwordController,
              obscureText: true,
              enablePasswordToggle: true,
              autofillHints: const [AutofillHints.newPassword],
            ),

            const SizedBox(height: 28),

            CustomButton(
              key: const Key('auth-primary-action'),
              text: 'Criar Conta',
              isLoading: _isLoading,
              onPressed: _registerUser,
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Já possui uma conta? Fazer Login',
                style: TextStyle(color: AppTheme.primaryInteractive),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
