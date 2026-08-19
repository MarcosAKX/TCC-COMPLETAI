import 'package:completai_app/core/theme/app_theme.dart';
import 'package:completai_app/features/gas_station/models/public_gas_station.dart';
import 'package:completai_app/features/user/models/station_discovery_filter.dart';
import 'package:completai_app/features/user/views/station_list_page.dart';
import 'package:completai_app/features/user/widgets/discovery_station_card.dart';
import 'package:completai_app/features/user/widgets/fuel_choice_selector.dart';
import 'package:completai_app/features/user/widgets/fuel_discovery_tip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/adaptive_test_harness.dart';

const _longStationName =
    'Posto Avenida das Palmeiras e Conveniência Bebedouro Centro';

void main() {
  for (final scenario in [
    adaptiveSmallPhone,
    adaptiveLargeText,
    adaptiveLandscape,
  ]) {
    testWidgets('controles e card preservam conteúdo em ${scenario.name}', (
      tester,
    ) async {
      await pumpAdaptive(
        tester,
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  FuelChoiceSelector(
                    choice: FuelChoice.gasoline,
                    onChanged: (_) {},
                  ),
                  FuelDiscoveryTip(onDismiss: () {}),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: DiscoveryStationCard(
                      station: _station(),
                      fuel: FuelChoice.gasoline,
                      isBestValue: true,
                      savingsPerLiter: 0.18,
                      isOpen: false,
                      onOpen: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        scenario,
      );
      await tester.pump();

      for (final fuel in FuelChoice.values) {
        final option = find.byKey(Key('fuel-option-${fuel.name}'));
        expect(option, findsOneWidget);
        expect(tester.getSize(option).height, greaterThanOrEqualTo(48));
      }

      expect(find.text('Não informado'), findsOneWidget);
      expect(find.text('Fechado'), findsOneWidget);
      expect(find.textContaining('Atualizado'), findsOneWidget);
      expect(find.text('Troque de combustível'), findsOneWidget);
      expectNoLayoutExceptions(tester);

      if (scenario == adaptiveLargeText) {
        _expectFullyRendered(tester, find.text('Gasolina').first);
        _expectFullyRendered(tester, find.text('Diesel').first);
        _expectFullyRendered(tester, find.text(_longStationName));
        _expectFullyRendered(tester, find.text('Não informado'));
        expect(
          tester.getSize(find.text(_longStationName)).height,
          greaterThan(40),
        );
      }
    });
  }

  for (final scenario in [
    adaptiveSmallPhone,
    adaptiveLargeText,
    adaptiveLandscape,
  ]) {
    testWidgets(
      'primeiro card permanece alcançável após o cabeçalho em ${scenario.name}',
      (tester) async {
        final searchController = TextEditingController();
        addTearDown(searchController.dispose);

        await pumpAdaptive(
          tester,
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: StationDiscoveryContent(
                snapshot: AsyncSnapshot.withData(ConnectionState.done, [
                  _station(),
                ]),
                searchController: searchController,
                fuel: FuelChoice.gasoline,
                onlyOpen: false,
                minimumRatingFour: false,
                showFuelTip: true,
                onRefresh: () async {},
                onRetry: () async {},
                onLocationTap: () {},
                onSearchChanged: (_) {},
                onClearSearch: () {},
                onFuelChanged: (_) {},
                onDismissFuelTip: () {},
                onOnlyOpenChanged: (_) {},
                onShowFilters: () {},
                onOpenStation: (_) {},
              ),
            ),
          ),
          scenario,
        );

        final firstCard = find.byKey(
          const Key('discovery-station-station-adaptive'),
        );
        await tester.dragUntilVisible(
          firstCard,
          find.byKey(const Key('station-discovery-scroll')),
          const Offset(0, -200),
        );
        await Scrollable.ensureVisible(
          tester.element(firstCard),
          alignment: 0.5,
        );
        await tester.pump();

        expect(firstCard, findsOneWidget);
        expect(
          find
              .descendant(of: firstCard, matching: find.byType(InkWell))
              .first
              .hitTestable(),
          findsOneWidget,
        );
        expectNoLayoutExceptions(tester);
      },
    );
  }
}

void _expectFullyRendered(WidgetTester tester, Finder finder) {
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  expect(paragraph.didExceedMaxLines, isFalse);
}

PublicGasStation _station() {
  return PublicGasStation(
    id: 'station-adaptive',
    name: _longStationName,
    phone: '',
    address: 'Avenida Brigadeiro Faria Lima, 1234',
    neighborhood: 'Jardim das Laranjeiras e Palmeiras',
    city: 'Bebedouro',
    fuelPrices: const {'ethanol': 3.79, 'dieselS10': 5.89},
    tags: const [],
    services: const [],
    openingHours: const {},
    updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    averageRating: 4.7,
    reviewCount: 20,
  );
}
