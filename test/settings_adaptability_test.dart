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
    testWidgets('zona de perigo permanece alcançável em ${scenario.name}', (
      tester,
    ) async {
      await pumpAdaptive(
        tester,
        MaterialApp(theme: AppTheme.darkTheme, home: const SettingsPage()),
        scenario,
      );

      final dangerZone = find.byKey(const Key('settings-danger-zone'));
      await tester.dragUntilVisible(
        dangerZone,
        find.byType(Scrollable),
        const Offset(0, -200),
      );

      expect(dangerZone, findsOneWidget);
      expectNoLayoutExceptions(tester);
    });
  }
}
