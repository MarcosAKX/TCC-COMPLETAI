import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:completai_app/core/theme/app_theme.dart';
import 'package:completai_app/core/widgets/price_display.dart';
import 'package:completai_app/core/widgets/station_rating_overview.dart';
import 'package:completai_app/core/widgets/station_visual_cover.dart';
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

  testWidgets('resumo de avaliações anuncia a distribuição das notas', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: StationRatingOverview(
            average: 4,
            reviewCount: 4,
            ratings: [5, 5, 4, 2],
          ),
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(StationRatingOverview));
    expect(semantics.label, contains('5 estrelas, 2 avaliações'));
    expect(semantics.label, contains('4 estrelas, 1 avaliação'));
    expect(find.byType(LinearProgressIndicator), findsNWidgets(5));
  });

  testWidgets('nota inválida não é convertida em estrela válida', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: StationRatingOverview(
            average: 1,
            reviewCount: 2,
            ratings: [0, 2],
          ),
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(StationRatingOverview));
    expect(semantics.label, isNot(contains('1 estrela')));
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('capa do posto comunica identidade e situação sem imagem real', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: StationVisualCover(
            stationName: 'Posto Avenida',
            locationLabel: 'Centro · Bebedouro',
            isOpen: true,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('station-visual-cover')), findsOneWidget);
    expect(find.text('Posto Avenida'), findsOneWidget);
    expect(find.text('Centro · Bebedouro'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(StationVisualCover)),
      matchesSemantics(
        label: 'Capa do Posto Avenida, Centro · Bebedouro, aberto agora',
      ),
    );
  });

  testWidgets('capa usa foto e selo de bandeira quando disponíveis', (
    tester,
  ) async {
    final tinyPng = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwC'
      'AAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: StationVisualCover(
          stationName: 'Posto Avenida',
          locationLabel: 'Centro · Bebedouro',
          isOpen: true,
          coverImageBytes: tinyPng,
          stationBrand: 'Shell',
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('SHELL'), findsOneWidget);
    expect(find.text('PARADA COMPLETA'), findsNothing);
  });

  testWidgets('capa fotográfica protege texto com scrim e selo escuros', (
    tester,
  ) async {
    final tinyPng = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwC'
      'AAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: StationVisualCover(
          stationName: 'Posto Avenida',
          locationLabel: 'Centro · Bebedouro',
          isOpen: true,
          coverImageBytes: tinyPng,
          stationBrand: 'Shell',
        ),
      ),
    );

    final scrimFinder = find.byKey(
      const Key('station-visual-cover-photo-scrim'),
    );
    final scrim = tester.widget<DecoratedBox>(scrimFinder);
    final scrimGradient =
        (scrim.decoration as BoxDecoration).gradient! as LinearGradient;
    expect(scrimGradient.colors.first.a, greaterThanOrEqualTo(0.6));

    final badgeFinder = find.byKey(
      const Key('station-visual-cover-brand-badge'),
    );
    final badge = tester.widget<Container>(badgeFinder);
    expect((badge.decoration as BoxDecoration).color, const Color(0xE6000000));
    expect(tester.widget<Text>(find.text('SHELL')).style?.color, Colors.white);
    expect(
      tester
          .widget<Icon>(
            find.descendant(
              of: badgeFinder,
              matching: find.byIcon(Icons.local_gas_station_rounded),
            ),
          )
          .color,
      Colors.white,
    );
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
