import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/adaptive_test_harness.dart';

void main() {
  testWidgets('harness aplica janela e escala de texto', (tester) async {
    await pumpAdaptive(
      tester,
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Text('Teste'),
      ),
      adaptiveLargeText,
    );

    expect(tester.view.physicalSize, const Size(360, 800));
    expect(tester.view.devicePixelRatio, 1);
    final media = tester.widget<MediaQuery>(find.byType(MediaQuery).last);
    expect(media.data.textScaler.scale(10), 20);
  });

  testWidgets('harness aplica cenário de telefone pequeno', (tester) async {
    await pumpAdaptive(
      tester,
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Text('Teste'),
      ),
      adaptiveSmallPhone,
    );

    expect(tester.view.physicalSize, const Size(320, 568));
    final media = tester.widget<MediaQuery>(find.byType(MediaQuery).last);
    expect(media.data.textScaler.scale(10), 10);
  });

  testWidgets('harness aplica cenário landscape e insets', (tester) async {
    await pumpAdaptive(
      tester,
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Text('Teste'),
      ),
      adaptiveLandscape,
    );

    expect(tester.view.physicalSize, const Size(640, 360));
    final media = tester.widget<MediaQuery>(find.byType(MediaQuery).last);
    expect(media.data.textScaler.scale(10), 13);
  });

  testWidgets('harness aplica e restaura insets de teclado', (tester) async {
    final originalInsets = tester.view.viewInsets;
    addTearDown(() {
      expect(tester.view.viewInsets, originalInsets);
    });
    const scenario = AdaptiveTestScenario(
      name: '320x568 @ 1.0 com teclado',
      size: Size(320, 568),
      textScaleFactor: 1,
      viewInsets: EdgeInsets.only(bottom: 240),
    );

    await pumpAdaptive(
      tester,
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Text('Teste'),
      ),
      scenario,
    );

    final media = tester.widget<MediaQuery>(find.byType(MediaQuery).last);
    expect(media.data.viewInsets.bottom, 240);
  });

  testWidgets('harness restaura a view ao desmontar o teste', (tester) async {
    final originalSize = tester.view.physicalSize;
    final originalDevicePixelRatio = tester.view.devicePixelRatio;

    addTearDown(() {
      expect(tester.view.physicalSize, originalSize);
      expect(tester.view.devicePixelRatio, originalDevicePixelRatio);
    });
    await pumpAdaptive(
      tester,
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Text('Teste'),
      ),
      adaptiveLargeText,
    );
  });

  testWidgets('harness identifica ausência de exceções de layout', (
    tester,
  ) async {
    await pumpAdaptive(
      tester,
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Text('Teste'),
      ),
      adaptiveSmallPhone,
    );

    expectNoLayoutExceptions(tester);
  });
}
