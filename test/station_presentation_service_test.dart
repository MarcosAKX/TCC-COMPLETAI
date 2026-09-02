import 'dart:typed_data';

import 'package:completai_app/features/gas_station/models/station_presentation.dart';
import 'package:completai_app/features/gas_station/services/station_presentation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Uint8List jpeg([int marker = 0]) =>
      Uint8List.fromList([0xff, 0xd8, marker, 0xff, 0xd9]);

  test('carrega bandeira e capa do documento separado', () async {
    final cover = jpeg(1);
    final boundary = _FakeBoundary(
      stationData: const {'stationBrand': 'Petrobras'},
      coverBytes: cover,
    );
    final service = StationPresentationService.withBoundary(boundary);

    final result = await service.loadCurrent();

    expect(result.stationBrand, 'Petrobras');
    expect(result.coverImageBytes, same(cover));
    expect(boundary.events, ['load:station-1', 'cover:station-1']);
  });

  test('salvar só bandeira preserva bytes atuais', () async {
    final cover = jpeg(2);
    final boundary = _FakeBoundary(coverBytes: cover);
    final service = StationPresentationService.withBoundary(boundary);
    final current = await service.loadCurrent();
    boundary.events.clear();

    final result = await service.savePresentation(
      current: current,
      stationBrand: 'Shell',
    );

    expect(boundary.events, ['commit:station-1:null:Shell:false']);
    expect(result.coverImageBytes, same(cover));
    expect(result.stationBrand, 'Shell');
  });

  test('substitui capa com bytes JPEG normalizados', () async {
    final replacement = StationCoverImage(bytes: jpeg(3));
    final boundary = _FakeBoundary();
    final service = StationPresentationService.withBoundary(boundary);

    final result = await service.savePresentation(
      current: const StationPresentation(stationBrand: 'ALE'),
      stationBrand: 'Ipiranga',
      newCover: replacement,
    );

    expect(boundary.committedCoverBytes, same(replacement.bytes));
    expect(boundary.events, ['commit:station-1:5:Ipiranga:false']);
    expect(result.coverImageBytes, same(replacement.bytes));
  });

  test('remove capa e preserva bandeira', () async {
    final boundary = _FakeBoundary(coverBytes: jpeg(4));
    final service = StationPresentationService.withBoundary(boundary);

    final result = await service.removeCover(
      current: StationPresentation(
        coverImageBytes: boundary.coverBytes,
        stationBrand: 'ALE',
      ),
      stationBrand: 'RodOil',
    );

    expect(boundary.events, ['commit:station-1:null:RodOil:true']);
    expect(result.coverImageBytes, isNull);
  });

  test('propaga falha da transação sem perder seleção local', () async {
    final replacement = StationCoverImage(bytes: jpeg(5));
    final boundary = _FakeBoundary(throwOnCommit: true);
    final service = StationPresentationService.withBoundary(boundary);

    await expectLater(
      service.savePresentation(
        current: const StationPresentation(stationBrand: 'ALE'),
        stationBrand: 'Shell',
        newCover: replacement,
      ),
      throwsStateError,
    );
    expect(boundary.committedCoverBytes, same(replacement.bytes));
  });

  test('exige um posto autenticado', () async {
    final service = StationPresentationService.withBoundary(
      _FakeBoundary(currentUserId: null),
    );

    await expectLater(service.loadCurrent(), throwsStateError);
  });
}

class _FakeBoundary implements StationPresentationBoundary {
  _FakeBoundary({
    this.currentUserId = 'station-1',
    this.stationData = const {},
    this.coverBytes,
    this.throwOnCommit = false,
  });

  @override
  final String? currentUserId;
  final Map<String, dynamic> stationData;
  final Uint8List? coverBytes;
  final bool throwOnCommit;
  Uint8List? committedCoverBytes;
  final events = <String>[];

  @override
  Future<Map<String, dynamic>?> loadStation(String stationId) async {
    events.add('load:$stationId');
    return stationData;
  }

  @override
  Future<Uint8List?> loadCover(String stationId) async {
    events.add('cover:$stationId');
    return coverBytes;
  }

  @override
  Future<void> commitPresentation({
    required String stationId,
    required Uint8List? coverBytes,
    required String stationBrand,
    required bool removeCover,
  }) async {
    committedCoverBytes = coverBytes;
    events.add(
      'commit:$stationId:${coverBytes?.lengthInBytes}:$stationBrand:$removeCover',
    );
    if (throwOnCommit) throw StateError('transaction failed');
  }
}
