import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TrustBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const TrustBadge({
    super.key,
    required this.text,
    required this.icon,
    this.color = AppTheme.primaryInteractive,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: text,
      container: true,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
