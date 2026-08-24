import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class AdaptiveTestScenario {
  const AdaptiveTestScenario({
    required this.name,
    required this.size,
    required this.textScaleFactor,
    this.viewInsets = EdgeInsets.zero,
  });

  final String name;
  final Size size;
  final double textScaleFactor;
  final EdgeInsets viewInsets;
}

const adaptiveSmallPhone = AdaptiveTestScenario(
  name: '320x568 @ 1.0',
  size: Size(320, 568),
  textScaleFactor: 1,
);

const adaptiveLargeText = AdaptiveTestScenario(
  name: '360x800 @ 2.0',
  size: Size(360, 800),
  textScaleFactor: 2,
);

const adaptiveLandscape = AdaptiveTestScenario(
  name: '640x360 @ 1.3',
  size: Size(640, 360),
  textScaleFactor: 1.3,
);

Future<void> pumpAdaptive(
  WidgetTester tester,
  Widget child,
  AdaptiveTestScenario scenario,
) async {
  final view = tester.view;
  final originalPhysicalSize = view.physicalSize;
  final originalDevicePixelRatio = view.devicePixelRatio;
  final originalViewInsets = view.viewInsets;

  view.physicalSize = scenario.size;
  view.devicePixelRatio = 1;
  view.viewInsets = FakeViewPadding(
    left: scenario.viewInsets.left,
    top: scenario.viewInsets.top,
    right: scenario.viewInsets.right,
    bottom: scenario.viewInsets.bottom,
  );
  addTearDown(() {
    view.physicalSize = originalPhysicalSize;
    view.devicePixelRatio = originalDevicePixelRatio;
    view.viewInsets = originalViewInsets;
  });

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData.fromView(
        view,
      ).copyWith(textScaler: TextScaler.linear(scenario.textScaleFactor)),
      child: child,
    ),
  );
}

void expectNoLayoutExceptions(WidgetTester tester) {
  expect(tester.takeException(), isNull);
}
