import 'dart:typed_data';

import 'dart:math' as math;
import 'package:image/image.dart' as img;

const stationBrandOptions = <String>[
  'Shell',
  'Ipiranga',
  'Petrobras',
  'ALE',
  'RodOil',
  'Bandeira branca',
  'Outra',
];

class StationPresentation {
  const StationPresentation({this.coverImageBytes, required this.stationBrand});

  final Uint8List? coverImageBytes;
  final String stationBrand;

  factory StationPresentation.fromMap(Map<String, dynamic> data) {
    final rawBrand = data['stationBrand'];
    return StationPresentation(
      stationBrand:
          rawBrand is String &&
              rawBrand.trim().length >= 2 &&
              rawBrand.trim().length <= 60
          ? rawBrand.trim()
          : 'Bandeira branca',
    );
  }
}

class StationCoverImage {
  const StationCoverImage({required this.bytes});

  final Uint8List bytes;

  int get byteSize => bytes.lengthInBytes;
  String get contentType => StationCoverProcessor.contentType;
}

abstract final class StationCoverProcessor {
  static const maxInputBytes = 5 * 1024 * 1024;
  static const maxOutputBytes = 500 * 1024;
  static const maxDimension = 1280;
  static const contentType = 'image/jpeg';

  static StationCoverImage normalize({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
  }) {
    if (bytes.isEmpty || bytes.lengthInBytes > maxInputBytes) {
      throw ArgumentError('A imagem original deve ter no máximo 5 MB.');
    }

    final name = fileName.trim().toLowerCase();
    final type = (mimeType ?? '').trim().toLowerCase();
    final expectedType = name.endsWith('.jpg') || name.endsWith('.jpeg')
        ? 'image/jpeg'
        : name.endsWith('.png')
        ? 'image/png'
        : name.endsWith('.webp')
        ? 'image/webp'
        : null;
    if (expectedType == null || (type.isNotEmpty && type != expectedType)) {
      throw ArgumentError('Use uma imagem JPG, PNG ou WebP.');
    }

    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw ArgumentError('Não foi possível ler a imagem.');
    }

    var working = img.bakeOrientation(decoded);
    final largest = math.max(working.width, working.height);
    if (largest > maxDimension) {
      working = working.width >= working.height
          ? img.copyResize(working, width: maxDimension)
          : img.copyResize(working, height: maxDimension);
    }

    while (true) {
      for (final quality in const [82, 72, 62, 52, 42]) {
        final encoded = img.encodeJpg(working, quality: quality);
        if (encoded.lengthInBytes <= maxOutputBytes) {
          return StationCoverImage(bytes: encoded);
        }
      }

      final currentLargest = math.max(working.width, working.height);
      if (currentLargest <= 320) break;
      working = img.copyResize(
        working,
        width: math.max(1, (working.width * .85).round()),
        height: math.max(1, (working.height * .85).round()),
      );
    }

    throw ArgumentError('Não foi possível reduzir a foto para 500 KB.');
  }
}

String normalizeStationBrand(String selection, String customName) {
  if (!stationBrandOptions.contains(selection)) {
    throw ArgumentError('Selecione uma bandeira válida.');
  }
  final value = selection == 'Outra' ? customName.trim() : selection;
  if (value.length < 2 || value.length > 60) {
    throw ArgumentError('Informe uma bandeira entre 2 e 60 caracteres.');
  }
  return value;
}
