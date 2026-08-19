import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PriceDisplay extends StatelessWidget {
  final String label;
  final double? price;
  final bool emphasized;
  final bool bestValue;
  final CrossAxisAlignment alignment;

  const PriceDisplay({
    super.key,
    required this.label,
    required this.price,
    this.emphasized = false,
    this.bestValue = false,
    this.alignment = CrossAxisAlignment.start,
  });

  String get _formattedPrice => price == null
      ? 'Não informado'
      : 'R\$ ${price!.toStringAsFixed(2).replaceAll('.', ',')}';

  String get _semanticLabel {
    if (price == null) return '$label, preço não informado';
    final cents = (price! * 100).round();
    final reais = cents ~/ 100;
    final centavos = cents % 100;
    final value =
        '$label, $reais ${reais == 1 ? 'real' : 'reais'} e $centavos centavos';
    return bestValue ? '$value, melhor valor' : value;
  }

  @override
  Widget build(BuildContext context) {
    final priceColor = price == null
        ? AppTheme.textMuted
        : bestValue
        ? AppTheme.savings
        : AppTheme.price;

    return Semantics(
      label: _semanticLabel,
      container: true,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: alignment,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.35,
              ),
            ),
            const SizedBox(height: 5),
            if (bestValue) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.savingsSurface,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Melhor valor',
                  style: TextStyle(
                    color: AppTheme.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
            if (price == null)
              Text(
                _formattedPrice,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'R\$ ',
                      style: AppTheme.priceStyle(
                        fontSize: emphasized ? 17 : 14,
                        fontWeight: FontWeight.w600,
                        color: priceColor,
                      ),
                    ),
                    TextSpan(
                      text: price!.toStringAsFixed(2).replaceAll('.', ','),
                      style: AppTheme.priceStyle(
                        fontSize: emphasized ? 30 : 18,
                        fontWeight: emphasized
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: priceColor,
                      ),
                    ),
                  ],
                ),
                style: TextStyle(color: priceColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
