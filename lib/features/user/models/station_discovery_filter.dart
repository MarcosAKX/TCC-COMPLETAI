import '../../gas_station/models/public_gas_station.dart';

enum FuelChoice { gasoline, ethanol, diesel }

extension FuelChoiceDetails on FuelChoice {
  String get fuelKey => switch (this) {
    FuelChoice.gasoline => 'gasolineRegular',
    FuelChoice.ethanol => 'ethanol',
    FuelChoice.diesel => 'dieselS10',
  };

  String get label => switch (this) {
    FuelChoice.gasoline => 'Gasolina',
    FuelChoice.ethanol => 'Etanol',
    FuelChoice.diesel => 'Diesel',
  };

  String get priceLabel => switch (this) {
    FuelChoice.gasoline => 'Gasolina comum',
    FuelChoice.ethanol => 'Etanol',
    FuelChoice.diesel => 'Diesel S10',
  };
}

List<PublicGasStation> filterAndSortStations(
  List<PublicGasStation> stations,
  FuelChoice fuel, {
  required bool onlyOpen,
  required DateTime moment,
  String query = '',
  double? minimumRating,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final filtered = stations.where((station) {
    if (onlyOpen && !station.isOpenAt(moment)) return false;
    if (minimumRating != null && station.averageRating < minimumRating) {
      return false;
    }
    if (normalizedQuery.isEmpty) return true;
    final searchable = [
      station.name,
      station.address,
      station.neighborhood,
      station.city,
      ...station.tags,
      ...station.services,
    ].join(' ').toLowerCase();
    return searchable.contains(normalizedQuery);
  }).toList();

  filtered.sort((a, b) {
    final aPrice = _validPrice(a.fuelPrices[fuel.fuelKey]);
    final bPrice = _validPrice(b.fuelPrices[fuel.fuelKey]);
    if (aPrice == null && bPrice == null) {
      return b.rankingScore.compareTo(a.rankingScore);
    }
    if (aPrice == null) return 1;
    if (bPrice == null) return -1;
    final priceComparison = aPrice.compareTo(bPrice);
    return priceComparison != 0
        ? priceComparison
        : b.rankingScore.compareTo(a.rankingScore);
  });
  return filtered;
}

String? bestPricedStationId(List<PublicGasStation> stations, FuelChoice fuel) {
  PublicGasStation? best;
  double? bestPrice;
  for (final station in stations) {
    final price = _validPrice(station.fuelPrices[fuel.fuelKey]);
    if (price == null) continue;
    if (bestPrice == null || price < bestPrice) {
      bestPrice = price;
      best = station;
    }
  }
  return best?.id;
}

double? savingsPerLiter(List<PublicGasStation> stations, FuelChoice fuel) {
  final prices =
      stations
          .map((station) => _validPrice(station.fuelPrices[fuel.fuelKey]))
          .whereType<double>()
          .toSet()
          .toList()
        ..sort();
  if (prices.length < 2) return null;
  final savings = prices[1] - prices[0];
  return savings > 0 ? savings : null;
}

double? _validPrice(double? price) => price != null && price > 0 ? price : null;
