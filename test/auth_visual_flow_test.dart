import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:completai_app/core/theme/app_theme.dart';
import 'package:completai_app/core/widgets/brand_header.dart';
import 'package:completai_app/core/widgets/step_progress_header.dart';
import 'package:completai_app/core/widgets/urban_route_signature.dart';

void main() {
  testWidgets('marca é estável e comunica produto sem animação infinita', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: BrandHeader(
            title: 'Completai!',
            subtitle: 'Preço confiável para abastecer melhor.',
          ),
        ),
      ),
    );

    expect(find.text('Completai!'), findsOneWidget);
    expect(find.byType(UrbanRouteSignature), findsOneWidget);
    final brand = find.byType(BrandHeader);
    expect(
      find.descendant(of: brand, matching: find.byType(AnimatedBuilder)),
      findsNothing,
    );
    expect(
      find.descendant(of: brand, matching: find.byType(ScaleTransition)),
      findsNothing,
    );
  });

  testWidgets('progresso informa etapa atual de forma semântica', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: StepProgressHeader(currentStep: 2, totalSteps: 2),
        ),
      ),
    );

    expect(find.text('Etapa 2 de 2'), findsOneWidget);
    expect(find.byKey(const Key('route-progress-waypoints')), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(
      tester.getSemantics(find.byType(StepProgressHeader)),
      matchesSemantics(label: 'Etapa 2 de 2'),
    );
  });
}
