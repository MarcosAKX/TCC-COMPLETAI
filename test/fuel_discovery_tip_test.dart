import 'package:completai_app/features/user/widgets/fuel_discovery_tip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dica orienta sem bloquear e pode ser dispensada', (
    tester,
  ) async {
    var dismissed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FuelDiscoveryTip(onDismiss: () => dismissed = true),
        ),
      ),
    );

    expect(find.text('Troque de combustível'), findsOneWidget);
    expect(
      find.text('Toque nas opções acima ou deslize a lista para os lados.'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Dispensar dica'));

    expect(dismissed, isTrue);
  });
}
