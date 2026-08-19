import 'package:flutter/material.dart';

import '../../features/user/models/station_discovery_filter.dart';
import '../theme/app_theme.dart';

class FuelPriceGrid extends StatelessWidget {
  final Map<String, double> prices;
  final FuelChoice? selectedFuel;
  final Set<String> bestValueKeys;

  const FuelPriceGrid({
    super.key,
    required this.prices,
    this.selectedFuel,
    this.bestValueKeys = const {},
  });

  static const _fuels = <(String, String)>[
    ('gasolineRegular', 'Gasolina'),
    ('ethanol', 'Etanol'),
    ('dieselS10', 'Diesel S10'),
  ];

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < _fuels.length; index++) ...[
            if (index > 0) const SizedBox(width: 6),
            Expanded(
              child: _FuelPriceCell(
                fuelKey: _fuels[index].$1,
                label: _fuels[index].$2,
                price: _validPrice(prices[_fuels[index].$1]),
                selected: selectedFuel?.fuelKey == _fuels[index].$1,
                bestValue: bestValueKeys.contains(_fuels[index].$1),
              ),
            ),
          ],
        ],
      ),
    );
  }

  double? _validPrice(double? value) =>
      value != null && value > 0 ? value : null;
}

class _FuelPriceCell extends StatelessWidget {
  final String fuelKey;
  final String label;
  final double? price;
  final bool selected;
  final bool bestValue;

  const _FuelPriceCell({
    required this.fuelKey,
    required this.label,
    required this.price,
    required this.selected,
    required this.bestValue,
  });

  @override
  Widget build(BuildContext context) {
    final color = bestValue ? AppTheme.savings : AppTheme.price;
    final background = bestValue
        ? AppTheme.savingsSurface
        : selected
        ? AppTheme.primarySurface
        : AppTheme.priceSurface;
    final borderColor = bestValue
        ? AppTheme.savings.withValues(alpha: 0.32)
        : selected
        ? AppTheme.primary.withValues(alpha: 0.32)
        : AppTheme.outline;
    final formatted = price == null
        ? 'Não informado'
        : 'R\$ ${price!.toStringAsFixed(2).replaceAll('.', ',')}';

    return Semantics(
      container: true,
      selected: selected,
      label: '$label, $formatted${bestValue ? ', melhor valor' : ''}',
      child: ExcludeSemantics(
        child: Container(
          key: Key('fuel-price-$fuelKey'),
          constraints: const BoxConstraints(minHeight: 66),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatted,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.priceStyle(
                  fontSize: price == null ? 11 : 16,
                  fontWeight: FontWeight.w800,
                  color: price == null ? AppTheme.textMuted : color,
                ),
              ),
              if (bestValue) ...[
                const SizedBox(height: 3),
                const Text(
                  'Melhor valor',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.savings,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
