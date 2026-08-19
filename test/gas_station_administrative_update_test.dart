import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/gas_station/services/gas_station_service.dart',
    ).readAsStringSync();
  });

  test('serviço expõe atualização parcial de preços', () {
    expect(source, contains('Future<void> updateFuelPrices('));
  });

  test('serviço expõe atualização parcial de informações', () {
    expect(source, contains('Future<void> updateStationInformation('));
  });

  test('serviço expõe atualização parcial de horários', () {
    expect(source, contains('Future<void> updateOpeningHours('));
  });

  test('serviço não mantém salvamento administrativo agregado', () {
    expect(source, isNot(contains('Future<void> updateAdministrativeData(')));
  });
}
