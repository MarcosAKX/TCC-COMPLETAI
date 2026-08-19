import 'package:flutter_test/flutter_test.dart';

import 'package:completai_app/features/gas_station/models/station_dashboard_draft.dart';

void main() {
  late StationDashboardDraft draft;

  setUp(() {
    draft = StationDashboardDraft(
      prices: const {'gasolineRegular': '5,499'},
      tags: const {'24 horas'},
      services: const {'Conveniência'},
      openingHours: const {
        'monday': {'enabled': true, 'open': '06:00', 'close': '22:00'},
      },
    );
  });

  test('começa sem alterações pendentes', () {
    expect(draft.hasPriceChanges, isFalse);
    expect(draft.hasInformationChanges, isFalse);
    expect(draft.hasOpeningHourChanges, isFalse);
  });

  test('detecta mudança apenas na seção de preços', () {
    draft.setPrice('gasolineRegular', '5.599');

    expect(draft.hasPriceChanges, isTrue);
    expect(draft.hasInformationChanges, isFalse);
    expect(draft.hasOpeningHourChanges, isFalse);
  });

  test('ignora ordem de tags e serviços', () {
    draft.replaceInformation(
      tags: const {'Aceita Pix', '24 horas'},
      services: const {'Calibragem', 'Conveniência'},
    );
    draft.markInformationSaved();
    draft.replaceInformation(
      tags: const {'24 horas', 'Aceita Pix'},
      services: const {'Conveniência', 'Calibragem'},
    );

    expect(draft.hasInformationChanges, isFalse);
  });

  test('restaura somente a seção solicitada', () {
    draft.setPrice('gasolineRegular', '6,000');
    draft.replaceInformation(tags: const {}, services: const {});

    draft.restorePrices();

    expect(draft.priceFor('gasolineRegular'), '5,499');
    expect(draft.hasPriceChanges, isFalse);
    expect(draft.hasInformationChanges, isTrue);
  });

  test('detecta e salva alteração aninhada de horário', () {
    draft.replaceOpeningHours(const {
      'monday': {'enabled': true, 'open': '07:00', 'close': '22:00'},
    });
    expect(draft.hasOpeningHourChanges, isTrue);

    draft.markOpeningHoursSaved();
    expect(draft.hasOpeningHourChanges, isFalse);
  });
}
