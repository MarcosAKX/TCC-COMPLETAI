import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class FuelDiscoveryTip extends StatelessWidget {
  final VoidCallback onDismiss;

  const FuelDiscoveryTip({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'Dica: troque de combustível tocando nas opções ou deslizando a lista para os lados.',
      child: ColoredBox(
        color: AppTheme.discoveryBackground,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppTheme.primarySurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.swipe_outlined,
                      size: 20,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Troque de combustível',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Toque nas opções acima ou deslize a lista para os lados.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Dispensar dica',
                    onPressed: onDismiss,
                    icon: const Icon(Icons.close_rounded),
                    color: AppTheme.primary,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
