import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum DecisionHighlightVariant { economy, rating }

class DecisionHighlightCard extends StatelessWidget {
  final DecisionHighlightVariant variant;
  final String title;
  final String subtitle;
  final String detail;
  final VoidCallback? onTap;

  const DecisionHighlightCard({
    super.key,
    required this.variant,
    required this.title,
    required this.subtitle,
    required this.detail,
    this.onTap,
  });

  Color get _accentColor => switch (variant) {
    DecisionHighlightVariant.economy => AppTheme.savings,
    DecisionHighlightVariant.rating => AppTheme.rating,
  };

  Color get _surfaceColor => switch (variant) {
    DecisionHighlightVariant.economy => AppTheme.savingsSurface,
    DecisionHighlightVariant.rating => AppTheme.ratingSurface,
  };

  IconData get _icon => switch (variant) {
    DecisionHighlightVariant.economy => Icons.savings_outlined,
    DecisionHighlightVariant.rating => Icons.star_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accentColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 52,
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 12),
          Icon(_icon, color: _accentColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: AppTheme.textLight),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(detail, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: content,
      ),
    );
  }
}
