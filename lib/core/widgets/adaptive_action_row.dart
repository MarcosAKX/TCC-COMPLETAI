import 'package:flutter/material.dart';

class AdaptiveActionRow extends StatelessWidget {
  final List<Widget> children;
  final double breakpoint;
  final double spacing;

  const AdaptiveActionRow({
    super.key,
    required this.children,
    this.breakpoint = 520,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(children: _withSpacing(Axis.vertical));
        }

        return Row(children: _withSpacing(Axis.horizontal));
      },
    );
  }

  List<Widget> _withSpacing(Axis axis) {
    return [
      for (var index = 0; index < children.length; index++) ...[
        if (index > 0)
          SizedBox(
            width: axis == Axis.horizontal ? spacing : null,
            height: axis == Axis.vertical ? spacing : null,
          ),
        children[index],
      ],
    ];
  }
}
