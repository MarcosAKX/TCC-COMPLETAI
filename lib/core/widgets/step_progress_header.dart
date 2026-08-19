import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StepProgressHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  }) : assert(currentStep > 0),
       assert(totalSteps > 0),
       assert(currentStep <= totalSteps);

  @override
  Widget build(BuildContext context) {
    final label = 'Etapa $currentStep de $totalSteps';
    return Semantics(
      label: label,
      container: true,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 10),
            Row(
              key: const Key('route-progress-waypoints'),
              children: List.generate(totalSteps * 2 - 1, (index) {
                if (index.isOdd) {
                  final segment = index ~/ 2 + 1;
                  return Expanded(
                    child: Container(
                      height: 3,
                      color: segment < currentStep
                          ? AppTheme.primary
                          : AppTheme.outline,
                    ),
                  );
                }
                final step = index ~/ 2 + 1;
                final reached = step <= currentStep;
                return Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: reached ? AppTheme.primary : AppTheme.card,
                    border: Border.all(
                      color: reached ? AppTheme.primary : AppTheme.outline,
                      width: 2,
                    ),
                  ),
                  child: step < currentStep
                      ? const Icon(Icons.check, color: Colors.white, size: 9)
                      : null,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
