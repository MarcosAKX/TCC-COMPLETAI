import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/station_discovery_filter.dart';

class FuelChoiceSelector extends StatelessWidget {
  final FuelChoice choice;
  final ValueChanged<FuelChoice> onChanged;

  const FuelChoiceSelector({
    super.key,
    required this.choice,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Meu combustível',
      container: true,
      child: ColoredBox(
        key: const Key('fuel-choice-band'),
        color: AppTheme.primary,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meu combustível',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 10),
              Container(
                constraints: const BoxConstraints(minHeight: 60),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Row(
                  children: [
                    for (
                      var index = 0;
                      index < FuelChoice.values.length;
                      index++
                    ) ...[
                      if (index > 0)
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 170),
                          opacity:
                              choice == FuelChoice.values[index] ||
                                  choice == FuelChoice.values[index - 1]
                              ? 0
                              : 1,
                          child: Container(
                            width: 1,
                            height: 26,
                            color: Colors.white.withValues(alpha: 0.24),
                          ),
                        ),
                      Expanded(
                        child: _FuelOption(
                          fuel: FuelChoice.values[index],
                          selected: choice == FuelChoice.values[index],
                          onTap: () => onChanged(FuelChoice.values[index]),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FuelOption extends StatelessWidget {
  final FuelChoice fuel;
  final bool selected;
  final VoidCallback onTap;

  const _FuelOption({
    required this.fuel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: fuel.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final useCompactComposition =
                  MediaQuery.textScalerOf(context).scale(14) > 18 ||
                  constraints.maxWidth < 88;
              final foreground = selected ? AppTheme.primary : Colors.white;
              final icon = Icon(
                Icons.local_gas_station_outlined,
                size: 19,
                color: foreground,
              );
              final label = Text(
                fuel.label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              );

              return AnimatedContainer(
                key: Key('fuel-option-${fuel.name}'),
                duration: const Duration(milliseconds: 170),
                curve: Curves.easeOut,
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: selected
                      ? const [
                          BoxShadow(
                            color: Color(0x26203C92),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : const [],
                ),
                child: useCompactComposition
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [icon, const SizedBox(height: 4), label],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          icon,
                          const SizedBox(width: 7),
                          Flexible(child: label),
                        ],
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}
