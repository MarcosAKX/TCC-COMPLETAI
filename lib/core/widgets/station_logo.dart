import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StationLogo extends StatelessWidget {
  final String? imageUrl;
  final String stationName;
  final double size;

  const StationLogo({
    super.key,
    this.imageUrl,
    required this.stationName,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final validImage = imageUrl?.trim().isNotEmpty == true;
    final initials = _initials(stationName);
    return Semantics(
      image: true,
      label: 'Logo de ${stationName.trim().isEmpty ? 'posto' : stationName}',
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppTheme.elevatedSurface,
            borderRadius: BorderRadius.circular(size * 0.3),
            border: Border.all(color: AppTheme.outline),
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
                  child: initials == null
                      ? Icon(
                          Icons.local_gas_station_outlined,
                          color: AppTheme.primary,
                          size: size * 0.48,
                        )
                      : Text(
                          initials,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                ),
        ),
      ),
    );
  }

  String? _initials(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .toList(growable: false);
    if (words.isEmpty) return null;
    return words.map((word) => word[0].toUpperCase()).join();
  }
}
