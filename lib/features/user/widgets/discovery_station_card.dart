import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/fuel_price_grid.dart';
import '../../../core/widgets/station_logo.dart';
import '../../../core/widgets/status_pill.dart';
import '../../gas_station/models/public_gas_station.dart';
import '../models/station_discovery_filter.dart';

class DiscoveryStationCard extends StatelessWidget {
  final PublicGasStation station;
  final FuelChoice fuel;
  final bool isBestValue;
  final bool isOpen;
  final double? savingsPerLiter;
  final VoidCallback onOpen;

  const DiscoveryStationCard({
    super.key,
    required this.station,
    required this.fuel,
    required this.isBestValue,
    required this.isOpen,
    this.savingsPerLiter,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isBestValue)
                const ColoredBox(
                  key: Key('station-card-accent'),
                  color: AppTheme.primary,
                  child: SizedBox(width: 4),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isBestValue ? 14 : 16,
                    14,
                    14,
                    13,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isBestValue) ...[
                        _DecisionHeader(
                          fuel: fuel,
                          savingsPerLiter: savingsPerLiter,
                        ),
                        const SizedBox(height: 14),
                      ],
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StationLogo(stationName: station.name, size: 46),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  station.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  station.neighborhood.isEmpty
                                      ? station.city
                                      : station.neighborhood,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusPill(isOpen: isOpen, compact: true),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FuelPriceGrid(
                        prices: station.fuelPrices,
                        selectedFuel: fuel,
                        bestValueKeys: isBestValue ? {fuel.fuelKey} : const {},
                      ),
                      const SizedBox(height: 10),
                      _StationTrustLine(station: station),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecisionHeader extends StatelessWidget {
  final FuelChoice fuel;
  final double? savingsPerLiter;

  const _DecisionHeader({required this.fuel, this.savingsPerLiter});

  @override
  Widget build(BuildContext context) {
    final savings = savingsPerLiter;
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.outline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Melhor opção para ${fuel.label}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (savings != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.savingsSurface,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                'Economize até R\$ ${savings.toStringAsFixed(2).replaceAll('.', ',')}/L',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.savings,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StationTrustLine extends StatelessWidget {
  final PublicGasStation station;

  const _StationTrustLine({required this.station});

  @override
  Widget build(BuildContext context) {
    final rating = station.reviewCount == 0
        ? 'Sem avaliações'
        : '${station.averageRating.toStringAsFixed(1)} · ${station.reviewCount} avaliações';
    final freshness = _freshness(station.updatedAt, DateTime.now());
    return Wrap(
      spacing: 12,
      runSpacing: 7,
      children: [
        _MetaItem(icon: Icons.star_rounded, text: rating, rating: true),
        if (freshness != null)
          _MetaItem(icon: Icons.schedule_rounded, text: freshness),
      ],
    );
  }

  String? _freshness(DateTime? updatedAt, DateTime now) {
    if (updatedAt == null) return null;
    final difference = now.difference(updatedAt);
    if (difference.isNegative || difference.inMinutes < 1) {
      return 'Atualizado agora';
    }
    if (difference.inMinutes < 60) {
      return 'Atualizado há ${difference.inMinutes} min';
    }
    if (difference.inHours < 24) {
      return 'Atualizado há ${difference.inHours} h';
    }
    return 'Atualizado há ${difference.inDays} d';
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool rating;

  const _MetaItem({
    required this.icon,
    required this.text,
    this.rating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: rating ? AppTheme.rating : AppTheme.textMuted,
        ),
        const SizedBox(width: 4),
        Text(text, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
