import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:completai_app/features/gas_station/models/public_gas_station.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'lê apresentação opcional e mantém compatibilidade com documento antigo',
    () {
      final station = PublicGasStation.fromDocument(
        _DocumentSnapshot('station-1', const {
          'name': 'Posto Avenida',
          'coverImagePath': 'station_covers/station-1/cover_1.jpg',
          'stationBrand': 'Shell',
        }),
      );
      final oldStation = PublicGasStation.fromDocument(
        _DocumentSnapshot('station-old', const {'name': 'Posto Antigo'}),
      );

      expect(station.stationBrand, 'Shell');
      expect(station.coverImageBytes, isNull);
      expect(oldStation.coverImageBytes, isNull);
      expect(oldStation.stationBrand, 'Bandeira branca');
    },
  );

  test('preserva apresentação ao atualizar avaliação e bytes da capa', () {
    final station = PublicGasStation.fromDocument(
      _DocumentSnapshot('station-1', const {
        'name': 'Posto Avenida',
        'coverImagePath': 'station_covers/station-1/cover_1.jpg',
        'stationBrand': 'Shell',
      }),
    );

    final bytes = Uint8List.fromList([0xff, 0xd8, 0xff, 0xd9]);
    final covered = station.withCoverImageBytes(bytes);
    final rated = covered.withRating(average: 4.5, count: 6);

    expect(rated.stationBrand, 'Shell');
    expect(rated.coverImageBytes, same(bytes));
    expect(rated.averageRating, 4.5);
    expect(rated.reviewCount, 6);
  });

  test('preserva nome personalizado selecionado como Outra', () {
    final station = PublicGasStation.fromDocument(
      _DocumentSnapshot('station-unknown', const {
        'name': 'Posto Desconhecido',
        'stationBrand': 'Rede Regional',
      }),
    );

    expect(station.stationBrand, 'Rede Regional');
  });

  test('normaliza bandeira com mais de 60 caracteres para Bandeira branca', () {
    final station = PublicGasStation.fromDocument(
      _DocumentSnapshot('station-too-long', {
        'name': 'Posto Longo',
        'stationBrand': 'a' * 61,
      }),
    );

    expect(station.stationBrand, 'Bandeira branca');
  });
}

// ignore: subtype_of_sealed_class
class _DocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  const _DocumentSnapshot(this.id, this._data);

  @override
  final String id;
  final Map<String, dynamic> _data;

  @override
  bool get exists => true;

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
  DocumentReference<Map<String, dynamic>> get reference =>
      throw UnimplementedError();

  @override
  Map<String, dynamic> data() => _data;

  @override
  dynamic get(Object field) => _data[field];

  @override
  dynamic operator [](Object field) => get(field);
}
