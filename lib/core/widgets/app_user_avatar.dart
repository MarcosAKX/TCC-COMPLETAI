import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppUserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String displayName;
  final VoidCallback onTap;
  final double size;

  const AppUserAvatar({
    super.key,
    this.imageUrl,
    required this.displayName,
    required this.onTap,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final validImage = imageUrl?.trim().isNotEmpty == true;
    return Semantics(
      button: true,
      label: 'Abrir meu perfil',
      child: Tooltip(
        message: 'Abrir meu perfil',
        child: InkWell(
          onTap: onTap,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Ink(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(14),
              image: validImage
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!.trim()),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: validImage
                ? null
                : Center(
                    child: Text(
                      _initials(displayName),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String _initials(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .toList(growable: false);
    if (words.isEmpty) return 'U';
    return words.map((word) => word[0].toUpperCase()).join();
  }
}
