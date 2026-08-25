import 'package:flutter/material.dart';

class AdaptiveLayout extends StatelessWidget {
  final double breakpoint;
  final Widget compact;
  final Widget expanded;

  const AdaptiveLayout({
    super.key,
    required this.breakpoint,
    required this.compact,
    required this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth < breakpoint ? compact : expanded;
      },
    );
  }
}
