import 'package:completai_app/core/theme/app_theme.dart';
import 'package:completai_app/core/widgets/custom_button.dart';
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
  testWidgets('ação primária cresce para acomodar rótulo ampliado', (
    tester,
  ) async {
    await pumpAdaptive(
      tester,
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              child: CustomButton(text: 'Finalizar Cadastro', onPressed: () {}),
            ),
          ),
        ),
      ),
      adaptiveLargeText,
    );

    expectNoLayoutExceptions(tester);
    expect(tester.getSize(find.byType(CustomButton)).height, greaterThan(52));
  });

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

  final formCases =
      <({String name, Widget Function(WidgetTester tester) build})>[
        (
          name: 'login',
          build: (tester) {
            final emailController = TextEditingController();
            final passwordController = TextEditingController();
            addTearDown(emailController.dispose);
            addTearDown(passwordController.dispose);
            return Scaffold(
              body: LoginContent(
                emailController: emailController,
                passwordController: passwordController,
                isLoading: false,
                onLogin: () {},
                onForgotPassword: () {},
                onCreateAccount: () {},
              ),
            );
          },
        ),
        (
          name: 'recuperação de senha',
          build: (_) => const ForgotPasswordPage(),
        ),
        (name: 'cadastro de usuário', build: (_) => const RegisterUserPage()),
        (
          name: 'primeira etapa do posto',
          build: (_) => const RegisterStationStepOnePage(),
        ),
        (
          name: 'segunda etapa do posto',
          build: (_) => const RegisterStationStepTwoPage(
            name: 'Posto Avenida',
            cnpj: '12345678000199',
            phone: '17999999999',
            email: 'posto@example.com',
            password: '123456',
          ),
        ),
      ];

  for (final formCase in formCases) {
    for (final scenario in [
      adaptiveSmallPhone,
      adaptiveLargeText,
      adaptiveLandscape,
      keyboardScenario,
    ]) {
      testWidgets(
        '${formCase.name} mantém ação acessível em ${scenario.name}',
        (tester) async {
          await pumpAdaptive(
            tester,
            MaterialApp(
              theme: AppTheme.darkTheme,
              home: formCase.build(tester),
            ),
            scenario,
          );
          await tester.pump();

          if (scenario.viewInsets.bottom > 0) {
            await tester.showKeyboard(find.byType(TextField).last);
          }
          final action = find.byKey(const Key('auth-primary-action'));
          await Scrollable.ensureVisible(tester.element(action));
          await tester.pump();

          expect(action, findsOneWidget);
          expectNoLayoutExceptions(tester);
          if (scenario == adaptiveLargeText) {
            if (formCase.name == 'login') {
              expect(
                tester
                    .getSize(find.widgetWithText(OutlinedButton, 'Criar conta'))
                    .height,
                greaterThan(52),
              );
            }
            expect(tester.getSize(action).height, greaterThan(52));
          }
        },
      );
    }
  }
}
