import 'package:completai_app/core/theme/app_theme.dart';
import 'package:completai_app/features/gas_station/models/public_gas_station.dart';
import 'package:completai_app/features/gas_station/models/station_review.dart';
import 'package:completai_app/features/gas_station/views/station_profile_page.dart';
import 'package:completai_app/features/user/views/profile_page.dart';
import 'package:completai_app/features/user/views/public_station_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/adaptive_test_harness.dart';

const _longName = 'Posto Avenida das Palmeiras e Conveniência Bebedouro Centro';
const _longAddress =
    'Avenida Brigadeiro Faria Lima, 1234, Jardim das Laranjeiras e Palmeiras';

void main() {
  test('rota usa Google Maps com destino completo e modo carro', () async {
    Uri? openedUri;

    final opened = await openStationDirections(
      _station(),
      launcher: (uri) async {
        openedUri = uri;
        return true;
      },
    );

    expect(opened, isTrue);
    expect(openedUri?.scheme, 'https');
    expect(openedUri?.host, 'www.google.com');
    expect(openedUri?.path, '/maps/dir/');
    expect(openedUri?.queryParameters, {
      'api': '1',
      'destination':
          'Avenida Brigadeiro Faria Lima, 1234, Jardim das Laranjeiras e Palmeiras - Jardim das Laranjeiras e Palmeiras - Bebedouro, SP, Brasil',
      'travelmode': 'driving',
    });
    expect(openedUri?.queryParameters.containsKey('origin'), isFalse);
  });

  testWidgets('Como chegar dispara navegação e mantém alvo acessível', (
    tester,
  ) async {
    var directionsRequested = false;
    await pumpAdaptive(
      tester,
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: PublicStationProfileContent(
            station: _station(),
            reviews: [_review()],
            favoriteStream: Stream.value(false),
            onRefresh: () async {},
            onDirections: () => directionsRequested = true,
            onReview: () {},
            onToggleFavorite: (_) async {},
            onShowAllReviews: () {},
            onReportReview: (_) {},
            onReportStation: () {},
          ),
        ),
      ),
      adaptiveSmallPhone,
    );
    await tester.pump();

    final action = find.widgetWithText(FilledButton, 'Como chegar');
    await tester.dragUntilVisible(
      action,
      find.byType(Scrollable).first,
      const Offset(0, -220),
    );
    await Scrollable.ensureVisible(tester.element(action), alignment: 0.5);
    await tester.pump();

    expect(action.hitTestable(), findsOneWidget);
    expect(tester.getSize(action).height, greaterThanOrEqualTo(48));
    expect(find.byIcon(Icons.directions_outlined), findsOneWidget);
    await tester.tap(action);
    expect(directionsRequested, isTrue);
    expectNoLayoutExceptions(tester);
  });

  for (final scenario in [
    adaptiveSmallPhone,
    adaptiveLargeText,
    adaptiveLandscape,
  ]) {
    testWidgets('perfil do usuário preserva edição em ${scenario.name}', (
      tester,
    ) async {
      await pumpAdaptive(
        tester,
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ProfileContent(
              name: _longName,
              email: 'motorista.nome.muito.longo@example.com.br',
              phone: '(17) 99999-9999',
              onEditName: () {},
              onEditPhone: () {},
              onChangePassword: () {},
            ),
          ),
        ),
        scenario,
      );

      final passwordAction = find.byKey(
        const Key('profile-change-password-action'),
      );
      await tester.dragUntilVisible(
        passwordAction,
        find.byType(Scrollable).first,
        const Offset(0, -220),
      );
      await Scrollable.ensureVisible(
        tester.element(passwordAction),
        alignment: 0.5,
      );
      await tester.pump();

      expect(passwordAction, findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Alterar senha').hitTestable(),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.edit), findsNWidgets(2));
      expectNoLayoutExceptions(tester);
      if (scenario == adaptiveLargeText) {
        _expectFullyRendered(tester, find.text(_longName).first);
      }
    });

    testWidgets('perfil administrativo preserva campos em ${scenario.name}', (
      tester,
    ) async {
      await pumpAdaptive(
        tester,
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StationProfileContent(
              stationName: _longName,
              cnpj: '12.345.678/0001-90',
              phone: '(17) 3333-4444',
              email: 'administracao.posto@example.com.br',
              address: _longAddress,
              neighborhood: 'Jardim das Laranjeiras e Palmeiras',
              city: 'Bebedouro',
              onEditName: () {},
              onEditPhone: () {},
              onEditAddress: () {},
              onEditNeighborhood: () {},
              onEditCity: () {},
              onChangePassword: () {},
              onLogout: () {},
            ),
          ),
        ),
        scenario,
      );

      final passwordAction = find.byKey(
        const Key('station-profile-change-password-action'),
      );
      await tester.dragUntilVisible(
        passwordAction,
        find.byType(Scrollable).first,
        const Offset(0, -220),
      );
      await Scrollable.ensureVisible(
        tester.element(passwordAction),
        alignment: 0.5,
      );
      await tester.pump();

      expect(passwordAction, findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Alterar senha').hitTestable(),
        findsOneWidget,
      );
      final logoutAction = find.byKey(
        const Key('station-profile-logout-action'),
      );
      await Scrollable.ensureVisible(
        tester.element(logoutAction),
        alignment: 1,
      );
      await tester.pump();

      expect(find.text('Sair da conta'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Sair da conta')).dy,
        greaterThan(tester.getTopLeft(find.text('Alterar senha')).dy),
      );
      expect(logoutAction.hitTestable(), findsOneWidget);
      expect(tester.getSize(logoutAction).height, greaterThanOrEqualTo(48));
      expect(find.text(_longAddress), findsOneWidget);
      expectNoLayoutExceptions(tester);
      if (scenario == adaptiveLargeText) {
        _expectFullyRendered(tester, find.text(_longAddress));
      }
    });

    testWidgets('perfil público mantém dados e ações em ${scenario.name}', (
      tester,
    ) async {
      await pumpAdaptive(
        tester,
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: PublicStationProfileContent(
              station: _station(),
              reviews: [_review()],
              favoriteStream: Stream.value(false),
              onRefresh: () async {},
              onDirections: () {},
              onReview: () {},
              onToggleFavorite: (_) async {},
              onShowAllReviews: () {},
              onReportReview: (_) {},
              onReportStation: () {},
            ),
          ),
        ),
        scenario,
      );
      await tester.pump();

      final reportAction = find.byKey(
        const Key('public-profile-report-station-action'),
      );
      await tester.dragUntilVisible(
        reportAction,
        find.byType(Scrollable).first,
        const Offset(0, -220),
      );
      await Scrollable.ensureVisible(
        tester.element(reportAction),
        alignment: 0.5,
      );
      await tester.pump();

      expect(reportAction, findsOneWidget);
      expect(
        find
            .widgetWithText(TextButton, 'Reportar problema com este posto')
            .hitTestable(),
        findsOneWidget,
      );
      expect(find.text('Avaliar'), findsOneWidget);
      expect(find.text('Características do posto'), findsOneWidget);
      expect(find.text('Serviços no local'), findsOneWidget);
      expect(find.byKey(const Key('station-visual-cover')), findsOneWidget);
      expect(find.text('SHELL'), findsOneWidget);
      expect(find.text('Combustíveis disponíveis'), findsOneWidget);
      expect(find.text('Endereço e rota'), findsOneWidget);
      expect(
        find.text('Prévia ilustrativa. A rota será calculada no mapa.'),
        findsOneWidget,
      );
      expect(find.text('Horários de funcionamento'), findsOneWidget);
      expect(find.text('Resumo das avaliações'), findsOneWidget);
      expect(find.textContaining(_longAddress), findsWidgets);
      expectNoLayoutExceptions(tester);
      if (scenario == adaptiveLargeText) {
        _expectFullyRendered(tester, find.text(_longName).first);
      }
    });
  }

  testWidgets('sheet de senha mantém ação acima do teclado em texto 2,0×', (
    tester,
  ) async {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirmation = TextEditingController();
    addTearDown(current.dispose);
    addTearDown(next.dispose);
    addTearDown(confirmation.dispose);

    await pumpAdaptive(
      tester,
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => ProfilePasswordSheet(
                  currentPasswordController: current,
                  newPasswordController: next,
                  confirmationController: confirmation,
                  onSave: () {},
                ),
              ),
              child: const Text('Abrir senha'),
            ),
          ),
        ),
      ),
      const AdaptiveTestScenario(
        name: '360x800 @ 2.0 com teclado',
        size: Size(360, 800),
        textScaleFactor: 2,
        viewInsets: EdgeInsets.only(bottom: 280),
      ),
    );

    await tester.tap(find.text('Abrir senha'));
    await tester.pumpAndSettle();

    final save = find.byKey(const Key('profile-password-save-action'));
    await Scrollable.ensureVisible(tester.element(save), alignment: 1);
    await tester.pump();
    expect(save.hitTestable(), findsOneWidget);
    expectNoLayoutExceptions(tester);
  });

  testWidgets('sheet de senha do usuário cabe acima do teclado em paisagem', (
    tester,
  ) async {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirmation = TextEditingController();
    addTearDown(current.dispose);
    addTearDown(next.dispose);
    addTearDown(confirmation.dispose);

    await _pumpPasswordSheet(
      tester,
      child: ProfilePasswordSheet(
        currentPasswordController: current,
        newPasswordController: next,
        confirmationController: confirmation,
        onSave: () {},
      ),
    );

    final sheet = find.byKey(const Key('profile-password-sheet'));
    expect(tester.getTopLeft(sheet).dy, greaterThanOrEqualTo(0));
    expect(tester.getBottomRight(sheet).dy, lessThanOrEqualTo(80));
    final save = find.widgetWithText(ElevatedButton, 'Salvar nova senha');
    await Scrollable.ensureVisible(tester.element(save), alignment: 1);
    await tester.pump();
    expect(save.hitTestable(), findsOneWidget);
    expect(tester.getSemantics(save).label, contains('Salvar nova senha'));
    expectNoLayoutExceptions(tester);
  });

  testWidgets('sheet de senha do posto cabe e mantém ação acessível', (
    tester,
  ) async {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirmation = TextEditingController();
    addTearDown(current.dispose);
    addTearDown(next.dispose);
    addTearDown(confirmation.dispose);

    await _pumpPasswordSheet(
      tester,
      child: StationPasswordSheet(
        currentPasswordController: current,
        newPasswordController: next,
        confirmationController: confirmation,
        onSave: () {},
      ),
    );

    final sheet = find.byKey(const Key('station-password-sheet'));
    expect(tester.getTopLeft(sheet).dy, greaterThanOrEqualTo(0));
    expect(tester.getBottomRight(sheet).dy, lessThanOrEqualTo(80));
    final save = find.widgetWithText(ElevatedButton, 'Salvar nova senha');
    await Scrollable.ensureVisible(tester.element(save), alignment: 1);
    await tester.pump();
    expect(save.hitTestable(), findsOneWidget);
    expect(tester.getSemantics(save).label, contains('Salvar nova senha'));
    expectNoLayoutExceptions(tester);
  });

  testWidgets('diálogos públicos mantêm última ação acessível em texto 2,0×', (
    tester,
  ) async {
    await _pumpDialogLauncher(tester, child: const StationReviewDialog());
    expect(
      find.widgetWithText(FilledButton, 'Publicar').hitTestable(),
      findsOne,
    );
    expectNoLayoutExceptions(tester);

    await _pumpDialogLauncher(tester, child: const StationReportDialog());
    expect(
      find.widgetWithText(FilledButton, 'Enviar reporte').hitTestable(),
      findsOne,
    );
    expectNoLayoutExceptions(tester);
  });

  testWidgets('sheets de avaliações permitem alcançar a última opção', (
    tester,
  ) async {
    await _pumpSheetLauncher(tester, child: const ReviewReportSheet());
    final lastReason = find.text('Outro');
    await tester.dragUntilVisible(
      lastReason,
      find.byType(Scrollable).last,
      const Offset(0, -160),
    );
    await tester.pump();
    expect(lastReason.hitTestable(), findsOneWidget);
    expectNoLayoutExceptions(tester);

    await _pumpSheetLauncher(
      tester,
      child: AllReviewsSheet(
        reviews: List.generate(4, (_) => _review()),
        onReport: (_) {},
      ),
    );
    final lastReport = find.byTooltip('Denunciar avaliação').last;
    await tester.dragUntilVisible(
      lastReport,
      find.byType(Scrollable).last,
      const Offset(0, -220),
    );
    await tester.pump();
    expect(lastReport.hitTestable(), findsOneWidget);
    expectNoLayoutExceptions(tester);
  });
}

