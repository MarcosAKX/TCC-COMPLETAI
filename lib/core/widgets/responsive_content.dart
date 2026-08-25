import 'package:flutter/material.dart';

class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final bool scrollable;
  final ScrollController? controller;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 900,
    this.padding = EdgeInsets.zero,
    this.scrollable = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final content = scrollable
        ? ListView(
            controller: controller,
            padding: padding.add(
              EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
            ),
            children: [child],
          )
        : Padding(padding: padding, child: child);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              key: const Key('responsive-content-frame'),
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SizedBox(width: double.infinity, child: content),
            ),
          );
        },
      ),
    );
  }
}
