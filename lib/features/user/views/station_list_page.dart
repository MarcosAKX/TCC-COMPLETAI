import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_user_avatar.dart';
import '../../../core/widgets/welcome_summary_header.dart';
import '../../gas_station/models/public_gas_station.dart';
import '../models/station_discovery_filter.dart';
import '../services/public_station_service.dart';
import '../widgets/discovery_station_card.dart';
import '../widgets/fuel_choice_selector.dart';
import '../widgets/fuel_swipe_surface.dart';
import 'public_station_profile_page.dart';

class StationListPage extends StatefulWidget {
  const StationListPage({super.key});

  @override
  State<StationListPage> createState() => _StationListPageState();
}

class _StationListPageState extends State<StationListPage> {
  static bool _onboardingShownThisSession = false;
  final PublicStationService _service = PublicStationService();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<PublicGasStation>> _stationsFuture;
  FuelChoice _fuel = FuelChoice.gasoline;
  bool _onlyOpen = false;
  bool _isRefreshing = false;
  bool _minimumRatingFour = false;

  @override
  void initState() {
    super.initState();
    _stationsFuture = _service.getStations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_onboardingShownThisSession && mounted) {
        _onboardingShownThisSession = true;
        _showFirstUseGuide();
      }
    });
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

  Future<void> _showFirstUseGuide() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Abasteça com mais confiança',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 7),
              Text(
                'Encontre a melhor opção sem perder tempo.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              const _GuideItem(
                icon: Icons.local_gas_station_outlined,
                text: 'Escolha seu combustível',
              ),
              const _GuideItem(
                icon: Icons.price_check_outlined,
                text: 'Compare preços atualizados',
              ),
              const _GuideItem(
                icon: Icons.swipe_outlined,
                text: 'Deslize para alternar combustíveis',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Ver postos'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                final allStations = snapshot.data ?? const <PublicGasStation>[];
                return Column(
                  children: [
                    WelcomeSummaryHeader(
                      stationCount: allStations.length,
                      onLocationTap: _showLocationInfo,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Buscar posto ou bairro',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Limpar busca',
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                      ),
                    ),
                    FuelSwipeSurface(
                      choice: _fuel,
                      onChanged: (fuel) => setState(() => _fuel = fuel),
                      child: FuelChoiceSelector(
                        choice: _fuel,
                        onChanged: (fuel) => setState(() => _fuel = fuel),
                      ),
                    ),
                    Material(
                      color: AppTheme.discoveryBackground,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
                        child: Row(
                          children: [
                            const Text('Só abertos'),
                            Switch.adaptive(
                              value: _onlyOpen,
                              onChanged: (value) =>
                                  setState(() => _onlyOpen = value),
                            ),
                            const Spacer(),
                            OutlinedButton.icon(
                              onPressed: _showFilters,
                              icon: const Icon(Icons.tune_rounded, size: 18),
                              label: Text(
                                _minimumRatingFour ? 'Filtros (1)' : 'Filtros',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: FuelSwipeSurface(
                        choice: _fuel,
                        onChanged: (fuel) => setState(() => _fuel = fuel),
                        child: ColoredBox(
                          color: AppTheme.discoveryBackground,
                          child: _buildResults(snapshot, allStations),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults(
    AsyncSnapshot<List<PublicGasStation>> snapshot,
    List<PublicGasStation> allStations,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return _MessageState(
        icon: Icons.cloud_off_rounded,
        title: 'Não foi possível carregar os postos',
        subtitle: 'Confira sua conexão e tente novamente.',
        actionLabel: 'Tentar novamente',
        onAction: _reload,
      );
    }

    final now = DateTime.now();
    final stations = filterAndSortStations(
      allStations,
      _fuel,
      onlyOpen: _onlyOpen,
      moment: now,
      query: _searchController.text,
      minimumRating: _minimumRatingFour ? 4 : null,
    );
    if (stations.isEmpty) {
      return _MessageState(
        icon: Icons.local_gas_station_outlined,
        title: _onlyOpen
            ? 'Nenhum posto aberto encontrado'
            : 'Nenhum posto encontrado',
        subtitle: _onlyOpen
            ? 'Desative “Só abertos” para ver todos os postos.'
            : 'Tente outro nome ou bairro.',
        actionLabel: _onlyOpen ? 'Mostrar todos' : null,
        onAction: _onlyOpen
            ? () async => setState(() => _onlyOpen = false)
            : null,
      );
    }

    final bestId = bestPricedStationId(stations, _fuel);
    final savings = savingsPerLiter(stations, _fuel);
    return RefreshIndicator.adaptive(
      onRefresh: _refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        itemCount: stations.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final station = stations[index];
          return DiscoveryStationCard(
            station: station,
            fuel: _fuel,
            isBestValue: station.id == bestId,
            savingsPerLiter: station.id == bestId ? savings : null,
            isOpen: station.isOpenAt(now),
            onOpen: () => _openStation(station),
          );
        },
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GuideItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
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
