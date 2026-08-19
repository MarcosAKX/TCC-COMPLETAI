import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:completai_app/core/theme/app_theme.dart';
import 'package:completai_app/features/gas_station/models/public_gas_station.dart';
import 'package:completai_app/features/user/models/station_discovery_filter.dart';
import 'package:completai_app/features/user/widgets/discovery_station_card.dart';
import 'package:completai_app/features/user/widgets/fuel_choice_selector.dart';

void main() {
  testWidgets('seletor comunica escolha e troca combustível', (tester) async {
    FuelChoice? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: FuelChoiceSelector(
            choice: FuelChoice.gasoline,
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    expect(find.text('Gasolina'), findsOneWidget);
    expect(find.text('Etanol'), findsOneWidget);
    expect(find.text('Diesel'), findsOneWidget);
    expect(find.byKey(const Key('fuel-option-gasoline')), findsOneWidget);
    expect(find.byKey(const Key('fuel-option-ethanol')), findsOneWidget);
    expect(find.byKey(const Key('fuel-option-diesel')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('fuel-option-gasoline'))).height,
      greaterThanOrEqualTo(48),
    );
    final activeOption = tester.widget<AnimatedContainer>(
      find.byKey(const Key('fuel-option-gasoline')),
    );
    expect((activeOption.decoration as BoxDecoration).color, Colors.white);
    final band = tester.widget<ColoredBox>(
      find.byKey(const Key('fuel-choice-band')),
    );
    expect(band.color, AppTheme.primary);

    await tester.tap(find.text('Etanol'));
    expect(selected, FuelChoice.ethanol);
  });

  testWidgets('card mostra três combustíveis e melhor valor', (tester) async {
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: DiscoveryStationCard(
            station: _station(),
            fuel: FuelChoice.gasoline,
            isBestValue: true,
            savingsPerLiter: 0.10,
            isOpen: true,
            onOpen: () => opened = true,
          ),
        ),
      ),
    );

    expect(find.text('R\$ 5,49'), findsOneWidget);
    expect(find.text('R\$ 3,79'), findsOneWidget);
    expect(find.text('R\$ 5,89'), findsOneWidget);
    expect(find.text('Melhor valor'), findsOneWidget);
    expect(find.text('Melhor opção para Gasolina'), findsOneWidget);
    expect(find.text('Economize até R\$ 0,10/L'), findsOneWidget);

    final accent = tester.widget<ColoredBox>(
      find.byKey(const Key('station-card-accent')),
    );
    expect(accent.color, AppTheme.primary);

    await tester.tap(find.byType(DiscoveryStationCard));
    expect(opened, isTrue);
  });

  testWidgets('card explica preço não informado', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: DiscoveryStationCard(
            station: _station(gasoline: null),
            fuel: FuelChoice.gasoline,
            isBestValue: false,
            isOpen: false,
            onOpen: () {},
          ),
        ),
      ),
    );

    expect(find.text('Não informado'), findsOneWidget);
    expect(find.text('Fechado'), findsOneWidget);
    expect(find.byKey(const Key('station-card-accent')), findsNothing);
  });
}

PublicGasStation _station({double? gasoline = 5.49}) {
  final prices = <String, double>{'ethanol': 3.79, 'dieselS10': 5.89};
  if (gasoline != null) prices['gasolineRegular'] = gasoline;
  return PublicGasStation(
    id: 'station-1',
    name: 'Posto Avenida',
    phone: '',
    address: 'Avenida Brasil, 1234',
    neighborhood: 'Centro',
    city: 'Bebedouro',
    fuelPrices: prices,
    tags: const [],
    services: const [],
    openingHours: const {},
    updatedAt: DateTime(2026, 8, 18, 11, 40),
    averageRating: 4.7,
    reviewCount: 20,
  );
}
