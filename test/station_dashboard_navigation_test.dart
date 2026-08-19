import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/gas_station/views/station_dashboard_page.dart',
    ).readAsStringSync();
  });

  test('dashboard oferece quatro tarefas com preços primeiro', () {
    final prices = source.indexOf("label: 'Preços'");
    final information = source.indexOf("label: 'Informações'");
    final hours = source.indexOf("label: 'Horários'");
    final reviews = source.indexOf("label: 'Avaliações'");

    expect(prices, greaterThan(-1));
    expect(information, greaterThan(prices));
    expect(hours, greaterThan(information));
    expect(reviews, greaterThan(hours));
    expect(source, isNot(contains("text: 'Administração'")));
  });

  test('saída com alterações oferece continuar ou descartar', () {
    expect(source, contains('Continuar editando'));
    expect(source, contains('Descartar alterações'));
  });

  test('cada seção editável tem uma ação específica', () {
    expect(source, contains('Publicar preço'));
    expect(source, contains('Salvar informações'));
    expect(source, contains('Salvar horários'));
    expect(source, isNot(contains('Salvar alterações')));
    expect(source, isNot(contains('Publicar novos preços')));
  });
}
