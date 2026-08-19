import 'package:flutter_test/flutter_test.dart';

import 'package:completai_app/features/gas_station/models/public_gas_station.dart';
import 'package:completai_app/features/user/models/station_discovery_filter.dart';

void main() {
  final moment = DateTime(2026, 8, 18, 12);

  test('ordena pelo combustível escolhido e deixa preço ausente no fim', () {
    final stations = [
      _station(id: 'high', gasoline: 6.10),
      _station(id: 'missing'),
      _station(id: 'low', gasoline: 5.49),
    ];

    final result = filterAndSortStations(
      stations,
      FuelChoice.gasoline,
      onlyOpen: false,
      moment: moment,
    );

    expect(result.map((station) => station.id), ['low', 'high', 'missing']);
  });

  test('filtra somente postos abertos no momento informado', () {
    final stations = [
      _station(id: 'open', gasoline: 5.49, open: true),
      _station(id: 'closed', gasoline: 5.39, open: false),
    ];

    final result = filterAndSortStations(
      stations,
      FuelChoice.gasoline,
      onlyOpen: true,
      moment: moment,
    );

    expect(result.single.id, 'open');
  });

  test('busca considera nome, bairro e serviços', () {
    final stations = [
      _station(id: 'target', name: 'Posto Avenida', services: ['Lavagem']),
      _station(id: 'other', name: 'Posto Central'),
    ];

    final result = filterAndSortStations(
      stations,
      FuelChoice.ethanol,
      onlyOpen: false,
      moment: moment,
      query: 'lavagem',
    );

    expect(result.single.id, 'target');
  });

  test('melhor valor ignora preço ausente e zero', () {
    final stations = [
      _station(id: 'zero', gasoline: 0),
      _station(id: 'best', gasoline: 5.49),
      _station(id: 'other', gasoline: 5.59),
    ];

    expect(bestPricedStationId(stations, FuelChoice.gasoline), 'best');
  });

  test('filtro de avaliação mantém somente postos com nota mínima', () {
    final stations = [
      _station(id: 'high-rating', gasoline: 5.69, rating: 4.6, reviews: 20),
      _station(id: 'low-rating', gasoline: 5.49, rating: 3.8, reviews: 20),
      _station(id: 'unrated', gasoline: 5.39),
    ];

    final result = filterAndSortStations(
      stations,
      FuelChoice.gasoline,
      onlyOpen: false,
      moment: moment,
      minimumRating: 4,
    );

    expect(result.map((station) => station.id), ['high-rating']);
  });

  test('economia compara o menor preço ao segundo menor preço válido', () {
    final stations = [
      _station(id: 'best', gasoline: 5.49),
      _station(id: 'second', gasoline: 5.59),
      _station(id: 'higher', gasoline: 5.89),
      _station(id: 'missing'),
    ];

    expect(
      savingsPerLiter(stations, FuelChoice.gasoline),
      closeTo(0.10, 0.001),
    );
  });
}

PublicGasStation _station({
  required String id,
  String name = 'Posto',
  double? gasoline,
  double? ethanol = 3.79,
  bool open = true,
  List<String> services = const [],
  double rating = 0,
  int reviews = 0,
}) {
  final prices = <String, double>{};
  if (gasoline != null) prices['gasolineRegular'] = gasoline;
  if (ethanol != null) prices['ethanol'] = ethanol;
  return PublicGasStation(
    id: id,
    name: name,
    phone: '',
    address: 'Rua A',
    neighborhood: 'Centro',
    city: 'Bebedouro',
    fuelPrices: prices,
    tags: const [],
    services: services,
    openingHours: {
      'tuesday': {'enabled': open, 'open': '00:00', 'close': '23:59'},
    },
    updatedAt: DateTime(2026, 8, 18, 11, 40),
    averageRating: rating,
    reviewCount: reviews,
  );
}
