import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:completai_app/core/theme/app_theme.dart';
import 'package:completai_app/core/widgets/app_user_avatar.dart';
import 'package:completai_app/core/widgets/fuel_price_grid.dart';
import 'package:completai_app/core/widgets/station_logo.dart';
import 'package:completai_app/features/user/models/station_discovery_filter.dart';

void main() {
  testWidgets('avatar usa iniciais e abre perfil', (tester) async {
    final semantics = tester.ensureSemantics();
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: AppUserAvatar(
            displayName: 'Marcos Silva',
            onTap: () => opened = true,
          ),
        ),
      ),
    );

    expect(find.text('MS'), findsOneWidget);
    final profileButton = find.bySemanticsLabel(RegExp('Abrir meu perfil'));
    expect(profileButton, findsOneWidget);
    await tester.tap(profileButton);
    expect(opened, isTrue);
    semantics.dispose();
  });

  testWidgets('logo ausente usa iniciais do posto', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: StationLogo(stationName: 'Posto Avenida')),
      ),
    );

    expect(find.text('PA'), findsOneWidget);
    expect(find.bySemanticsLabel('Logo de Posto Avenida'), findsOneWidget);
  });

  testWidgets('grade mostra três preços e melhor valor', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: FuelPriceGrid(
            prices: {
              'gasolineRegular': 5.69,
              'ethanol': 3.89,
              'dieselS10': 5.99,
            },
            selectedFuel: FuelChoice.gasoline,
            bestValueKeys: {'gasolineRegular'},
          ),
        ),
      ),
    );

    expect(find.text('GASOLINA'), findsOneWidget);
    expect(find.text('ETANOL'), findsOneWidget);
    expect(find.text('DIESEL S10'), findsOneWidget);
    expect(find.text('R\$ 5,69'), findsOneWidget);
    expect(find.text('R\$ 3,89'), findsOneWidget);
    expect(find.text('R\$ 5,99'), findsOneWidget);
    expect(find.text('Melhor valor'), findsOneWidget);
  });

  testWidgets('grade comunica preço não informado', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: FuelPriceGrid(prices: {})),
      ),
    );

    expect(find.text('Não informado'), findsNWidgets(3));
  });
}
