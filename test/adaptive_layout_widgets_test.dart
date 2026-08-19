import 'package:completai_app/core/widgets/adaptive_action_row.dart';
import 'package:completai_app/core/widgets/adaptive_layout.dart';
import 'package:completai_app/core/widgets/responsive_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/adaptive_test_harness.dart';

void main() {
  testWidgets('responsive content caps its width and scrolls to final child', (
    tester,
  ) async {
    await pumpAdaptive(
      tester,
      MaterialApp(
        home: Scaffold(
          body: ResponsiveContent(
            maxWidth: 440,
            scrollable: true,
            child: const Column(
              children: [
                SizedBox(height: 700),
                SizedBox(key: Key('responsive-content-final'), height: 48),
              ],
            ),
          ),
        ),
      ),
      adaptiveLandscape,
    );

    expect(
      tester.getSize(find.byKey(const Key('responsive-content-frame'))).width,
      440,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('responsive-content-final')),
      200,
    );
    expect(find.byKey(const Key('responsive-content-final')), findsOneWidget);
    expectNoLayoutExceptions(tester);
  });

  testWidgets('adaptive layout selects compact content below breakpoint', (
    tester,
  ) async {
    await pumpAdaptive(
      tester,
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveLayout(
            breakpoint: 480,
            compact: SizedBox(key: Key('compact-layout')),
            expanded: SizedBox(key: Key('expanded-layout')),
          ),
        ),
      ),
      adaptiveLargeText,
    );

    expect(find.byKey(const Key('compact-layout')), findsOneWidget);
    expect(find.byKey(const Key('expanded-layout')), findsNothing);
    expectNoLayoutExceptions(tester);
  });

  testWidgets('adaptive action row stacks children on a small phone', (
    tester,
  ) async {
    await pumpAdaptive(
      tester,
      MaterialApp(
        home: Scaffold(
          body: AdaptiveActionRow(
            children: const [
              SizedBox(key: Key('primary-action'), height: 48),
              SizedBox(key: Key('secondary-action'), height: 48),
            ],
          ),
        ),
      ),
      adaptiveSmallPhone,
    );

    expect(find.byType(Column), findsOneWidget);
    expect(find.byType(Row), findsNothing);
    expectNoLayoutExceptions(tester);
  });

  testWidgets('adaptive action row keeps children in a row on wide landscape', (
    tester,
  ) async {
    await pumpAdaptive(
      tester,
      MaterialApp(
        home: Scaffold(
          body: AdaptiveActionRow(
            children: const [
              SizedBox(key: Key('primary-action'), height: 48),
              SizedBox(key: Key('secondary-action'), height: 48),
            ],
          ),
        ),
      ),
      adaptiveLandscape,
    );

    expect(find.byType(Row), findsOneWidget);
    expect(find.byType(Column), findsNothing);
    expectNoLayoutExceptions(tester);
  });
}
