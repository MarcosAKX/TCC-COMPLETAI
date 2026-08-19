import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:completai_app/core/theme/app_theme.dart';
import 'package:completai_app/core/widgets/custom_button.dart';
import 'package:completai_app/core/widgets/custom_text_field.dart';
import 'package:completai_app/core/widgets/decision_highlight_card.dart';
import 'package:completai_app/core/widgets/price_display.dart';

void main() {
  test('tema aplica paleta Meu combustível', () {
    expect(AppTheme.background, const Color(0xFFF6F7F9));
    expect(AppTheme.card, const Color(0xFFFFFFFF));
    expect(AppTheme.primary, const Color(0xFF315EFB));
    expect(AppTheme.price, const Color(0xFF3559C7));
    expect(AppTheme.savings, const Color(0xFF079B68));
    expect(AppTheme.savingsSurface, const Color(0xFFE7F7F0));
    expect(AppTheme.rating, const Color(0xFFD88710));
    expect(AppTheme.error, const Color(0xFFC9362B));
    expect(AppTheme.textLight, const Color(0xFF1B1D22));
  });

  testWidgets('preço comum usa azul médio aprovado', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: PriceDisplay(label: 'Etanol', price: 3.89)),
      ),
    );

    final richText = tester
        .widgetList<RichText>(find.byType(RichText))
        .firstWhere((widget) => widget.text.toPlainText().contains('3,89'));
    final root = richText.text as TextSpan;
    expect(_usesColor(root, AppTheme.price), isTrue);
  });

  testWidgets('botão principal preserva alvo mínimo de 48 dp', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: CustomButton(text: 'Continuar', onPressed: () {}),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(ElevatedButton)).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('botão principal mantém texto branco sobre azul', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: CustomButton(text: 'Entrar', onPressed: () {}),
        ),
      ),
    );

    final label = tester.widget<Text>(find.text('Entrar'));
    expect(label.style?.color, Colors.white);
  });

  testWidgets('campo comunica erro e permite revelar senha', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: CustomTextField(
            label: 'Senha',
            hint: 'Digite sua senha',
            icon: Icons.lock_outline,
            obscureText: true,
            enablePasswordToggle: true,
            errorText: 'Senha obrigatória',
            autofillHints: [AutofillHints.password],
          ),
        ),
      ),
    );

    expect(find.text('Senha obrigatória'), findsOneWidget);
    expect(find.byTooltip('Mostrar senha'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isTrue,
    );

    await tester.tap(find.byTooltip('Mostrar senha'));
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isFalse,
    );
    expect(find.byTooltip('Ocultar senha'), findsOneWidget);
  });

  testWidgets('destaque de decisão diferencia economia e avaliação', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Column(
            children: [
              DecisionHighlightCard(
                variant: DecisionHighlightVariant.economy,
                title: 'Menor preço',
                subtitle: 'Posto A',
                detail: 'Gasolina comum · R\$ 5,79',
              ),
              DecisionHighlightCard(
                variant: DecisionHighlightVariant.rating,
                title: 'Melhor avaliação',
                subtitle: 'Posto B',
                detail: '4,5 · 12 avaliações',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Menor preço'), findsOneWidget);
    expect(find.text('Melhor avaliação'), findsOneWidget);
  });
}

bool _usesColor(InlineSpan span, Color color) {
  if (span.style?.color == color) return true;
  if (span is! TextSpan) return false;
  return span.children?.any((child) => _usesColor(child, color)) ?? false;
}
