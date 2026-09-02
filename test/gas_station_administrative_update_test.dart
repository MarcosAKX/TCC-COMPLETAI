import 'dart:io';

import 'package:completai_app/features/gas_station/services/gas_station_service.dart';
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

  test('perfil público preserva bandeira e omite caminho legado da capa', () {
    final result = buildPublicStationPresentationFields(const {
      'coverImagePath': 'station_covers/station-1/cover_1.jpg',
      'stationBrand': 'Shell',
    });
    expect(result, {'stationBrand': 'Shell'});
    expect(buildPublicStationPresentationFields(const {}), isEmpty);
  });

  test('patch público existente omite apresentação capturada', () {
    final result = buildExistingPublicStationUpdateFields(const {
      'fuelPrices': {'ethanol': 3.79},
      'coverImagePath': 'station_covers/station-1/cover_10.jpg',
      'stationBrand': 'Shell',
    });

    expect(result, const {
      'fuelPrices': {'ethanol': 3.79},
    });
  });

  test('updates administrativos decidem projeção dentro de transação', () {
    final administrativeUpdate = source.substring(
      source.indexOf('Future<void> _updateAdministrativeFields('),
      source.indexOf('Stream<List<StationReview>> watchCurrentStationReviews'),
    );
    final stationFieldUpdate = source.substring(
      source.indexOf('Future<void> updateStationField('),
      source.indexOf(
        'DocumentReference<Map<String, dynamic>> _currentStationReference()',
      ),
    );

    for (final method in [administrativeUpdate, stationFieldUpdate]) {
      expect(method, contains('_firestore.runTransaction'));
      expect(method, contains('transaction.get(privateReference)'));
      expect(method, contains('transaction.get(publicReference)'));
    }
  });
}
