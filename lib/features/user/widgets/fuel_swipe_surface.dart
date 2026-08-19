import 'package:flutter/material.dart';

import '../models/station_discovery_filter.dart';

class FuelSwipeSurface extends StatefulWidget {
  final FuelChoice choice;
  final ValueChanged<FuelChoice> onChanged;
  final Widget child;
  final double threshold;

  const FuelSwipeSurface({
    super.key,
    required this.choice,
    required this.onChanged,
    required this.child,
    this.threshold = 36,
  });

  @override
  State<FuelSwipeSurface> createState() => _FuelSwipeSurfaceState();
}

class _FuelSwipeSurfaceState extends State<FuelSwipeSurface> {
  double _horizontalDistance = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) => _horizontalDistance = 0,
      onHorizontalDragUpdate: (details) {
        _horizontalDistance += details.primaryDelta ?? 0;
      },
      onHorizontalDragEnd: (_) {
        if (_horizontalDistance.abs() < widget.threshold) return;
        final values = FuelChoice.values;
        final currentIndex = values.indexOf(widget.choice);
        final targetIndex = _horizontalDistance < 0
            ? currentIndex + 1
            : currentIndex - 1;
        if (targetIndex < 0 || targetIndex >= values.length) return;
        widget.onChanged(values[targetIndex]);
      },
      child: widget.child,
    );
  }
}
