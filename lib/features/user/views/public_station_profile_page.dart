import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/adaptive_action_row.dart';
import '../../../core/widgets/fuel_price_grid.dart';
import '../../../core/widgets/price_display.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/station_logo.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../core/widgets/trust_badge.dart';
import '../../gas_station/models/public_gas_station.dart';
import '../../gas_station/models/station_review.dart';
import '../services/public_station_service.dart';

class PublicStationProfilePage extends StatefulWidget {
  final String stationId;
  final PublicGasStation? initialStation;

  const PublicStationProfilePage({
    super.key,
    required this.stationId,
    this.initialStation,
  });

  @override
  State<PublicStationProfilePage> createState() =>
      _PublicStationProfilePageState();
}

class _PublicStationProfilePageState extends State<PublicStationProfilePage> {
  final PublicStationService _service = PublicStationService();
  late Future<void> _loadFuture;
  PublicGasStation? _station;
  List<StationReview> _reviews = const [];

  @override
  void initState() {
    super.initState();
    _station = widget.initialStation;
    _loadFuture = _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      _service.getStation(widget.stationId),
      _service.getReviews(widget.stationId),
    ]);
    if (!mounted) return;
    _station = results[0] as PublicGasStation;
    _reviews = results[1] as List<StationReview>;
  }

  Future<void> _reload() async {
    final future = _load();
    setState(() => _loadFuture = future);
    await future;
    if (mounted) setState(() {});
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openReviewDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const StationReviewDialog(),
    );
    if (result == null) return;

    try {
      await _service.submitReview(
        stationId: widget.stationId,
        rating: result['rating'] as int,
        comment: result['comment'] as String,
      );
      if (!mounted) return;
      _showMessage('Avaliação publicada com sucesso.');
      await _reload();
    } catch (_) {
      if (mounted) {
        _showMessage('Não foi possível publicar sua avaliação.');
      }
    }
  }

  Future<void> _openStationReportDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const StationReportDialog(),
    );
    if (result == null) return;

    try {
      await _service.reportStation(
        stationId: widget.stationId,
        reason: result['reason']!,
        details: result['details']!,
      );
      if (mounted) {
        _showMessage('Reporte enviado para análise. Obrigado.');
      }
    } catch (_) {
      if (mounted) _showMessage('Não foi possível enviar o reporte.');
    }
  }

  Future<void> _reportReview(StationReview review) async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.card,
      isScrollControlled: true,
      builder: (_) => const ReviewReportSheet(),
    );
    if (reason == null) return;

    try {
      await _service.reportReview(
        stationId: widget.stationId,
        reviewId: review.id,
        reason: reason,
      );
      if (mounted) _showMessage('Avaliação denunciada para análise.');
    } catch (_) {
      if (mounted) _showMessage('Não foi possível denunciar a avaliação.');
    }
  }

  void _showAllReviews() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.background,
      isScrollControlled: true,
      builder: (_) =>
          AllReviewsSheet(reviews: _reviews, onReport: _reportReview),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Perfil do posto',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Reportar posto',
            onPressed: _openStationReportDialog,
            icon: const Icon(Icons.flag_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _station == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryInteractive,
              ),
            );
          }
          if (snapshot.hasError && _station == null) {
            return _ProfileError(onRetry: _reload);
          }

          final station = _station;
          if (station == null) return _ProfileError(onRetry: _reload);

          return PublicStationProfileContent(
            station: station,
            reviews: _reviews,
            favoriteStream: _service.watchIsFavorite(station.id),
            onRefresh: _reload,
            onCopyAddress: () async {
              await Clipboard.setData(ClipboardData(text: station.fullAddress));
              if (mounted) {
                _showMessage(
                  'Endereço copiado. Abra no seu aplicativo de mapas.',
                );
              }
            },
            onReview: _openReviewDialog,
            onToggleFavorite: (favorite) async {
              try {
                await _service.setFavorite(
                  stationId: station.id,
                  favorite: favorite,
                );
              } catch (_) {
                if (mounted) {
                  _showMessage('Não foi possível alterar o favorito.');
                }
              }
            },
            onShowAllReviews: _showAllReviews,
            onReportReview: _reportReview,
            onReportStation: _openStationReportDialog,
          );
        },
      ),
    );
  }
}

