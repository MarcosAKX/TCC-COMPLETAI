import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StationRatingOverview extends StatelessWidget {
  const StationRatingOverview({
    super.key,
    required this.average,
    required this.reviewCount,
    this.ratings = const [],
  });

  final double average;
  final int reviewCount;
  final List<double> ratings;

  bool get _hasCompleteValidDistribution {
    return reviewCount > 0 &&
        ratings.length == reviewCount &&
        ratings.every(
          (rating) =>
              rating.isFinite &&
              rating >= 1 &&
              rating <= 5 &&
              rating == rating.roundToDouble(),
        );
  }

  String get _semanticLabel {
    if (reviewCount <= 0) {
      return 'Resumo das avaliações, ainda sem avaliações';
    }

    final summary =
        'Resumo das avaliações, nota ${average.toStringAsFixed(1)} de 5, $reviewCount ${reviewCount == 1 ? 'avaliação' : 'avaliações'}';
    if (!_hasCompleteValidDistribution) return summary;

    final distribution = <String>[];
    for (var stars = 5; stars >= 1; stars--) {
      final count = ratings.where((rating) => rating == stars).length;
      distribution.add(
        '$stars ${stars == 1 ? 'estrela' : 'estrelas'}, $count ${count == 1 ? 'avaliação' : 'avaliações'}',
      );
    }
    return '$summary. ${distribution.join('. ')}';
  }

  @override
  Widget build(BuildContext context) {
    final hasCompleteDistribution = _hasCompleteValidDistribution;

    return Semantics(
      container: true,
      label: _semanticLabel,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Resumo das avaliações',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final score = _ScoreBlock(
                    average: average,
                    reviewCount: reviewCount,
                  );
                  if (!hasCompleteDistribution) return score;

                  final distribution = _RatingDistribution(ratings: ratings);
                  if (constraints.maxWidth < 460 ||
                      MediaQuery.textScalerOf(context).scale(1) >= 1.5) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        score,
                        const SizedBox(height: 18),
                        distribution,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 180, child: score),
                      const SizedBox(width: 24),
                      Expanded(child: distribution),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBlock extends StatelessWidget {
  const _ScoreBlock({required this.average, required this.reviewCount});

  final double average;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final hasReviews = reviewCount > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 62,
          height: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.rating.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            hasReviews ? average.toStringAsFixed(1) : '—',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.rating,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 13),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Icon(
                    average >= index + 1
                        ? Icons.star_rounded
                        : average >= index + 0.5
                        ? Icons.star_half_rounded
                        : Icons.star_border_rounded,
                    color: AppTheme.rating,
                    size: 18,
                  );
                }),
              ),
              const SizedBox(height: 5),
              Text(
                hasReviews
                    ? '$reviewCount ${reviewCount == 1 ? 'avaliação' : 'avaliações'}'
                    : 'Ainda sem avaliações',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RatingDistribution extends StatelessWidget {
  const _RatingDistribution({required this.ratings});

  final List<double> ratings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var stars = 5; stars >= 1; stars--)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 18,
                  child: Text(
                    '$stars',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                const Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: AppTheme.rating,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 7,
                      value: _countFor(stars) / ratings.length,
                      backgroundColor: AppTheme.elevatedSurface,
                      color: AppTheme.rating,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 20,
                  child: Text(
                    '${_countFor(stars)}',
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  int _countFor(int stars) {
    return ratings.where((rating) => rating == stars).length;
  }
}
