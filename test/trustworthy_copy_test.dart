import 'package:completai_app/features/auth/views/register_type_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cadastro descreve somente capacidades disponíveis', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterTypePage()));

    expect(find.text('Motorista'), findsOneWidget);
    expect(
      find.text(
        'Compare preços, horários e avaliações dos postos de Bebedouro.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Mantenha preços, horários e serviços do seu posto atualizados.',
      ),
      findsOneWidget,
    );

    expect(find.textContaining('próximos'), findsNothing);
    expect(find.textContaining('gastos'), findsNothing);
    expect(find.textContaining('tempo real'), findsNothing);
    expect(find.textContaining('vendas'), findsNothing);
  });
}
