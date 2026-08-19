import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'urban_route_signature.dart';

class BrandHeroPanel extends StatelessWidget {
  final String title;
  final String message;
  final double routeProgress;

  const BrandHeroPanel({
    super.key,
    this.title = 'Completai!',
    this.message = 'Seu próximo abastecimento começa aqui',
    this.routeProgress = 1,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.primary,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 34, 28, 72),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.4,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              message,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontSize: 30,
                height: 1.12,
              ),
            ),
            const SizedBox(height: 12),
            UrbanRouteSignature(progress: routeProgress),
          ],
        ),
      ),
    );
  }
}
