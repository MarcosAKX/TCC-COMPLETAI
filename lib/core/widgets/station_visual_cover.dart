import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StationVisualCover extends StatelessWidget {
  const StationVisualCover({
    super.key,
    required this.stationName,
    required this.locationLabel,
    required this.isOpen,
    this.compact = false,
    this.coverImageUrl,
    this.coverImageBytes,
    this.stationBrand = 'Bandeira branca',
  }) : assert(coverImageUrl == null || coverImageBytes == null);

  final String stationName;
  final String locationLabel;
  final bool isOpen;
  final bool compact;
  final String? coverImageUrl;
  final Uint8List? coverImageBytes;
  final String stationBrand;

  @override
  Widget build(BuildContext context) {
    final location = locationLabel.trim().isEmpty
        ? 'Localização não informada'
        : locationLabel.trim();
    final status = isOpen ? 'aberto agora' : 'fechado agora';
    final hasCoverImage =
        coverImageBytes != null || (coverImageUrl?.trim().isNotEmpty ?? false);
    final semanticLabel = hasCoverImage
        ? 'Foto de capa do $stationName, $location, $status'
        : 'Capa do $stationName, $location, $status';
    final brandBadgeColor = hasCoverImage
        ? const Color(0xE6000000)
        : Colors.white.withValues(alpha: 0.16);

    return Semantics(
      container: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Container(
          key: const Key('station-visual-cover'),
          clipBehavior: Clip.antiAlias,
          constraints: BoxConstraints(minHeight: compact ? 158 : 220),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 18 : 24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2448C9), AppTheme.primary, Color(0xFF079B68)],
              stops: [0, 0.58, 1],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.18),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(child: _coverBackground()),
              if (hasCoverImage)
                const Positioned.fill(
                  child: DecoratedBox(
                    key: Key('station-visual-cover-photo-scrim'),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x99000000), Color(0xA6000000)],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(compact ? 18 : 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: compact ? 240 : 320,
                      ),
                      child: Container(
                        key: const Key('station-visual-cover-brand-badge'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: brandBadgeColor,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.24),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_gas_station_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                stationBrand.toUpperCase(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 36 : 62),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: compact ? 390 : 480,
                      ),
                      child: Text(
                        stationName,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontSize: compact ? 22 : 29,
                              fontWeight: FontWeight.w900,
                              height: 1.08,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white,
                          size: 17,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            location,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coverBackground() {
    final bytes = coverImageBytes;
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _CoverIllustration(compact: compact),
      );
    }

    final url = coverImageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _CoverIllustration(compact: compact),
      );
    }

    return _CoverIllustration(compact: compact);
  }
}

class _CoverIllustration extends StatelessWidget {
  const _CoverIllustration({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: CustomPaint(painter: _CoverPainter())),
        Positioned(
          right: compact ? -12 : -18,
          bottom: compact ? -14 : -24,
          child: Icon(
            Icons.local_gas_station_rounded,
            size: compact ? 112 : 168,
            color: Colors.white.withValues(alpha: 0.16),
          ),
        ),
      ],
    );
  }
}

class _CoverPainter extends CustomPainter {
  const _CoverPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final route = Paint()
      ..color = Colors.white.withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (var x = size.width * 0.48; x < size.width; x += 34) {
      canvas.drawLine(Offset(x, 0), Offset(x - 70, size.height), line);
    }
    for (var y = 28.0; y < size.height; y += 34) {
      canvas.drawLine(
        Offset(size.width * 0.42, y),
        Offset(size.width, y),
        line,
      );
    }

    final path = Path()
      ..moveTo(size.width * 0.54, size.height * 0.12)
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.18,
        size.width * 0.58,
        size.height * 0.68,
        size.width * 0.92,
        size.height * 0.86,
      );
    canvas.drawPath(path, route);
    canvas.drawCircle(
      Offset(size.width * 0.54, size.height * 0.12),
      6,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
