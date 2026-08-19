import 'package:completai_app/core/theme/app_theme.dart';
import 'package:completai_app/core/widgets/auth_surface_card.dart';
import 'package:completai_app/core/widgets/brand_hero_panel.dart';
import 'package:completai_app/core/widgets/urban_route_signature.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'identity tokens keep authentication and discovery contexts distinct',
    () {
      expect(AppTheme.discoveryBackground, const Color(0xFFE8EEFF));
      expect(AppTheme.authBackground, const Color(0xFFE8EEFF));
      expect(AppTheme.primary, const Color(0xFF315EFB));
    },
  );

  testWidgets('brand hero presents the approved promise and route signature', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BrandHeroPanel(
            title: 'Completai!',
            message: 'Seu próximo abastecimento começa aqui',
          ),
        ),
      ),
    );

    expect(find.text('Completai!'), findsOneWidget);
    expect(find.text('Seu próximo abastecimento começa aqui'), findsOneWidget);
    expect(find.byType(UrbanRouteSignature), findsOneWidget);
  });

  testWidgets('auth surface exposes a white bounded form surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AuthSurfaceCard(child: Text('Entre na sua conta')),
        ),
      ),
    );

    final decorated = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(AuthSurfaceCard),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = decorated.decoration as BoxDecoration;
    expect(decoration.color, AppTheme.card);
    expect(find.text('Entre na sua conta'), findsOneWidget);
  });
}
