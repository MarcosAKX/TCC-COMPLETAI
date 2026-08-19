import 'package:flutter/material.dart';

class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final bool scrollable;
  final ScrollController? controller;
  final Key? frameKey;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 900,
    this.padding = EdgeInsets.zero,
    this.scrollable = false,
    this.controller,
    this.frameKey,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = scrollable
            ? ListView(
                controller: controller,
                padding: padding,
                children: [child],
              )
            : Padding(padding: padding, child: child);

        return Center(
          child: ConstrainedBox(
            key: frameKey ?? const Key('responsive-content-frame'),
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SizedBox(width: double.infinity, child: content),
          ),
        );
      },
    );
  }
}
