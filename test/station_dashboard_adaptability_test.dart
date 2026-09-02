import 'package:completai_app/features/gas_station/models/station_review.dart';
import 'package:completai_app/features/gas_station/views/station_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/adaptive_test_harness.dart';

void main() {
  Widget app(Widget child) => MaterialApp(home: Scaffold(body: child));

  for (final scenario in [
    adaptiveSmallPhone,
    adaptiveLargeText,
    adaptiveLandscape,
  ]) {
    testWidgets('header e card de preço cabem em ${scenario.name}', (
      tester,
    ) async {
      await pumpAdaptive(
        tester,
        app(
          ListView(
            children: [
              DashboardHeader(
                stationName: 'Posto Avenida com nome bastante extenso',
                isOpen: true,
                onNotifications: () {},
                onProfile: () {},
              ),
              DashboardPriceFields(
                fields: const [
                  TextField(
                    decoration: InputDecoration(labelText: 'Gasolina comum'),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Gasolina aditivada',
                    ),
                  ),
                  TextField(decoration: InputDecoration(labelText: 'Etanol')),
                ],
              ),
            ],
          ),
        ),
        scenario,
      );

      expectNoLayoutExceptions(tester);
      expect(find.text('Completai!'), findsOneWidget);
      expect(
        find.text('Posto Avenida com nome bastante extenso'),
        findsOneWidget,
      );
      expect(find.text('Área administrativa'), findsOneWidget);
      expect(find.text('Etanol'), findsOneWidget);
    });
  }

  testWidgets('usa barra abaixo de 840 e rail a partir de 840', (tester) async {
    Widget shell() => app(
      DashboardAdaptiveShell(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        header: const SizedBox(height: 48),
        body: const Text('conteúdo'),
      ),
    );

    await tester.binding.setSurfaceSize(const Size(839, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(shell());
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    await tester.binding.setSurfaceSize(const Size(840, 700));
    await tester.pumpWidget(shell());
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsOneWidget);
  });

  testWidgets('mantém CTA final alcançável por rolagem compacta', (
    tester,
  ) async {
    const ctaKey = Key('dashboard-final-cta');
    await pumpAdaptive(
      tester,
      app(
        DashboardAdaptiveShell(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          header: const SizedBox(height: 48),
          body: ListView(
            children: [
              const SizedBox(height: 900),
              FilledButton(
                key: ctaKey,
                onPressed: () {},
                child: const Text('Publicar preço'),
              ),
            ],
          ),
        ),
      ),
      adaptiveSmallPhone,
    );

    await tester.dragUntilVisible(
      find.byKey(ctaKey),
      find.byType(Scrollable).first,
      const Offset(0, -240),
    );
    expect(find.byKey(ctaKey), findsOneWidget);
    expectNoLayoutExceptions(tester);
  });

  testWidgets('resumo operacional expõe a completude do cadastro', (
    tester,
  ) async {
    await pumpAdaptive(
      tester,
      app(
        const DashboardOperationalOverview(
          configuredPriceCount: 4,
          serviceCount: 6,
          activeDayCount: 7,
        ),
      ),
      adaptiveSmallPhone,
    );

    expect(find.text('4 de 5'), findsOneWidget);
    expect(find.text('6 serviços'), findsOneWidget);
    expect(find.text('7 dias ativos'), findsOneWidget);
    expectNoLayoutExceptions(tester);
  });

  testWidgets('prévia pública apresenta o posto como o cliente verá', (
    tester,
  ) async {
    var editCount = 0;
    await pumpAdaptive(
      tester,
      app(
        SingleChildScrollView(
          child: DashboardPublicPreview(
            stationName: 'Posto Avenida com nome bastante extenso',
            address: 'Avenida Central, 123 · Bebedouro',
            isOpen: true,
            configuredPriceCount: 4,
            serviceCount: 6,
            activeDayCount: 7,
            lastUpdatedText: 'Hoje às 10:30',
            coverImageUrl: 'https://example.invalid/cover.jpg',
            stationBrand: 'Shell',
            onEditPresentation: () => editCount++,
          ),
        ),
      ),
      adaptiveLargeText,
    );

    expect(find.text('Prévia para clientes'), findsOneWidget);
    expect(find.byKey(const Key('station-visual-cover')), findsOneWidget);
    expect(find.text('4 combustíveis'), findsOneWidget);
    expect(find.text('6 serviços'), findsOneWidget);
    expect(find.text('7 dias ativos'), findsOneWidget);
    expect(find.text('SHELL'), findsOneWidget);
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<NetworkImage>());
    expect((image.image as NetworkImage).url, contains('cover.jpg'));
    await tester.tap(find.byTooltip('Editar exibição'));
    expect(editCount, 1);
    expectNoLayoutExceptions(tester);
  });

  testWidgets('horário reflui e mantém controles com 48 dp', (tester) async {
    await pumpAdaptive(
      tester,
      app(
        DashboardOpeningHourRow(
          dayLabel: 'Segunda-feira',
          enabled: true,
          openLabel: '06:00',
          closeLabel: '22:00',
          onEnabledChanged: (_) {},
          onOpenPressed: () {},
          onClosePressed: () {},
        ),
      ),
      adaptiveLargeText,
    );

    expectNoLayoutExceptions(tester);
    expect(find.byKey(const Key('dashboard-hours-stacked')), findsOneWidget);
    for (final label in ['06:00', '22:00']) {
      final size = tester.getSize(find.widgetWithText(OutlinedButton, label));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    }
  });

  testWidgets('avaliação longa reflui sem perder denúncia', (tester) async {
    await pumpAdaptive(
      tester,
      app(
        SingleChildScrollView(
          child: DashboardReviewCard(
            review: StationReview(
              id: 'review-1',
              userId: 'user-1',
              authorName: 'Cliente com um nome bastante longo',
              rating: 4,
              comment:
                  'Comentário longo que precisa continuar legível em fonte ampliada.',
              createdAt: DateTime(2026, 8, 1),
              updatedAt: null,
            ),
            alreadyReported: false,
            onReport: () {},
          ),
        ),
      ),
      adaptiveLargeText,
    );

    expectNoLayoutExceptions(tester);
    expect(find.text('Denunciar'), findsOneWidget);
    expect(
      tester.getSize(find.widgetWithText(OutlinedButton, 'Denunciar')).height,
      greaterThanOrEqualTo(48),
    );
  });
}
