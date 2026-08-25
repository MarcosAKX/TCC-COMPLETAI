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

  testWidgets('adaptive layout selects expanded content at the breakpoint', (
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
      adaptiveLandscape,
    );

    expect(find.byKey(const Key('compact-layout')), findsNothing);
    expect(find.byKey(const Key('expanded-layout')), findsOneWidget);
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
              SizedBox(key: Key('primary-action')),
              SizedBox(key: Key('secondary-action')),
            ],
          ),
        ),
      ),
      adaptiveSmallPhone,
    );

    expect(find.byType(Column), findsOneWidget);
    expect(find.byType(Row), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('primary-action'))),
      const Size(320, 48),
    );
    expect(
      tester.getSize(find.byKey(const Key('secondary-action'))),
      const Size(320, 48),
    );
    expectNoLayoutExceptions(tester);
  });

  testWidgets(
    'adaptive action row keeps fitting children horizontal on wide landscape',
    (tester) async {
      await pumpAdaptive(
        tester,
        MaterialApp(
          home: Scaffold(
            body: AdaptiveActionRow(
              children: const [
                SizedBox(key: Key('primary-action')),
                SizedBox(key: Key('secondary-action')),
              ],
            ),
          ),
        ),
        adaptiveLandscape,
      );

      expect(find.byType(OverflowBar), findsOneWidget);
      expect(find.byType(Column), findsNothing);
      expect(
        tester.getSize(find.byKey(const Key('primary-action'))),
        const Size(48, 48),
      );
      expect(
        tester.getSize(find.byKey(const Key('secondary-action'))),
        const Size(48, 48),
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('primary-action'))).dy,
        tester.getTopLeft(find.byKey(const Key('secondary-action'))).dy,
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('primary-action'))).dx,
        lessThan(
          tester.getTopLeft(find.byKey(const Key('secondary-action'))).dx,
        ),
      );
      expectNoLayoutExceptions(tester);
    },
  );

  testWidgets(
    'adaptive action row reflows long scaled labels at exactly 600 dp',
    (tester) async {
      const largeTextMidWidth = AdaptiveTestScenario(
        name: '600x800 @ 2.0',
        size: Size(600, 800),
        textScaleFactor: 2,
      );

      await pumpAdaptive(
        tester,
        MaterialApp(
          home: Scaffold(
            body: AdaptiveActionRow(
              children: [
                FilledButton(
                  key: const Key('large-primary-action'),
                  onPressed: () {},
                  child: const Text('Salvar todas as alteracoes'),
                ),
                FilledButton(
                  key: const Key('large-secondary-action'),
                  onPressed: () {},
                  child: const Text('Cancelar e voltar'),
                ),
              ],
            ),
          ),
        ),
        largeTextMidWidth,
      );

      expect(find.byType(OverflowBar), findsOneWidget);
      expect(find.byType(Row), findsNothing);
      expect(
        tester.getTopLeft(find.byKey(const Key('large-primary-action'))).dy,
        lessThan(
          tester.getTopLeft(find.byKey(const Key('large-secondary-action'))).dy,
        ),
      );
      expectNoLayoutExceptions(tester);
    },
  );

  testWidgets('responsive content keeps the final child above the keyboard', (
    tester,
  ) async {
    const keyboardOpen = AdaptiveTestScenario(
      name: '360x800 keyboard',
      size: Size(360, 800),
      textScaleFactor: 1,
      viewInsets: EdgeInsets.only(bottom: 240),
    );

    await pumpAdaptive(
      tester,
      MaterialApp(
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          body: ResponsiveContent(
            scrollable: true,
            child: const Column(
              children: [
                SizedBox(height: 700),
                SizedBox(key: Key('keyboard-final-child'), height: 48),
              ],
            ),
          ),
        ),
      ),
      keyboardOpen,
    );

    await tester.drag(find.byType(Scrollable), const Offset(0, -240));
    await tester.pumpAndSettle();

    expect(
      tester.getBottomRight(find.byKey(const Key('keyboard-final-child'))).dy,
      lessThanOrEqualTo(560),
    );
    expectNoLayoutExceptions(tester);
  });
}
