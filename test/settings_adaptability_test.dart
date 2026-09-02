import 'package:completai_app/core/theme/app_theme.dart';
import 'package:completai_app/features/user/views/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/adaptive_test_harness.dart';

void main() {
  for (final scenario in [
    adaptiveSmallPhone,
    adaptiveLargeText,
    adaptiveLandscape,
  ]) {
    testWidgets(
      'conta de posto oculta logout e mantém exclusão em ${scenario.name}',
      (tester) async {
        await pumpAdaptive(
          tester,
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: SettingsContent(
                showLogout: false,
                onEditProfile: () {},
                onLogout: () {},
                onDeleteAccount: () {},
              ),
            ),
          ),
          scenario,
        );

        final dangerZone = find.byKey(const Key('settings-danger-zone'));
        await tester.dragUntilVisible(
          dangerZone,
          find.byType(Scrollable),
          const Offset(0, -200),
        );

        expect(dangerZone, findsOneWidget);
        expect(find.text('Sessão'), findsNothing);
        expect(find.text('Sair da conta'), findsNothing);
        expect(find.text('Excluir conta'), findsOneWidget);
        expectNoLayoutExceptions(tester);
      },
    );

    testWidgets('usuário comum mantém logout em ${scenario.name}', (
      tester,
    ) async {
      await pumpAdaptive(
        tester,
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SettingsContent(
              showLogout: true,
              onEditProfile: () {},
              onLogout: () {},
              onDeleteAccount: () {},
            ),
          ),
        ),
        scenario,
      );

      final logout = find.text('Sair da conta');
      await tester.dragUntilVisible(
        logout,
        find.byType(Scrollable),
        const Offset(0, -200),
      );

      expect(logout, findsOneWidget);
      expect(find.text('Excluir conta'), findsOneWidget);
      expectNoLayoutExceptions(tester);
    });
  }
}
