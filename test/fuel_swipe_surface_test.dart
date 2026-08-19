import 'package:completai_app/features/user/models/station_discovery_filter.dart';
import 'package:completai_app/features/user/widgets/fuel_swipe_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('swipe left advances and swipe right returns fuel choice', (
    tester,
  ) async {
    FuelChoice selected = FuelChoice.gasoline;

    Widget app() => MaterialApp(
      home: StatefulBuilder(
        builder: (context, setState) => Scaffold(
          body: FuelSwipeSurface(
            choice: selected,
            onChanged: (fuel) => setState(() => selected = fuel),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );

    await tester.pumpWidget(app());
    await tester.drag(find.byType(FuelSwipeSurface), const Offset(-90, 0));
    await tester.pumpAndSettle();
    expect(selected, FuelChoice.ethanol);

    await tester.drag(find.byType(FuelSwipeSurface), const Offset(90, 0));
    await tester.pumpAndSettle();
    expect(selected, FuelChoice.gasoline);
  });

  testWidgets('swipe respects first and last fuel boundaries', (tester) async {
    FuelChoice selected = FuelChoice.diesel;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FuelSwipeSurface(
            choice: selected,
            onChanged: (fuel) => selected = fuel,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(FuelSwipeSurface), const Offset(-90, 0));
    await tester.pumpAndSettle();
    expect(selected, FuelChoice.diesel);
  });

  testWidgets('short horizontal movement does not change fuel', (tester) async {
    FuelChoice selected = FuelChoice.ethanol;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FuelSwipeSurface(
            choice: selected,
            onChanged: (fuel) => selected = fuel,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(FuelSwipeSurface), const Offset(20, 0));
    await tester.pumpAndSettle();
    expect(selected, FuelChoice.ethanol);
  });
}
