import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StatusPill extends StatelessWidget {
  final bool isOpen;
  final bool compact;

  const StatusPill({super.key, required this.isOpen, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? AppTheme.green : AppTheme.error;
    final text = isOpen ? 'Aberto agora' : 'Fechado';
    return Semantics(
      label: isOpen ? 'Posto aberto agora' : 'Posto fechado',
      container: true,
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 9 : 12,
            vertical: compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule_rounded,
                color: color,
                size: compact ? 14 : 16,
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: compact ? 10 : 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
