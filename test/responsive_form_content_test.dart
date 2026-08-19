import 'package:completai_app/core/widgets/responsive_form_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/adaptive_test_harness.dart';

void main() {
  testWidgets('form content stays centered and capped on wide screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResponsiveFormContent(
            child: SizedBox(key: Key('form-child'), height: 100),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const Key('responsive-form-frame'))).width,
      440,
    );
    expect(tester.getSize(find.byKey(const Key('form-child'))).width, 400);
    expect(
      tester.getTopLeft(find.byKey(const Key('responsive-form-frame'))).dx,
      280,
    );
  });

  testWidgets('form content keeps equal mobile insets', (tester) async {
    await pumpAdaptive(
      tester,
      const MaterialApp(
        home: Scaffold(
          body: ResponsiveFormContent(
            child: SizedBox(key: Key('form-child'), height: 100),
          ),
        ),
      ),
      adaptiveLargeText,
    );

    expect(
      tester.getSize(find.byKey(const Key('responsive-form-frame'))).width,
      360,
    );
    expect(tester.getSize(find.byKey(const Key('form-child'))).width, 320);
    expect(tester.getTopLeft(find.byKey(const Key('form-child'))).dx, 20);
  });
}
