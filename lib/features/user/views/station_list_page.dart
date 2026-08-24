import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_user_avatar.dart';
import '../../../core/widgets/welcome_summary_header.dart';
import '../../gas_station/models/public_gas_station.dart';
import '../models/station_discovery_filter.dart';
import '../services/discovery_tip_preference.dart';
import '../services/public_station_service.dart';
import '../widgets/discovery_station_card.dart';
import '../widgets/fuel_choice_selector.dart';
import '../widgets/fuel_discovery_tip.dart';
import '../widgets/fuel_swipe_surface.dart';
import 'public_station_profile_page.dart';

class StationListPage extends StatefulWidget {
  const StationListPage({super.key});

  @override
  State<StationListPage> createState() => _StationListPageState();
}

class _StationListPageState extends State<StationListPage> {
  final PublicStationService _service = PublicStationService();
  final DiscoveryTipPreference _tipPreference = DiscoveryTipPreference();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<PublicGasStation>> _stationsFuture;
  FuelChoice _fuel = FuelChoice.gasoline;
  bool _onlyOpen = false;
  bool _isRefreshing = false;
  bool _minimumRatingFour = false;
  bool _showFuelTip = false;

  @override
  void initState() {
    super.initState();
    _stationsFuture = _service.getStations();
    unawaited(_loadFuelTip());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final future = _service.getStations();
    setState(() {
      _stationsFuture = future;
    });
    await future;
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lista de postos atualizada.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Falha ao atualizar postos: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível atualizar a lista.')),
      );
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Future<void> _openStation(PublicGasStation station) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PublicStationProfilePage(
          stationId: station.id,
          initialStation: station,
        ),
      ),
    );
    if (mounted) _reload();
  }

  Future<void> _loadFuelTip() async {
    final shouldShow = await _tipPreference.shouldShow();
    if (!mounted) return;
    setState(() => _showFuelTip = shouldShow);
  }

  void _changeFuel(FuelChoice fuel) {
    final changed = fuel != _fuel;
    setState(() {
      _fuel = fuel;
      if (changed) _showFuelTip = false;
    });
    if (changed) unawaited(_tipPreference.dismiss());
  }

  void _dismissFuelTip() {
    setState(() => _showFuelTip = false);
    unawaited(_tipPreference.dismiss());
  }

  Future<void> _showLocationInfo() {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Área atendida',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.location_on_outlined),
                title: Text('Bebedouro'),
                subtitle: Text('No momento, o Completai atende esta cidade.'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showFilters() async {
    var onlyOpen = _onlyOpen;
    var minimumRatingFour = _minimumRatingFour;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtrar postos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Somente postos abertos'),
                  value: onlyOpen,
                  onChanged: (value) => setModalState(() => onlyOpen = value),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Avaliação 4,0 ou superior'),
                  value: minimumRatingFour,
                  onChanged: (value) =>
                      setModalState(() => minimumRatingFour = value),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _onlyOpen = onlyOpen;
                        _minimumRatingFour = minimumRatingFour;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Aplicar filtros'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Text('Meu combustível'),
        actions: [
          IconButton(
            tooltip: 'Atualizar postos',
            onPressed: _isRefreshing ? null : _refresh,
            icon: _isRefreshing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
          AppUserAvatar(
            displayName:
                FirebaseAuth.instance.currentUser?.displayName ?? 'Usuário',
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: FutureBuilder<List<PublicGasStation>>(
              future: _stationsFuture,
              builder: (context, snapshot) {
                return StationDiscoveryContent(
                  snapshot: snapshot,
                  searchController: _searchController,
                  fuel: _fuel,
                  onlyOpen: _onlyOpen,
                  minimumRatingFour: _minimumRatingFour,
                  showFuelTip: _showFuelTip,
                  onRefresh: _refresh,
                  onRetry: _reload,
                  onLocationTap: _showLocationInfo,
                  onSearchChanged: (_) => setState(() {}),
                  onClearSearch: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  onFuelChanged: _changeFuel,
                  onDismissFuelTip: _dismissFuelTip,
                  onOnlyOpenChanged: (value) =>
                      setState(() => _onlyOpen = value),
                  onShowFilters: _showFilters,
                  onOpenStation: _openStation,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class StationDiscoveryContent extends StatelessWidget {
  final AsyncSnapshot<List<PublicGasStation>> snapshot;
  final TextEditingController searchController;
  final FuelChoice fuel;
  final bool onlyOpen;
  final bool minimumRatingFour;
  final bool showFuelTip;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onRetry;
  final VoidCallback onLocationTap;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<FuelChoice> onFuelChanged;
  final VoidCallback onDismissFuelTip;
  final ValueChanged<bool> onOnlyOpenChanged;
  final VoidCallback onShowFilters;
  final ValueChanged<PublicGasStation> onOpenStation;
  final DateTime? currentTime;

  const StationDiscoveryContent({
    super.key,
    required this.snapshot,
    required this.searchController,
    required this.fuel,
    required this.onlyOpen,
    required this.minimumRatingFour,
    required this.showFuelTip,
    required this.onRefresh,
    required this.onRetry,
    required this.onLocationTap,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFuelChanged,
    required this.onDismissFuelTip,
    required this.onOnlyOpenChanged,
    required this.onShowFilters,
    required this.onOpenStation,
    this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    final allStations = snapshot.data ?? const <PublicGasStation>[];
    return ColoredBox(
      color: AppTheme.discoveryBackground,
      child: RefreshIndicator.adaptive(
        onRefresh: onRefresh,
        child: ListView(
          key: const Key('station-discovery-scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            WelcomeSummaryHeader(
              stationCount: allStations.length,
              onLocationTap: onLocationTap,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Buscar posto ou bairro',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar busca',
                          onPressed: onClearSearch,
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
            FuelSwipeSurface(
              choice: fuel,
              onChanged: onFuelChanged,
              child: FuelChoiceSelector(choice: fuel, onChanged: onFuelChanged),
            ),
            if (showFuelTip) FuelDiscoveryTip(onDismiss: onDismissFuelTip),
            Material(
              color: AppTheme.discoveryBackground,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Flexible(child: Text('Só abertos')),
                        Switch.adaptive(
                          value: onlyOpen,
                          onChanged: onOnlyOpenChanged,
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: onShowFilters,
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: Text(
                        minimumRatingFour ? 'Filtros (1)' : 'Filtros',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FuelSwipeSurface(
              choice: fuel,
              onChanged: onFuelChanged,
              child: Column(children: _buildResults(allStations)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResults(List<PublicGasStation> allStations) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const [
        SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (snapshot.hasError) {
      return [
        _MessageState(
          icon: Icons.cloud_off_rounded,
          title: 'Não foi possível carregar os postos',
          subtitle: 'Confira sua conexão e tente novamente.',
          actionLabel: 'Tentar novamente',
          onAction: onRetry,
        ),
      ];
    }

    final now = currentTime ?? DateTime.now();
    final stations = filterAndSortStations(
      allStations,
      fuel,
      onlyOpen: onlyOpen,
      moment: now,
      query: searchController.text,
      minimumRating: minimumRatingFour ? 4 : null,
    );
    if (stations.isEmpty) {
      return [
        _MessageState(
          icon: Icons.local_gas_station_outlined,
          title: onlyOpen
              ? 'Nenhum posto aberto encontrado'
              : 'Nenhum posto encontrado',
          subtitle: onlyOpen
              ? 'Desative “Só abertos” para ver todos os postos.'
              : 'Tente outro nome ou bairro.',
          actionLabel: onlyOpen ? 'Mostrar todos' : null,
          onAction: onlyOpen ? () async => onOnlyOpenChanged(false) : null,
        ),
      ];
    }

    final bestId = bestPricedStationId(stations, fuel);
    final savings = savingsPerLiter(stations, fuel);
    return [
      for (var index = 0; index < stations.length; index++) ...[
        if (index > 0) const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DiscoveryStationCard(
            key: Key('discovery-station-${stations[index].id}'),
            station: stations[index],
            fuel: fuel,
            isBestValue: stations[index].id == bestId,
            savingsPerLiter: stations[index].id == bestId ? savings : null,
            isOpen: stations[index].isOpenAt(now),
            onOpen: () => onOpenStation(stations[index]),
          ),
        ),
      ],
    ];
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.textMuted, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 7),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
