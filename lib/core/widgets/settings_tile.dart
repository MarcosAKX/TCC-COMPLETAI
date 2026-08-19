import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool destructive;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? AppTheme.error : AppTheme.primary;
    return ListTile(
      minTileHeight: 52,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: DecoratedBox(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: accent, size: 20),
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: destructive ? AppTheme.error : AppTheme.textLight,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppTheme.textMuted,
      ),
      onTap: onTap,
    );
  }
}
