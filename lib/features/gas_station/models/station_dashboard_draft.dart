class StationDashboardDraft {
  StationDashboardDraft({
    required Map<String, String> prices,
    required Set<String> tags,
    required Set<String> services,
    required Map<String, Map<String, dynamic>> openingHours,
  }) : _savedPrices = _normalizedPrices(prices),
       _prices = _normalizedPrices(prices),
       _savedTags = {...tags},
       _tags = {...tags},
       _savedServices = {...services},
       _services = {...services},
       _savedOpeningHours = _copyHours(openingHours),
       _openingHours = _copyHours(openingHours);

  Map<String, String> _savedPrices;
  Map<String, String> _prices;
  Set<String> _savedTags;
  Set<String> _tags;
  Set<String> _savedServices;
  Set<String> _services;
  Map<String, Map<String, dynamic>> _savedOpeningHours;
  Map<String, Map<String, dynamic>> _openingHours;

  bool get hasPriceChanges => !_mapEquals(_savedPrices, _prices);
  bool get hasInformationChanges =>
      !_setEquals(_savedTags, _tags) ||
      !_setEquals(_savedServices, _services);
  bool get hasOpeningHourChanges =>
      !_hoursEqual(_savedOpeningHours, _openingHours);

  Map<String, String> get prices => Map.unmodifiable(_prices);
  Set<String> get tags => Set.unmodifiable(_tags);
  Set<String> get services => Set.unmodifiable(_services);
  Map<String, Map<String, dynamic>> get openingHours =>
      _copyHours(_openingHours);

  String priceFor(String fuel) => _prices[fuel] ?? '';

  void setPrice(String fuel, String value) {
    _prices[fuel] = _normalizePrice(value);
  }

  void replaceInformation({
    required Set<String> tags,
    required Set<String> services,
  }) {
    _tags = {...tags};
    _services = {...services};
  }

  void replaceOpeningHours(
    Map<String, Map<String, dynamic>> openingHours,
  ) {
    _openingHours = _copyHours(openingHours);
  }

  void markPricesSaved() {
    _savedPrices = {..._prices};
  }

  void markInformationSaved() {
    _savedTags = {..._tags};
    _savedServices = {..._services};
  }

  void markOpeningHoursSaved() {
    _savedOpeningHours = _copyHours(_openingHours);
  }

  void restorePrices() {
    _prices = {..._savedPrices};
  }

  void restoreInformation() {
    _tags = {..._savedTags};
    _services = {..._savedServices};
  }

  void restoreOpeningHours() {
    _openingHours = _copyHours(_savedOpeningHours);
  }

  static Map<String, String> _normalizedPrices(Map<String, String> prices) {
    return prices.map(
      (key, value) => MapEntry(key, _normalizePrice(value)),
    );
  }

  static String _normalizePrice(String value) {
    return value.trim().replaceAll('.', ',');
  }

  static Map<String, Map<String, dynamic>> _copyHours(
    Map<String, Map<String, dynamic>> source,
  ) {
    return source.map((day, schedule) => MapEntry(day, {...schedule}));
  }

  static bool _setEquals<T>(Set<T> first, Set<T> second) {
    return first.length == second.length && first.containsAll(second);
  }

  static bool _mapEquals<K, V>(Map<K, V> first, Map<K, V> second) {
    if (first.length != second.length) return false;
    return first.entries.every((entry) => second[entry.key] == entry.value);
  }

  static bool _hoursEqual(
    Map<String, Map<String, dynamic>> first,
    Map<String, Map<String, dynamic>> second,
  ) {
    if (first.length != second.length) return false;
    return first.entries.every((entry) {
      final other = second[entry.key];
      return other != null && _mapEquals(entry.value, other);
    });
  }
}
