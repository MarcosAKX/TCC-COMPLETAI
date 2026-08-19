import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../core/widgets/step_progress_header.dart';
import '../viewmodels/register_station_viewmodel.dart';
import 'register_station_step_two_page.dart';

class RegisterStationStepOnePage extends StatefulWidget {
  const RegisterStationStepOnePage({super.key});

  @override
  State<RegisterStationStepOnePage> createState() =>
      _RegisterStationStepOnePageState();
}

class _RegisterStationStepOnePageState
    extends State<RegisterStationStepOnePage> {
  final RegisterStationViewModel _viewModel = RegisterStationViewModel();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cnpjController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _goToStepTwo() {
    final errorMessage = _viewModel.validateStepOne(
      name: _nameController.text,
      cnpj: _cnpjController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterStationStepTwoPage(
          name: _nameController.text.trim(),
          cnpj: _cnpjController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cnpjController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Cadastro do Posto')),
      body: ResponsiveContent(
        maxWidth: 440,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        scrollable: true,
        child: Column(
          children: [
            const StepProgressHeader(currentStep: 1, totalSteps: 2),
            const SizedBox(height: 28),
            const Icon(
              Icons.local_gas_station,
              size: 52,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Dados do Posto',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Informe os dados básicos para criar a conta administrativa.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: 'Nome do posto',
              hint: 'Ex: Posto Avenida',
              icon: Icons.storefront_outlined,
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'CNPJ',
              hint: 'Digite apenas números',
              icon: Icons.badge_outlined,
              controller: _cnpjController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(14),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Telefone',
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
              label: 'E-mail administrativo',
              hint: 'E-mail',
              icon: Icons.email_outlined,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
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
              text: 'Próximo',
              onPressed: _goToStepTwo,
            ),
          ],
        ),
      ),
    );
  }
}
