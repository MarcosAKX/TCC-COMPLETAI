import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:completai_app/core/theme/app_theme.dart';
import 'package:completai_app/core/widgets/price_display.dart';
import 'package:completai_app/core/widgets/status_pill.dart';
import 'package:completai_app/core/widgets/trust_badge.dart';
import 'package:completai_app/core/widgets/welcome_summary_header.dart';

void main() {
  testWidgets('preço em destaque comunica combustível e valor', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: PriceDisplay(
            label: 'Gasolina comum',
            price: 5.79,
            emphasized: true,
          ),
        ),
      ),
    );

    expect(find.text('GASOLINA COMUM'), findsOneWidget);
    expect(find.text('R\$ 5,79'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(PriceDisplay)),
      matchesSemantics(label: 'Gasolina comum, 5 reais e 79 centavos'),
    );
  });

  testWidgets('preço ausente usa mensagem compreensível', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: PriceDisplay(label: 'Etanol', price: null)),
      ),
    );

    expect(find.text('Não informado'), findsOneWidget);
  });

  testWidgets('melhor valor usa selo textual e verde de economia', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: PriceDisplay(
            label: 'Gasolina comum',
            price: 5.49,
            bestValue: true,
          ),
        ),
      ),
    );

    expect(find.text('Melhor valor'), findsOneWidget);
    final price = tester.widget<Text>(find.text('R\$ 5,49'));
    expect(price.style?.color, AppTheme.savings);
  });

  testWidgets('status não depende apenas de cor', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: StatusPill(isOpen: true)),
      ),
    );

    expect(find.text('Aberto agora'), findsOneWidget);
    expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(StatusPill)),
      matchesSemantics(label: 'Posto aberto agora'),
    );
  });

  testWidgets('selo de confiança comunica origem e frescor', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: TrustBadge(
            text: 'Informado pelo posto',
            icon: Icons.verified_outlined,
          ),
        ),
      ),
    );

    expect(find.text('Informado pelo posto'), findsOneWidget);
    expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
  });

  testWidgets('cabeçalho resume cobertura sem claim inventado', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: WelcomeSummaryHeader(stationCount: 12)),
      ),
    );

    expect(find.text('Onde completar hoje?'), findsOneWidget);
    expect(find.text('Bebedouro · 12 postos encontrados'), findsOneWidget);
  });
}
