import 'dart:async';
import 'dart:typed_data';

import 'package:completai_app/core/theme/app_theme.dart';
import 'package:completai_app/features/gas_station/models/station_presentation.dart';
import 'package:completai_app/features/gas_station/services/station_presentation_service.dart';
import 'package:completai_app/features/gas_station/views/station_presentation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import 'helpers/adaptive_test_harness.dart';

void main() {
  Widget app(Widget child) => MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(body: child),
  );

  testWidgets('edição permite escolher bandeira e salvar em largura compacta', (
    tester,
  ) async {
    String? savedBrand;
    await pumpAdaptive(
      tester,
      app(
        StationPresentationContent(
          initialPresentation: const StationPresentation(
            stationBrand: 'Bandeira branca',
          ),
          initialCoverUrl: null,
          selectedCoverBytes: null,
          isSaving: false,
          onPickCover: () async {},
          onRemoveCover: () {},
          onSave: (brand) async => savedBrand = brand,
        ),
      ),
      adaptiveSmallPhone,
    );

    expect(find.text('Editar exibição'), findsOneWidget);
    expect(find.text('Selecionar foto'), findsOneWidget);
    await tester.tap(find.byKey(const Key('station-brand-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shell').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Salvar exibição'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar exibição'));
    await tester.pump();

    expect(savedBrand, 'Shell');
    expectNoLayoutExceptions(tester);
  });

  testWidgets(
    'bandeira salva fora da lista inicia como Outra e é normalizada',
    (tester) async {
      String? savedBrand;
      await pumpAdaptive(
        tester,
        app(
          StationPresentationContent(
            initialPresentation: const StationPresentation(
              stationBrand: '  Rede Regional  ',
            ),
            initialCoverUrl: null,
            selectedCoverBytes: null,
            isSaving: false,
            onPickCover: () async {},
            onRemoveCover: () {},
            onSave: (brand) async => savedBrand = brand,
          ),
        ),
        adaptiveLargeText,
      );

      final selector = tester.widget<DropdownButtonFormField<String>>(
        find.byKey(const Key('station-brand-selector')),
      );
      expect(selector.initialValue, 'Outra');
      expect(
        find.widgetWithText(TextFormField, 'Rede Regional'),
        findsOneWidget,
      );

      await tester.ensureVisible(find.text('Salvar exibição'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar exibição'));
      await tester.pump();

      expect(savedBrand, 'Rede Regional');
      expectNoLayoutExceptions(tester);
    },
  );

  testWidgets('prévia local usa bytes e remoção fica disponível', (
    tester,
  ) async {
    var removeCount = 0;
    final bytes = Uint8List.fromList(const [0, 1, 2, 3]);
    await pumpAdaptive(
      tester,
      app(
        StationPresentationContent(
          initialPresentation: const StationPresentation(
            stationBrand: 'Ipiranga',
          ),
          initialCoverUrl: 'https://example.invalid/persisted.jpg',
          selectedCoverBytes: bytes,
          isSaving: false,
          onPickCover: () async {},
          onRemoveCover: () => removeCount++,
          onSave: (_) async {},
        ),
      ),
      adaptiveSmallPhone,
    );

    expect(find.byType(Image), findsOneWidget);
    expect(tester.widget<Image>(find.byType(Image)).image, isA<MemoryImage>());
    expect(find.text('Substituir foto'), findsOneWidget);
    expect(find.text('Remover foto'), findsOneWidget);

    await tester.ensureVisible(find.text('Remover foto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remover foto'));
    expect(removeCount, 1);
    expectNoLayoutExceptions(tester);
  });

  for (final scenario in [
    adaptiveSmallPhone,
    adaptiveLargeText,
    adaptiveLandscape,
  ]) {
    testWidgets('conteúdo de exibição reflui em ${scenario.name}', (
      tester,
    ) async {
      await pumpAdaptive(
        tester,
        app(
          StationPresentationContent(
            initialPresentation: const StationPresentation(
              stationBrand: 'Bandeira branca',
            ),
            initialCoverUrl: null,
            selectedCoverBytes: null,
            isSaving: false,
            onPickCover: () async {},
            onRemoveCover: () {},
            onSave: (_) async {},
          ),
        ),
        scenario,
      );

      expect(find.byType(Scrollable), findsWidgets);
      expectNoLayoutExceptions(tester);
      expect(
        tester
            .getSize(find.widgetWithText(OutlinedButton, 'Selecionar foto'))
            .height,
        greaterThanOrEqualTo(48),
      );
    });
  }

  testWidgets('salvar bandeira na página real retorna true à rota chamadora', (
    tester,
  ) async {
    final boundary = _PageBoundary();
    final service = StationPresentationService.withBoundary(boundary);
    final imagePicker = _FakeImagePicker();
    bool? result;

    await pumpAdaptive(
      tester,
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute<bool>(
                    builder: (_) => StationPresentationPage(
                      service: service,
                      imagePicker: imagePicker,
                    ),
                  ),
                );
              },
              child: const Text('Abrir edição'),
            ),
          ),
        ),
      ),
      adaptiveSmallPhone,
    );

    await tester.tap(find.text('Abrir edição'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Selecionar foto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Selecionar foto'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('station-brand-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shell').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Salvar exibição'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar exibição'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(boundary.committedBrands, ['Shell']);
    expect(find.text('Editar exibição'), findsNothing);
    expectNoLayoutExceptions(tester);
  });

  testWidgets('descartar alteração suja fecha a página sem reabrir o diálogo', (
    tester,
  ) async {
    final service = StationPresentationService.withBoundary(_PageBoundary());
    bool routeReturned = false;

    await pumpAdaptive(
      tester,
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => StationPresentationPage(service: service),
                  ),
                );
                routeReturned = true;
              },
              child: const Text('Abrir edição'),
            ),
          ),
        ),
      ),
      adaptiveSmallPhone,
    );

    await tester.tap(find.text('Abrir edição'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('station-brand-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shell').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Descartar alterações?'), findsOneWidget);
    await tester.tap(find.text('Descartar alterações'));
    await tester.pumpAndSettle();

    expect(routeReturned, isTrue);
    expect(find.text('Descartar alterações?'), findsNothing);
    expect(find.text('Editar exibição'), findsNothing);
    expectNoLayoutExceptions(tester);
  });

  testWidgets('timeout encerra spinner e permite tentar novamente', (
    tester,
  ) async {
    final service = StationPresentationService.withBoundary(
      _PageBoundary(neverComplete: true),
    );
    await pumpAdaptive(
      tester,
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: StationPresentationPage(service: service),
      ),
      adaptiveSmallPhone,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('station-brand-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shell').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Salvar exibição'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar exibição'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 21));

    expect(
      find.text('A operação demorou demais. Tente novamente.'),
      findsWidgets,
    );
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Salvar exibição'),
    );
    expect(button.onPressed, isNotNull);
  });
}

class _PageBoundary implements StationPresentationBoundary {
  _PageBoundary({this.neverComplete = false});

  @override
  final String? currentUserId = 'station-test';
  final stationBrand = 'Bandeira branca';
  final committedBrands = <String>[];
  final bool neverComplete;

  @override
  Future<Map<String, dynamic>?> loadStation(String stationId) async => {
    'stationBrand': stationBrand,
  };

  @override
  Future<Uint8List?> loadCover(String stationId) async => null;

  @override
  Future<void> commitPresentation({
    required String stationId,
    required Uint8List? coverBytes,
    required String stationBrand,
    required bool removeCover,
  }) async {
    if (neverComplete) await Completer<void>().future;
    committedBrands.add(stationBrand);
  }
}

class _FakeImagePicker extends ImagePicker {
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    final image = img.Image(width: 8, height: 8);
    img.fill(image, color: img.ColorRgb8(40, 120, 80));
    return XFile.fromData(
      Uint8List.fromList(img.encodePng(image)),
      path: 'new.png',
      name: 'new.png',
      mimeType: 'image/png',
    );
  }
}
