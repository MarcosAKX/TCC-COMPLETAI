import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/adaptive_action_row.dart';
import '../../../../core/widgets/auth_surface_card.dart';
import '../../../../core/widgets/brand_hero_panel.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../user/views/station_list_page.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginViewModel _viewModel = LoginViewModel();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirectExistingSession();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final errorMessage = _viewModel.validateLogin(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (errorMessage != null) {
      _showMessage(errorMessage);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _viewModel.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showMessage(_loginErrorMessage(e));
      setState(() => _isLoading = false);
      return;
    } catch (_) {
      if (!mounted) return;
      _showMessage('Não foi possível entrar. Tente novamente.');
      setState(() => _isLoading = false);
      return;
    }

    try {
      final redirected = await _redirectUser();
      if (!mounted) return;

      if (!redirected) {
        _showMessage(
          'Seu perfil não foi encontrado. Entre em contato com o suporte.',
        );
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage(
        'Login realizado, mas não foi possível carregar seu perfil.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _redirectExistingSession() async {
    if (FirebaseAuth.instance.currentUser == null || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      await _redirectUser();
    } catch (_) {
      if (mounted) {
        _showMessage('Não foi possível restaurar sua sessão.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _redirectUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    final documents = await Future.wait([
      FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get(),
      FirebaseFirestore.instance
          .collection('gas_stations')
          .doc(currentUser.uid)
          .get(),
    ]);

    if (!mounted) return false;

    final userDoc = documents[0];
    final stationDoc = documents[1];

    if (stationDoc.exists && stationDoc.data()?['type'] == 'gas_station') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.stationDashboard,
        (route) => false,
      );
      return true;
    }

    if (userDoc.exists && userDoc.data()?['type'] == 'client') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(builder: (_) => const StationListPage()),
        (route) => false,
      );
      return true;
    }

    return false;
  }

  String _loginErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Digite um e-mail válido.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde um pouco e tente novamente.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      default:
        return 'E-mail ou senha inválidos.';
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.authBackground,
      body: LoginContent(
        emailController: _emailController,
        passwordController: _passwordController,
        isLoading: _isLoading,
        onLogin: _login,
        onForgotPassword: () =>
            Navigator.pushNamed(context, AppRoutes.forgotPassword),
        onCreateAccount: () =>
            Navigator.pushNamed(context, AppRoutes.registerType),
      ),
    );
  }
}

class LoginContent extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onCreateAccount;

  const LoginContent({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
    required this.onForgotPassword,
    required this.onCreateAccount,
  });

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final showHero = !keyboardOpen && constraints.maxHeight >= 680;

        return ResponsiveContent(
          maxWidth: 460,
          padding: EdgeInsets.fromLTRB(20, showHero ? 0 : 24, 20, 30),
          scrollable: true,
          child: Column(
            children: [
              if (showHero) ...[
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: disableAnimations ? 1 : 0, end: 1),
                  duration: disableAnimations
                      ? Duration.zero
                      : const Duration(milliseconds: 420),
                  builder: (context, value, _) =>
                      BrandHeroPanel(routeProgress: value),
                ),
                const SizedBox(height: 20),
              ],
              AuthSurfaceCard(
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Entre na sua conta',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 22),
                      CustomTextField(
                        label: 'E-mail',
                        hint: 'Seu e-mail',
                        icon: Icons.email_outlined,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Senha',
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        controller: passwordController,
                        obscureText: true,
                        enablePasswordToggle: true,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => onLogin(),
                      ),
                      const SizedBox(height: 24),
                      AdaptiveActionRow(
                        children: [
                          CustomButton(
                            key: const Key('auth-primary-action'),
                            text: 'Entrar',
                            isLoading: isLoading,
                            onPressed: onLogin,
                          ),
                          TextButton(
                            onPressed: onForgotPassword,
                            child: const Text('Esqueci minha senha'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Ainda não tem uma conta?',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: onCreateAccount,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Criar conta'),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Preços locais para decisões mais rápidas',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppTheme.textMuted),
              ),
            ],
          ),
        );
      },
    );
  }
}
