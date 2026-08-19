import 'dart:math' as math;

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final readableCellWidth = math.max(
          82.0,
          MediaQuery.textScalerOf(context).scale(72),
        );
        final useVerticalLayout =
            constraints.maxWidth < readableCellWidth * _fuels.length + 12;
        if (useVerticalLayout) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < _fuels.length; index++) ...[
                if (index > 0) const SizedBox(height: 6),
                _buildCell(index),
              ],
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < _fuels.length; index++) ...[
                if (index > 0) const SizedBox(width: 6),
                Expanded(child: _buildCell(index)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCell(int index) {
    final fuel = _fuels[index];
    return _FuelPriceCell(
      fuelKey: fuel.$1,
      label: fuel.$2,
      price: _validPrice(prices[fuel.$1]),
      selected: selectedFuel?.fuelKey == fuel.$1,
      bestValue: bestValueKeys.contains(fuel.$1),
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
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatted,
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
