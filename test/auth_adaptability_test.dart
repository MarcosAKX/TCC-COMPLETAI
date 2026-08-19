import 'package:completai_app/core/theme/app_theme.dart';
import 'package:completai_app/features/auth/views/forgot_password_page.dart';
import 'package:completai_app/features/auth/views/login_page.dart';
import 'package:completai_app/features/auth/views/register_type_page.dart';
import 'package:completai_app/features/auth/views/register_user_page.dart';
import 'package:completai_app/features/gas_station/views/register_station_step_one_page.dart';
import 'package:completai_app/features/gas_station/views/register_station_step_two_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/adaptive_test_harness.dart';

const keyboardScenario = AdaptiveTestScenario(
  name: '360x800 com teclado',
  size: Size(360, 800),
  textScaleFactor: 1,
  viewInsets: EdgeInsets.only(bottom: 300),
);

void main() {
  for (final scenario in [
    adaptiveSmallPhone,
    adaptiveLargeText,
    adaptiveLandscape,
  ]) {
    testWidgets('seleção de cadastro permanece rolável em ${scenario.name}', (
      tester,
    ) async {
      await pumpAdaptive(
        tester,
        MaterialApp(theme: AppTheme.darkTheme, home: const RegisterTypePage()),
        scenario,
      );

      await tester.dragUntilVisible(
        find.text('Fazer login'),
        find.byType(Scrollable),
        const Offset(0, -200),
      );

      expect(find.text('Fazer login'), findsOneWidget);
      expectNoLayoutExceptions(tester);
    });
  }

  testWidgets('login mantém ação acessível com teclado', (tester) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    addTearDown(emailController.dispose);
    addTearDown(passwordController.dispose);

    await pumpAdaptive(
      tester,
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: LoginContent(
            emailController: emailController,
            passwordController: passwordController,
            isLoading: false,
            onLogin: () {},
            onForgotPassword: () {},
            onCreateAccount: () {},
          ),
        ),
      ),
      keyboardScenario,
    );

    await tester.showKeyboard(find.byType(TextField).last);
    final action = find.byKey(const Key('auth-primary-action'));
    await Scrollable.ensureVisible(tester.element(action));
    await tester.pump();

    expect(action, findsOneWidget);
    expectNoLayoutExceptions(tester);
  });

  final formCases = <({String name, Widget widget})>[
    (name: 'recuperação de senha', widget: const ForgotPasswordPage()),
    (name: 'cadastro de usuário', widget: const RegisterUserPage()),
    (
      name: 'primeira etapa do posto',
      widget: const RegisterStationStepOnePage(),
    ),
    (
      name: 'segunda etapa do posto',
      widget: const RegisterStationStepTwoPage(
        name: 'Posto Avenida',
        cnpj: '12345678000199',
        phone: '17999999999',
        email: 'posto@example.com',
        password: '123456',
      ),
    ),
  ];

  for (final formCase in formCases) {
    testWidgets('${formCase.name} mantém ação acessível com teclado', (
      tester,
    ) async {
      await pumpAdaptive(
        tester,
        MaterialApp(theme: AppTheme.darkTheme, home: formCase.widget),
        keyboardScenario,
      );
      await tester.pump();

      await tester.showKeyboard(find.byType(TextField).last);
      final action = find.byKey(const Key('auth-primary-action'));
      await Scrollable.ensureVisible(tester.element(action));
      await tester.pump();

      expect(action, findsOneWidget);
      expectNoLayoutExceptions(tester);
    });
  }
}