class PublicStationProfileContent extends StatelessWidget {
  const PublicStationProfileContent({
    super.key,
    required this.station,
    required this.reviews,
    required this.favoriteStream,
    required this.onRefresh,
    required this.onCopyAddress,
    required this.onReview,
    required this.onToggleFavorite,
    required this.onShowAllReviews,
    required this.onReportReview,
    required this.onReportStation,
  });

  final PublicGasStation station;
  final List<StationReview> reviews;
  final Stream<bool> favoriteStream;
  final Future<void> Function() onRefresh;
  final VoidCallback onCopyAddress;
  final VoidCallback onReview;
  final Future<void> Function(bool favorite) onToggleFavorite;
  final VoidCallback onShowAllReviews;
  final void Function(StationReview review) onReportReview;
  final VoidCallback onReportStation;

  ButtonStyle get _secondaryButtonStyle => OutlinedButton.styleFrom(
    minimumSize: const Size.fromHeight(52),
    foregroundColor: AppTheme.primary,
    side: const BorderSide(color: AppTheme.outline),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
  );

  @override
  Widget build(BuildContext context) {
    final services = {...station.services, ...station.tags};
    return RefreshIndicator(
      color: AppTheme.primaryInteractive,
      onRefresh: onRefresh,
      child: ResponsiveContent(
        maxWidth: 760,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        scrollable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StationHeader(station: station),
            const SizedBox(height: 22),
            _PricesCard(station: station),
            const SizedBox(height: 25),
            const _SectionTitle(title: 'Serviços disponíveis'),
            const SizedBox(height: 11),
            if (services.isEmpty)
              Text(
                'Nenhum serviço informado.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
              )
            else
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: services
                    .map((item) => _ServiceChip(label: item))
                    .toList(),
              ),
            const SizedBox(height: 25),
            _InformationCard(station: station),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onCopyAddress,
              icon: const Icon(Icons.near_me_outlined),
              label: const Text('Copiar endereço para chegar'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 520;
                final actionWidth = compact
                    ? double.infinity
                    : (constraints.maxWidth - 12) / 2;
                return AdaptiveActionRow(
                  breakpoint: 520,
                  children: [
                    SizedBox(
                      width: actionWidth,
                      child: OutlinedButton.icon(
                        onPressed: onReview,
                        icon: const Icon(
                          Icons.star_rounded,
                          color: AppTheme.rating,
                        ),
                        label: const Text('Avaliar'),
                        style: _secondaryButtonStyle,
                      ),
                    ),
                    SizedBox(
                      width: actionWidth,
                      child: StreamBuilder<bool>(
                        stream: favoriteStream,
                        initialData: false,
                        builder: (context, snapshot) {
                          final favorite = snapshot.data ?? false;
                          return OutlinedButton.icon(
                            onPressed: () => onToggleFavorite(!favorite),
                            icon: Icon(
                              favorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: AppTheme.error,
                            ),
                            label: Text(favorite ? 'Favoritado' : 'Favoritar'),
                            style: _secondaryButtonStyle,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: [
                const _SectionTitle(title: 'O que dizem os motoristas'),
                if (reviews.length > 3)
                  TextButton(
                    onPressed: onShowAllReviews,
                    child: const Text('Ver todas'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (reviews.isEmpty)
              const _NoReviews()
            else
              ...reviews
                  .take(3)
                  .map(
                    (review) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ReviewCard(
                        review: review,
                        onReport: () => onReportReview(review),
                      ),
                    ),
                  ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const Key('public-profile-report-station-action'),
                onPressed: onReportStation,
                icon: const Icon(Icons.flag_outlined, size: 18),
                label: const Text('Reportar problema com este posto'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StationReviewDialog extends StatefulWidget {
  const StationReviewDialog({super.key});

  @override
  State<StationReviewDialog> createState() => _StationReviewDialogState();
}

class _StationReviewDialogState extends State<StationReviewDialog> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.card,
      title: Text(
        'Avaliar este posto',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: SizedBox(
        width: 420,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.52,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sua avaliação ajuda outros motoristas.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      tooltip: '${index + 1} estrelas',
                      onPressed: () => setState(() => _rating = index + 1),
                      icon: Icon(
                        index < _rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: AppTheme.rating,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Conte como foi sua experiência',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: AdaptiveActionRow(
            breakpoint: 360,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  final comment = _commentController.text.trim();
                  if (comment.length < 3) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Escreva pelo menos 3 caracteres.'),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context, {
                    'rating': _rating,
                    'comment': comment,
                  });
                },
                child: const Text('Publicar'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StationReportDialog extends StatefulWidget {
  const StationReportDialog({super.key});

  @override
  State<StationReportDialog> createState() => _StationReportDialogState();
}

class _StationReportDialogState extends State<StationReportDialog> {
  static const _reasons = [
    'Suspeita de combustível adulterado',
    'Preço diferente do anunciado',
    'Informações incorretas',
    'Posto inexistente ou fechado',
    'Outro',
  ];

  final TextEditingController _detailsController = TextEditingController();
  String _reason = _reasons.first;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.card,
      title: Text(
        'Reportar este posto',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: SizedBox(
        width: 420,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.52,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _reason,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Motivo',
                    border: OutlineInputBorder(),
                  ),
                  items: _reasons
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _reason = value);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _detailsController,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Detalhes adicionais (opcional)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: AdaptiveActionRow(
            breakpoint: 360,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context, {
                  'reason': _reason,
                  'details': _detailsController.text.trim(),
                }),
                child: const Text('Enviar reporte'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ReviewReportSheet extends StatelessWidget {
  const ReviewReportSheet({super.key});

  static const _reasons = [
    'Conteúdo ofensivo',
    'Palavrões ou baixo calão',
    'Discurso de ódio',
    'Spam ou conteúdo falso',
    'Outro',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.82,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Por que deseja denunciar?',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: _reasons
                      .map(
                        (item) => ListTile(
                          minTileHeight: 48,
                          contentPadding: EdgeInsets.zero,
                          title: Text(item),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => Navigator.pop(context, item),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AllReviewsSheet extends StatelessWidget {
  const AllReviewsSheet({
    super.key,
    required this.reviews,
    required this.onReport,
  });

  final List<StationReview> reviews;
  final void Function(StationReview review) onReport;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      minChildSize: 0.55,
      maxChildSize: 0.94,
      builder: (context, controller) => Column(
        children: [
          Container(
            width: 42,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.outline,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Todas as avaliações',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              itemCount: reviews.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, index) => _ReviewCard(
                review: reviews[index],
                onReport: () => onReport(reviews[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StationHeader extends StatelessWidget {
  final PublicGasStation station;

  const _StationHeader({required this.station});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StationLogo(stationName: station.name, size: 64),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    station.fullAddress,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StatusPill(isOpen: station.isOpenAt(DateTime.now()), compact: true),
        const SizedBox(height: 13),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            TrustBadge(
              text: _PricesCard.updatedText(station.updatedAt),
              icon: Icons.update_rounded,
            ),
            const TrustBadge(
              text: 'Informado pelo posto',
              icon: Icons.verified_outlined,
            ),
          ],
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            _Stars(rating: station.averageRating),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                station.reviewCount == 0
                    ? 'Ainda sem avaliações'
                    : '${station.averageRating.toStringAsFixed(1)}  (${station.reviewCount} avaliações)',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PricesCard extends StatelessWidget {
  final PublicGasStation station;

  const _PricesCard({required this.station});

  static const extraFuels = {
    'gasolineAdditive': 'Gasolina aditivada',
    'dieselS500': 'Diesel S500',
  };

  @override
  Widget build(BuildContext context) {
    final extras = extraFuels.entries
        .where((fuel) => (station.fuelPrices[fuel.key] ?? 0) > 0)
        .toList(growable: false);
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Todos os preços',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            updatedText(station.updatedAt),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 14),
          FuelPriceGrid(prices: station.fuelPrices),
          if (extras.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            ...extras.map(
              (fuel) => Padding(
                padding: const EdgeInsets.only(top: 12),
                child: PriceDisplay(
                  label: fuel.value,
                  price: station.fuelPrices[fuel.key],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String updatedText(DateTime? updatedAt) {
    if (updatedAt == null) return 'Atualização não informada';
    final difference = DateTime.now().difference(updatedAt);
    if (difference.inMinutes < 1) return 'Atualizado agora';
    if (difference.inHours < 1) {
      return 'Atualizado há ${difference.inMinutes} min';
    }
    if (difference.inDays < 1) {
      return 'Atualizado há ${difference.inHours} h';
    }
    return 'Atualizado há ${difference.inDays} d';
  }
}

class _InformationCard extends StatelessWidget {
  final PublicGasStation station;

  const _InformationCard({required this.station});

  static const dayLabels = {
    'monday': 'Segunda-feira',
    'tuesday': 'Terça-feira',
    'wednesday': 'Quarta-feira',
    'thursday': 'Quinta-feira',
    'friday': 'Sexta-feira',
    'saturday': 'Sábado',
    'sunday': 'Domingo',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outline),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: const Icon(
          Icons.info_outline_rounded,
          color: AppTheme.primaryInteractive,
        ),
        title: const Text(
          'Informações do posto',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          station.phone.isEmpty ? station.fullAddress : station.phone,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
        ),
        children: [
          _InfoRow(
            icon: Icons.location_on_outlined,
            title: 'Endereço',
            value: station.fullAddress,
          ),
          _InfoRow(
            icon: Icons.phone_outlined,
            title: 'Telefone',
            value: station.phone.isEmpty ? 'Não informado' : station.phone,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: Column(
              children: dayLabels.entries.map((entry) {
                final hours = station.openingHours[entry.key];
                final enabled = hours?['enabled'] == true;
                final value = enabled
                    ? '${hours?['open'] ?? '--:--'} – ${hours?['close'] ?? '--:--'}'
                    : 'Fechado';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 12,
                    runSpacing: 2,
                    children: [
                      Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: enabled ? AppTheme.textLight : AppTheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.textMuted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: AppTheme.textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textLight,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  final String label;

  const _ServiceChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryInteractive.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primaryInteractive.withValues(alpha: 0.55),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.primaryInteractive,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final double rating;

  const _Stars({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final position = index + 1;
        final icon = rating >= position
            ? Icons.star_rounded
            : rating >= position - 0.5
            ? Icons.star_half_rounded
            : Icons.star_border_rounded;
        return Icon(icon, color: AppTheme.rating, size: 19);
      }),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final StationReview review;
  final VoidCallback onReport;

  const _ReviewCard({required this.review, required this.onReport});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.darkColorScheme.primaryContainer,
                child: Text(
                  review.authorName.isEmpty
                      ? '?'
                      : review.authorName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      _dateText(review.createdAt),
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Denunciar avaliação',
                onPressed: onReport,
                icon: const Icon(
                  Icons.flag_outlined,
                  color: AppTheme.textMuted,
                  size: 19,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _Stars(rating: review.rating),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: const TextStyle(color: AppTheme.textMuted, height: 1.45),
            ),
          ],
        ],
      ),
    );
  }

  static String _dateText(DateTime? date) {
    if (date == null) return 'Data não informada';
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 60) {
      return 'Há ${difference.inMinutes.clamp(1, 59)} min';
    }
    if (difference.inHours < 24) return 'Há ${difference.inHours} h';
    if (difference.inDays < 7) return 'Há ${difference.inDays} dias';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _NoReviews extends StatelessWidget {
  const _NoReviews();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        children: [
          Icon(Icons.forum_outlined, color: AppTheme.textMuted),
          SizedBox(width: 13),
          Expanded(
            child: Text(
              'Seja a primeira pessoa a avaliar este posto.',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _ProfileError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 46),
          const SizedBox(height: 12),
          const Text('Não foi possível carregar este posto.'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