Future<void> _pumpDialogLauncher(
  WidgetTester tester, {
  required Widget child,
}) async {
  await pumpAdaptive(
    tester,
    MaterialApp(
      key: UniqueKey(),
      theme: AppTheme.lightTheme,
      home: Builder(
        builder: (context) => Scaffold(
          body: FilledButton(
            onPressed: () =>
                showDialog<void>(context: context, builder: (_) => child),
            child: const Text('Abrir diálogo'),
          ),
        ),
      ),
    ),
    adaptiveLargeText,
  );
  await tester.tap(find.widgetWithText(FilledButton, 'Abrir diálogo'));
  await tester.pumpAndSettle();
}

Future<void> _pumpSheetLauncher(
  WidgetTester tester, {
  required Widget child,
}) async {
  await pumpAdaptive(
    tester,
    MaterialApp(
      key: UniqueKey(),
      theme: AppTheme.lightTheme,
      home: Builder(
        builder: (context) => Scaffold(
          body: FilledButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => child,
            ),
            child: const Text('Abrir sheet'),
          ),
        ),
      ),
    ),
    adaptiveLargeText,
  );
  await tester.tap(find.widgetWithText(FilledButton, 'Abrir sheet'));
  await tester.pumpAndSettle();
}

Future<void> _pumpPasswordSheet(
  WidgetTester tester, {
  required Widget child,
}) async {
  await pumpAdaptive(
    tester,
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: Builder(
        builder: (context) => Scaffold(
          body: FilledButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => child,
            ),
            child: const Text('Abrir senha em paisagem'),
          ),
        ),
      ),
    ),
    const AdaptiveTestScenario(
      name: '640x360 @ 1.3 com teclado',
      size: Size(640, 360),
      textScaleFactor: 1.3,
      viewInsets: EdgeInsets.only(bottom: 280),
    ),
  );
  await tester.tap(find.text('Abrir senha em paisagem'));
  await tester.pumpAndSettle();
}

void _expectFullyRendered(WidgetTester tester, Finder finder) {
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  expect(paragraph.didExceedMaxLines, isFalse);
}

PublicGasStation _station() {
  return PublicGasStation(
    id: 'station-profile-adaptive',
    name: _longName,
    phone: '(17) 3333-4444',
    address: _longAddress,
    neighborhood: 'Jardim das Laranjeiras e Palmeiras',
    city: 'Bebedouro',
    fuelPrices: const {
      'gasolineRegular': 5.79,
      'ethanol': 3.89,
      'dieselS10': 5.99,
    },
    tags: const ['24 horas', 'Aceita cartões'],
    services: const ['Conveniência', 'Troca de óleo'],
    openingHours: const {},
    updatedAt: null,
    averageRating: 4.8,
    reviewCount: 12,
    stationBrand: 'Shell',
  );
}

StationReview _review() {
  return const StationReview(
    id: 'review-adaptive',
    userId: 'user-adaptive',
    authorName: 'Motorista com nome muito longo para o cabeçalho',
    rating: 5,
    comment:
        'Atendimento cuidadoso e informações claras sobre todos os preços.',
    createdAt: null,
    updatedAt: null,
  );
}
