import 'package:flutter/material.dart';

import 'responsive_content.dart';

class ResponsiveFormContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveFormContent({
    super.key,
    required this.child,
    this.maxWidth = 440,
    this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 32),
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveContent(
      frameKey: const Key('responsive-form-frame'),
      maxWidth: maxWidth,
      padding: padding,
      child: child,
    );
  }
}
