import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum UrbanRouteVariant { hero, compact, emptyState }

class UrbanRouteSignature extends StatelessWidget {
  final UrbanRouteVariant variant;
  final Color? color;
  final double progress;

  const UrbanRouteSignature({
    super.key,
    this.variant = UrbanRouteVariant.hero,
    this.color,
    this.progress = 1,
  }) : assert(progress >= 0 && progress <= 1);

  @override
  Widget build(BuildContext context) {
    final size = switch (variant) {
      UrbanRouteVariant.hero => const Size(double.infinity, 92),
      UrbanRouteVariant.compact => const Size(double.infinity, 46),
      UrbanRouteVariant.emptyState => const Size(180, 64),
    };
    return ExcludeSemantics(
      child: SizedBox.fromSize(
        size: size,
        child: CustomPaint(
          painter: _UrbanRoutePainter(
            color:
                color ??
                (variant == UrbanRouteVariant.hero
                    ? Colors.white
                    : AppTheme.primary),
            progress: progress,
          ),
        ),
      ),
    );
  }
}

class _UrbanRoutePainter extends CustomPainter {
  final Color color;
  final double progress;

  const _UrbanRoutePainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final route = Path()
      ..moveTo(0, size.height * .76)
      ..cubicTo(
        size.width * .13,
        size.height * .76,
        size.width * .11,
        size.height * .43,
        size.width * .26,
        size.height * .43,
      )
      ..cubicTo(
        size.width * .42,
        size.height * .43,
        size.width * .45,
        size.height * .66,
        size.width * .59,
        size.height * .42,
      )
      ..cubicTo(
        size.width * .7,
        size.height * .23,
        size.width * .8,
        size.height * .27,
        size.width * .88,
        size.height * .27,
      );
    final metric = route.computeMetrics().first;
    final visible = metric.extractPath(0, metric.length * progress);
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(visible, linePaint);
    if (progress > .32) {
      _drawWaypoint(
        canvas,
        metric.getTangentForOffset(metric.length * .3)!.position,
      );
    }
    if (progress > .68) {
      _drawWaypoint(
        canvas,
        metric.getTangentForOffset(metric.length * .64)!.position,
      );
    }
    if (progress > .92) {
      _drawPump(
        canvas,
        Offset(size.width * .9, size.height * .08),
        size.height * .42,
      );
    }
  }

  void _drawWaypoint(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 6, Paint()..color = color);
    canvas.drawCircle(center, 3, Paint()..color = AppTheme.primary);
  }

  void _drawPump(Canvas canvas, Offset origin, double height) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;
    final width = height * .58;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(origin.dx, origin.dy, width, height),
        const Radius.circular(3),
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(origin.dx + 4, origin.dy + 5, width - 8, height * .27),
      paint,
    );
    canvas.drawLine(
      Offset(origin.dx - 3, origin.dy + height),
      Offset(origin.dx + width + 3, origin.dy + height),
      paint,
    );
    final hose = Path()
      ..moveTo(origin.dx + width, origin.dy + height * .28)
      ..cubicTo(
        origin.dx + width * 1.35,
        origin.dy + height * .34,
        origin.dx + width * 1.3,
        origin.dy + height * .74,
        origin.dx + width * 1.08,
        origin.dy + height * .74,
      );
    canvas.drawPath(hose, paint);
  }

  @override
  bool shouldRepaint(_UrbanRoutePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.progress != progress;
}
