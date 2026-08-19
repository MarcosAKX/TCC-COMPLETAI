import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class WelcomeSummaryHeader extends StatelessWidget {
  final int stationCount;
  final VoidCallback? onLocationTap;

  const WelcomeSummaryHeader({
    super.key,
    required this.stationCount,
    this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    final countText = stationCount == 1
        ? 'Bebedouro · 1 posto encontrado'
        : 'Bebedouro · $stationCount postos encontrados';
    return Semantics(
      label: countText,
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
        color: AppTheme.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Onde completar hoje?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 7),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onLocationTap,
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  minimumSize: const Size(48, 48),
                  foregroundColor: AppTheme.textMuted,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(countText)),
                    if (onLocationTap != null)
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
