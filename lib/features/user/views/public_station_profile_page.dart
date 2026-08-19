import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/fuel_price_grid.dart';
import '../../../core/widgets/price_display.dart';
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
    final commentController = TextEditingController();
    int rating = 5;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppTheme.card,
            title: const Text('Avaliar este posto'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Sua avaliação ajuda outros motoristas.',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        tooltip: '${index + 1} estrelas',
                        onPressed: () =>
                            setDialogState(() => rating = index + 1),
                        icon: Icon(
                          index < rating
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
                    controller: commentController,
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
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  final comment = commentController.text.trim();
                  if (comment.length < 3) {
                    _showMessage('Escreva pelo menos 3 caracteres.');
                    return;
                  }
                  Navigator.pop(dialogContext, {
                    'rating': rating,
                    'comment': comment,
                  });
                },
                child: const Text('Publicar'),
              ),
            ],
          );
        },
      ),
    );
    commentController.dispose();
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
    const reasons = [
      'Suspeita de combustível adulterado',
      'Preço diferente do anunciado',
      'Informações incorretas',
      'Posto inexistente ou fechado',
      'Outro',
    ];
    String reason = reasons.first;
    final detailsController = TextEditingController();
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppTheme.card,
            title: const Text('Reportar este posto'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: reason,
                    decoration: const InputDecoration(
                      labelText: 'Motivo',
                      border: OutlineInputBorder(),
                    ),
                    items: reasons
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => reason = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: detailsController,
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
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(dialogContext, {
                  'reason': reason,
                  'details': detailsController.text.trim(),
                }),
                child: const Text('Enviar reporte'),
              ),
            ],
          );
        },
      ),
    );
    detailsController.dispose();
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
    const reasons = [
      'Conteúdo ofensivo',
      'Palavrões ou baixo calão',
      'Discurso de ódio',
      'Spam ou conteúdo falso',
      'Outro',
    ];
    final reason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.card,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Por que deseja denunciar?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ...reasons.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.pop(context, item),
                ),
              ),
            ],
          ),
        ),
      ),
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
      builder: (context) => DraggableScrollableSheet(
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
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Todas as avaliações',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                itemCount: _reviews.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, index) => _ReviewCard(
                  review: _reviews[index],
                  onReport: () => _reportReview(_reviews[index]),
                ),
              ),
            ),
          ],
        ),
      ),
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

          return RefreshIndicator(
            color: AppTheme.primaryInteractive,
            onRefresh: _reload,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
                  children: [
                    _StationHeader(station: station),
                    const SizedBox(height: 22),
                    _PricesCard(station: station),
                    const SizedBox(height: 25),
                    _SectionTitle(title: 'Serviços disponíveis'),
                    const SizedBox(height: 11),
                    if ({...station.services, ...station.tags}.isEmpty)
                      const Text(
                        'Nenhum serviço informado.',
                        style: TextStyle(color: AppTheme.textMuted),
                      )
                    else
                      Wrap(
                        spacing: 9,
                        runSpacing: 9,
                        children: {
                          ...station.services,
                          ...station.tags,
                        }.map((item) => _ServiceChip(label: item)).toList(),
                      ),
                    const SizedBox(height: 25),
                    _InformationCard(station: station),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: station.fullAddress),
                        );
                        if (context.mounted) {
                          _showMessage(
                            'Endereço copiado. Abra no seu aplicativo de mapas.',
                          );
                        }
                      },
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
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _openReviewDialog,
                            icon: const Icon(
                              Icons.star_rounded,
                              color: AppTheme.rating,
                            ),
                            label: const Text('Avaliar'),
                            style: _secondaryButtonStyle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StreamBuilder<bool>(
                            stream: _service.watchIsFavorite(station.id),
                            initialData: false,
                            builder: (context, favoriteSnapshot) {
                              final favorite = favoriteSnapshot.data ?? false;
                              return OutlinedButton.icon(
                                onPressed: () async {
                                  try {
                                    await _service.setFavorite(
                                      stationId: station.id,
                                      favorite: !favorite,
                                    );
                                  } catch (_) {
                                    if (context.mounted) {
                                      _showMessage(
                                        'Não foi possível alterar o favorito.',
                                      );
                                    }
                                  }
                                },
                                icon: Icon(
                                  favorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: AppTheme.error,
                                ),
                                label: Text(
                                  favorite ? 'Favoritado' : 'Favoritar',
                                ),
                                style: _secondaryButtonStyle,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        const Expanded(
                          child: _SectionTitle(
                            title: 'O que dizem os motoristas',
                          ),
                        ),
                        if (_reviews.length > 3)
                          TextButton(
                            onPressed: _showAllReviews,
                            child: const Text('Ver todas'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_reviews.isEmpty)
                      const _NoReviews()
                    else
                      ..._reviews
                          .take(3)
                          .map(
                            (review) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ReviewCard(
                                review: review,
                                onReport: () => _reportReview(review),
                              ),
                            ),
                          ),
                    const SizedBox(height: 6),
                    TextButton.icon(
                      onPressed: _openStationReportDialog,
                      icon: const Icon(Icons.flag_outlined, size: 18),
                      label: const Text('Reportar problema com este posto'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  ButtonStyle get _secondaryButtonStyle => OutlinedButton.styleFrom(
    minimumSize: const Size.fromHeight(52),
    foregroundColor: AppTheme.primary,
    side: const BorderSide(color: AppTheme.outline),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
  );
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
            const SizedBox(width: 8),
            StatusPill(isOpen: station.isOpenAt(DateTime.now()), compact: true),
          ],
        ),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Todos os preços',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text(
                updatedText(station.updatedAt),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(color: AppTheme.textMuted),
                        ),
                      ),
                      Text(
                        value,
                        style: TextStyle(
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
              _Stars(rating: review.rating),
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
