import 'dart:typed_data';

import 'package:completai_app/features/gas_station/models/station_presentation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('normaliza PNG para JPEG de até 500 KiB e 1280 px', () {
    final source = img.Image(width: 1800, height: 1200);
    img.fill(source, color: img.ColorRgb8(20, 120, 220));

    final result = StationCoverProcessor.normalize(
      bytes: Uint8List.fromList(img.encodePng(source)),
      fileName: 'posto.png',
      mimeType: 'image/png',
    );

    final decoded = img.decodeJpg(result.bytes)!;
    expect(result.contentType, 'image/jpeg');
    expect(result.bytes.lengthInBytes, lessThanOrEqualTo(500 * 1024));
    expect(decoded.width, 1280);
    expect(decoded.height, 853);
  });

  test('normaliza entradas JPEG e WebP para JPEG', () {
    final source = img.Image(width: 32, height: 24);
    img.fill(source, color: img.ColorRgb8(220, 80, 30));
    final inputs = [
      ('capa.jpg', 'image/jpeg', img.encodeJpg(source)),
      ('capa.webp', 'image/webp', img.encodeWebP(source)),
    ];

    for (final input in inputs) {
      final result = StationCoverProcessor.normalize(
        bytes: Uint8List.fromList(input.$3),
        fileName: input.$1,
        mimeType: input.$2,
      );
      expect(img.decodeJpg(result.bytes), isNotNull);
      expect(result.byteSize, lessThanOrEqualTo(500 * 1024));
    }
  });

  test('rejeita bytes inválidos, tamanho excessivo e MIME incompatível', () {
    expect(
      () => StationCoverProcessor.normalize(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'capa.jpg',
        mimeType: 'image/jpeg',
      ),
      throwsArgumentError,
    );
    expect(
      () => StationCoverProcessor.normalize(
        bytes: Uint8List(5 * 1024 * 1024 + 1),
        fileName: 'capa.jpg',
        mimeType: 'image/jpeg',
      ),
      throwsArgumentError,
    );
    expect(
      () => StationCoverProcessor.normalize(
        bytes: Uint8List.fromList(
          img.encodePng(img.Image(width: 2, height: 2)),
        ),
        fileName: 'capa.png',
        mimeType: 'image/jpeg',
      ),
      throwsArgumentError,
    );
  });

  test('normaliza lista conhecida e exige nome quando Outra', () {
    expect(normalizeStationBrand('Shell', ''), 'Shell');
    expect(
      normalizeStationBrand('Outra', '  Posto Regional  '),
      'Posto Regional',
    );
    expect(() => normalizeStationBrand('Outra', ' '), throwsArgumentError);
    expect(
      () => normalizeStationBrand('Outra', List<String>.filled(61, 'x').join()),
      throwsArgumentError,
    );
  });

  test('documento antigo usa apresentação padrão', () {
    final presentation = StationPresentation.fromMap(const {});
    expect(presentation.coverImageBytes, isNull);
    expect(presentation.stationBrand, 'Bandeira branca');
  });
}
