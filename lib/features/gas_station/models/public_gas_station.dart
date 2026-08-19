import 'package:cloud_firestore/cloud_firestore.dart';

class PublicGasStation {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String neighborhood;
  final String city;
  final Map<String, double> fuelPrices;
  final List<String> tags;
  final List<String> services;
  final Map<String, Map<String, dynamic>> openingHours;
  final DateTime? updatedAt;
  final double averageRating;
  final int reviewCount;

  const PublicGasStation({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.neighborhood,
    required this.city,
    required this.fuelPrices,
    required this.tags,
    required this.services,
    required this.openingHours,
    required this.updatedAt,
    this.averageRating = 0,
    this.reviewCount = 0,
  });

  factory PublicGasStation.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document, {
    double averageRating = 0,
    int reviewCount = 0,
  }) {
    final data = document.data() ?? const <String, dynamic>{};
    final rawPrices = data['fuelPrices'];
    final rawHours = data['openingHours'];
    final rawUpdatedAt = data['updatedAt'];

    return PublicGasStation(
      id: document.id,
      name: _string(data['name'], 'Posto sem nome'),
      phone: _string(data['phone']),
      address: _string(data['address']),
      neighborhood: _string(data['neighborhood']),
      city: _string(data['city']),
      fuelPrices: rawPrices is Map
          ? rawPrices.map(
              (key, value) =>
                  MapEntry(key.toString(), value is num ? value.toDouble() : 0),
            )
          : const {},
      tags: _stringList(data['tags']),
      services: _stringList(data['services']),
      openingHours: rawHours is Map
          ? rawHours.map(
              (key, value) => MapEntry(
                key.toString(),
                value is Map
                    ? Map<String, dynamic>.from(value)
                    : <String, dynamic>{},
              ),
            )
          : const {},
      updatedAt: rawUpdatedAt is Timestamp ? rawUpdatedAt.toDate() : null,
      averageRating: averageRating,
      reviewCount: reviewCount,
    );
  }

  PublicGasStation withRating({required double average, required int count}) {
    return PublicGasStation(
      id: id,
      name: name,
      phone: phone,
      address: address,
      neighborhood: neighborhood,
      city: city,
      fuelPrices: fuelPrices,
      tags: tags,
      services: services,
      openingHours: openingHours,
      updatedAt: updatedAt,
      averageRating: average,
      reviewCount: count,
    );
  }

  String get fullAddress {
    return [
      address,
      neighborhood,
      city,
    ].where((part) => part.trim().isNotEmpty).join(' - ');
  }

  bool isOpenAt(DateTime moment) {
    const dayKeys = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final day = openingHours[dayKeys[moment.weekday - 1]];
    if (day == null || day['enabled'] != true) return false;

    final openMinutes = _minutes(day['open']);
    final closeMinutes = _minutes(day['close']);
    if (openMinutes == null || closeMinutes == null) return false;

    final currentMinutes = moment.hour * 60 + moment.minute;
    if (closeMinutes < openMinutes) {
      return currentMinutes >= openMinutes || currentMinutes <= closeMinutes;
    }
    return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
  }

  /// Média bayesiana: exige consistência antes de aproximar a nota de 5.
  /// Com prior 4 e peso 10, 100 avaliações de 4,5 superam 2 avaliações de 5.
  double get rankingScore =>
      fairRatingScore(average: averageRating, reviewCount: reviewCount);

  static double fairRatingScore({
    required double average,
    required int reviewCount,
    double priorAverage = 4,
    int priorWeight = 10,
  }) {
    if (reviewCount <= 0) return 0;
    return ((reviewCount * average) + (priorWeight * priorAverage)) /
        (reviewCount + priorWeight);
  }

  static String _string(dynamic value, [String fallback = '']) {
    final text = value is String ? value.trim() : '';
    return text.isEmpty ? fallback : text;
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static int? _minutes(dynamic value) {
    if (value is! String) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }
}
