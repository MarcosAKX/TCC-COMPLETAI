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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _stackedChildren(),
          );
        }

        return OverflowBar(
          alignment: MainAxisAlignment.start,
          spacing: spacing,
          overflowAlignment: OverflowBarAlignment.start,
          overflowSpacing: spacing,
          children: _constrainedChildren(),
        );
      },
    );
  }

  List<Widget> _stackedChildren() {
    return [
      for (var index = 0; index < children.length; index++) ...[
        if (index > 0) SizedBox(height: spacing),
        _constrain(children[index]),
      ],
    ];
  }

  List<Widget> _constrainedChildren() {
    return [for (final child in children) _constrain(child)];
  }

  Widget _constrain(Widget child) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: child,
    );
  }
}
