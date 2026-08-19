import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/station_logo.dart';
import '../../../core/widgets/status_pill.dart';
import '../models/station_review.dart';
import '../services/gas_station_service.dart';

class StationDashboardPage extends StatefulWidget {
  const StationDashboardPage({super.key});

  @override
  State<StationDashboardPage> createState() => _StationDashboardPageState();
}

class _StationDashboardPageState extends State<StationDashboardPage> {
  static const Color _panelColor = AppTheme.card;
  static const Color _borderColor = AppTheme.outline;

  static const Map<String, String> _fuelLabels = {
    'gasolineRegular': 'Gasolina comum',
    'gasolineAdditive': 'Gasolina aditivada',
    'ethanol': 'Etanol',
    'dieselS10': 'Diesel S10',
    'dieselS500': 'Diesel S500',
  };

  static const Map<String, String> _dayLabels = {
    'monday': 'Segunda-feira',
    'tuesday': 'Terça-feira',
    'wednesday': 'Quarta-feira',
    'thursday': 'Quinta-feira',
    'friday': 'Sexta-feira',
    'saturday': 'Sábado',
    'sunday': 'Domingo',
  };

  static const List<String> _availableTags = [
    '24 horas',
    'Rodovia',
    'Centro',
    'Aceita Pix',
    'Aceita cartões',
    'Pet friendly',
  ];

  static const List<String> _availableServices = [
    'Conveniência',
    'Lava-jato',
    'Troca de óleo',
    'Calibragem',
    'Wi-Fi grátis',
    'Restaurante',
    'Banheiro',
    'Mecânica',
  ];

  final GasStationService _service = GasStationService();
  final Map<String, TextEditingController> _priceControllers = {
    for (final key in _fuelLabels.keys) key: TextEditingController(),
  };
  final Map<String, String> _initialPriceValues = {};

  final Set<String> _selectedTags = {};
  final Set<String> _selectedServices = {};
  Map<String, Map<String, dynamic>> _openingHours = _buildDefaultOpeningHours();

  String _stationName = 'Meu posto';
  String _stationAddress = '';
  DateTime? _lastUpdatedAt;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    for (final controller in _priceControllers.values) {
      controller.addListener(_handlePriceChanged);
    }
    _loadStationData();
  }

  void _handlePriceChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final controller in _priceControllers.values) {
      controller.removeListener(_handlePriceChanged);
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadStationData() async {
    try {
      final data = await _service.getCurrentStationData();
      if (!mounted) return;

      if (data != null) {
        _applyStationData(data);
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Não foi possível carregar os dados administrativos.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyStationData(Map<String, dynamic> data) {
    _stationName = (data['name'] as String?)?.trim().isNotEmpty == true
        ? (data['name'] as String).trim()
        : 'Meu posto';

    final address = (data['address'] as String?)?.trim() ?? '';
    final neighborhood = (data['neighborhood'] as String?)?.trim() ?? '';
    final city = (data['city'] as String?)?.trim() ?? '';
    _stationAddress = [
      address,
      neighborhood,
      city,
    ].where((value) => value.isNotEmpty).join(' • ');

    final rawPrices = data['fuelPrices'];
    if (rawPrices is Map) {
      for (final entry in rawPrices.entries) {
        final controller = _priceControllers[entry.key];
        final value = entry.value;
        if (controller != null && value is num) {
          controller.text = value.toStringAsFixed(3).replaceAll('.', ',');
        }
      }
    }
    _initialPriceValues
      ..clear()
      ..addEntries(
        _priceControllers.entries.map(
          (entry) => MapEntry(entry.key, _normalizePrice(entry.value.text)),
        ),
      );

    _selectedTags
      ..clear()
      ..addAll(_stringSet(data['tags']));
    _selectedServices
      ..clear()
      ..addAll(_stringSet(data['services']));
    _openingHours = _parseOpeningHours(data['openingHours']);

    final rawUpdatedAt = data['updatedAt'];
    if (rawUpdatedAt is Timestamp) {
      _lastUpdatedAt = rawUpdatedAt.toDate();
    }
  }

  Set<String> _stringSet(dynamic value) {
    if (value is! List) return {};
    return value.whereType<String>().toSet();
  }

  Map<String, Map<String, dynamic>> _parseOpeningHours(dynamic value) {
    final defaults = _buildDefaultOpeningHours();
    if (value is! Map) return defaults;

    for (final day in _dayLabels.keys) {
      final rawSchedule = value[day];
      if (rawSchedule is Map) {
        defaults[day] = {
          'enabled': rawSchedule['enabled'] == true,
          'open': rawSchedule['open'] is String
              ? rawSchedule['open']
              : defaults[day]!['open'],
          'close': rawSchedule['close'] is String
              ? rawSchedule['close']
              : defaults[day]!['close'],
        };
      }
    }
    return defaults;
  }

  Future<void> _saveAdministrativeData() async {
    final fuelPrices = <String, double>{};

    for (final entry in _priceControllers.entries) {
      final rawValue = entry.value.text.trim();
      if (rawValue.isEmpty) continue;

      final price = double.tryParse(rawValue.replaceAll(',', '.'));
      if (price == null || price <= 0 || price > 50) {
        _showMessage('Confira os preços informados.');
        return;
      }
      fuelPrices[entry.key] = price;
    }

    setState(() => _isSaving = true);

    try {
      await _service.updateAdministrativeData(
        fuelPrices: fuelPrices,
        tags: _selectedTags,
        openingHours: _openingHours,
        services: _selectedServices,
      );

      if (!mounted) return;
      setState(() {
        _lastUpdatedAt = DateTime.now();
        _initialPriceValues
          ..clear()
          ..addEntries(
            _priceControllers.entries.map(
              (entry) => MapEntry(entry.key, _normalizePrice(entry.value.text)),
            ),
          );
      });
      _showMessage(
        'Tudo certo. Seus preços já estão visíveis para os clientes.',
      );
    } catch (_) {
      if (mounted) {
        _showMessage('Não foi possível atualizar o posto.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _selectTime(String day, String field) async {
    final schedule = _openingHours[day]!;
    final initialTime = _parseTime(schedule[field] as String);
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: field == 'open'
          ? 'Horário de abertura'
          : 'Horário de fechamento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (selectedTime == null || !mounted) return;

    setState(() {
      _openingHours[day] = {...schedule, field: _formatTime(selectedTime)};
    });
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return const TimeOfDay(hour: 8, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool get _isOpenNow {
    final now = DateTime.now();
    final day = _dayLabels.keys.elementAt(now.weekday - 1);
    final schedule = _openingHours[day]!;
    if (schedule['enabled'] != true) return false;

    final currentMinutes = now.hour * 60 + now.minute;
    final open = _timeInMinutes(schedule['open'] as String);
    final close = _timeInMinutes(schedule['close'] as String);

    if (close < open) {
      return currentMinutes >= open || currentMinutes <= close;
    }
    return currentMinutes >= open && currentMinutes <= close;
  }

  int _timeInMinutes(String value) {
    final time = _parseTime(value);
    return time.hour * 60 + time.minute;
  }

  String get _lastUpdatedText {
    final date = _lastUpdatedAt;
    if (date == null) return 'Ainda não atualizado';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month às $hour:$minute';
  }

  String _normalizePrice(String value) => value.trim().replaceAll('.', ',');

  int get _changedPriceCount => _priceControllers.entries.where((entry) {
    return _normalizePrice(entry.value.text) !=
        (_initialPriceValues[entry.key] ?? '');
  }).length;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        children: [
                          _buildAdministrationTab(),
                          _buildReviewsTab(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(bottom: BorderSide(color: AppTheme.outline)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.elevatedSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.outline),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'C!',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Completai!',
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              StatusPill(isOpen: _isOpenNow),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Notificações',
                onPressed: () => _showMessage('Você não possui notificações.'),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: 'Editar perfil do posto',
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.stationProfile);
                  },
                  child: StationLogo(stationName: _stationName, size: 42),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: TabBar(
            indicatorColor: AppTheme.primary,
            indicatorWeight: 3,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textMuted,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(icon: Icon(Icons.dashboard_outlined), text: 'Administração'),
              Tab(icon: Icon(Icons.star_outline_rounded), text: 'Avaliações'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdministrationTab() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atualizar preços',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Mantenha os valores corretos para quem vai abastecer.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildPricesCard(),
                const SizedBox(height: 20),
                _buildStationSummary(),
                const SizedBox(height: 20),
                _buildTagsCard(),
                const SizedBox(height: 20),
                _buildServicesCard(),
                const SizedBox(height: 20),
                _buildOpeningHoursCard(),
                const SizedBox(height: 20),
                SizedBox(
                  height: 54,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveAdministrativeData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppTheme.primary.withValues(
                        alpha: 0.55,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      _isSaving ? 'Salvando...' : 'Salvar alterações',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStationSummary() {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _stationName,
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (_stationAddress.isNotEmpty) ...[
                      const SizedBox(height: 9),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppTheme.textMuted,
                            size: 17,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _stationAddress,
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Editar dados cadastrais',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.stationProfile);
                },
                icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.background.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.update_rounded,
                  size: 19,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Última atualização: $_lastUpdatedText',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricesCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.savings.withValues(alpha: 0.35)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: ColoredBox(
          color: AppTheme.savingsSurface.withValues(alpha: 0.45),
          child: _DashboardCard(
            title: 'Painel de preços',
            subtitle: 'Clientes verão os novos valores assim que você publicar',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _changedPriceCount == 0
                      ? const Text(
                          'Seus valores ficam preservados enquanto você edita.',
                          key: ValueKey('unchanged'),
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        )
                      : Text(
                          '$_changedPriceCount ${_changedPriceCount == 1 ? 'preço alterado' : 'preços alterados'}',
                          key: const ValueKey('changed'),
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final fieldWidth = constraints.maxWidth >= 650
                        ? (constraints.maxWidth - 14) / 2
                        : constraints.maxWidth;
                    return Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: _fuelLabels.entries.map((entry) {
                        return SizedBox(
                          width: fieldWidth,
                          child: _FuelPriceField(
                            label: entry.value,
                            controller: _priceControllers[entry.key]!,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSaving || _changedPriceCount == 0
                        ? null
                        : _saveAdministrativeData,
                    icon: _isSaving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.publish_outlined),
                    label: Text(
                      _isSaving ? 'Publicando...' : 'Publicar novos preços',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagsCard() {
    return _DashboardCard(
      title: 'Tags do posto',
      subtitle: 'Destaque características que ajudam o cliente a escolher',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _availableTags.map((tag) {
          final selected = _selectedTags.contains(tag);
          return FilterChip(
            selected: selected,
            label: Text(tag),
            avatar: Icon(
              selected ? Icons.check_circle : Icons.add_circle_outline,
              size: 18,
            ),
            onSelected: (value) {
              setState(() {
                value ? _selectedTags.add(tag) : _selectedTags.remove(tag);
              });
            },
            selectedColor: AppTheme.primary.withValues(alpha: 0.2),
            checkmarkColor: AppTheme.primary,
            backgroundColor: AppTheme.background.withValues(alpha: 0.45),
            side: BorderSide(color: selected ? AppTheme.primary : _borderColor),
            labelStyle: TextStyle(
              color: selected ? AppTheme.primary : AppTheme.textMuted,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildServicesCard() {
    return _DashboardCard(
      title: 'Serviços oferecidos',
      subtitle: 'Selecione tudo que está disponível no local',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth >= 600
              ? (constraints.maxWidth - 12) / 2
              : constraints.maxWidth;

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _availableServices.map((service) {
              final selected = _selectedServices.contains(service);
              return SizedBox(
                width: itemWidth,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      selected
                          ? _selectedServices.remove(service)
                          : _selectedServices.add(service);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primary.withValues(alpha: 0.12)
                          : AppTheme.background.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppTheme.primary : _borderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.textMuted,
                            ),
                          ),
                          child: selected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            service,
                            style: const TextStyle(color: AppTheme.textLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildOpeningHoursCard() {
    return _DashboardCard(
      title: 'Horário de funcionamento',
      subtitle: 'Desative o dia quando o posto estiver fechado',
      child: Column(
        children: _dayLabels.entries.map((entry) {
          final day = entry.key;
          final schedule = _openingHours[day]!;
          final enabled = schedule['enabled'] == true;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.background.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 570;
                  final dayControl = Row(
                    children: [
                      Switch.adaptive(
                        value: enabled,
                        activeTrackColor: AppTheme.primary,
                        onChanged: (value) {
                          setState(() {
                            _openingHours[day] = {
                              ...schedule,
                              'enabled': value,
                            };
                          });
                        },
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            color: AppTheme.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );

                  final hoursControl = enabled
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _TimeButton(
                              label: schedule['open'] as String,
                              onPressed: () => _selectTime(day, 'open'),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'até',
                                style: TextStyle(color: AppTheme.textMuted),
                              ),
                            ),
                            _TimeButton(
                              label: schedule['close'] as String,
                              onPressed: () => _selectTime(day, 'close'),
                            ),
                          ],
                        )
                      : const Text(
                          'Fechado',
                          style: TextStyle(
                            color: AppTheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        dayControl,
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: hoursControl,
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: dayControl),
                      hoursControl,
                    ],
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return StreamBuilder<List<StationReview>>(
      stream: _service.watchCurrentStationReviews(),
      builder: (context, reviewsSnapshot) {
        if (reviewsSnapshot.hasError) {
          return _buildReviewsError();
        }
        if (!reviewsSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reviews = reviewsSnapshot.data!;

        return StreamBuilder<Set<String>>(
          stream: _service.watchReportedReviewIds(),
          builder: (context, reportsSnapshot) {
            final reportedIds = reportsSnapshot.data ?? <String>{};
            return _buildReviewsContent(reviews, reportedIds);
          },
        );
      },
    );
  }

  Widget _buildReviewsContent(
    List<StationReview> reviews,
    Set<String> reportedIds,
  ) {
    final average = reviews.isEmpty
        ? 0.0
        : reviews.fold<double>(0, (total, review) => total + review.rating) /
              reviews.length;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                _DashboardCard(
                  child: Row(
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: AppTheme.rating.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.star_rounded,
                          color: AppTheme.rating,
                          size: 34,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reviews.isEmpty
                                  ? 'Sem avaliações'
                                  : average.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppTheme.textLight,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              reviews.isEmpty
                                  ? 'As avaliações aparecerão aqui'
                                  : '${reviews.length} ${reviews.length == 1 ? 'avaliação' : 'avaliações'}',
                              style: const TextStyle(color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (reviews.isEmpty)
                  _buildEmptyReviews()
                else
                  ...reviews.map(
                    (review) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ReviewCard(
                        review: review,
                        alreadyReported: reportedIds.contains(review.id),
                        onReport: () => _reportReview(review),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyReviews() {
    return _DashboardCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            Icon(
              Icons.reviews_outlined,
              size: 48,
              color: AppTheme.textMuted.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 14),
            const Text(
              'Nenhuma avaliação recebida',
              style: TextStyle(
                color: AppTheme.textLight,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Quando clientes avaliarem o posto, os comentários aparecerão nesta aba.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 46,
              color: AppTheme.error,
            ),
            const SizedBox(height: 12),
            const Text(
              'Não foi possível carregar as avaliações.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textLight),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => setState(() {}),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reportReview(StationReview review) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) =>
          _ReportReviewDialog(authorName: review.authorName),
    );

    if (reason == null || !mounted) return;

    try {
      await _service.reportReview(reviewId: review.id, reason: reason);
      if (mounted) {
        _showMessage('Avaliação enviada para análise.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Não foi possível denunciar esta avaliação.');
      }
    }
  }

  static Map<String, Map<String, dynamic>> _buildDefaultOpeningHours() {
    return {
      'monday': {'enabled': true, 'open': '06:00', 'close': '22:00'},
      'tuesday': {'enabled': true, 'open': '06:00', 'close': '22:00'},
      'wednesday': {'enabled': true, 'open': '06:00', 'close': '22:00'},
      'thursday': {'enabled': true, 'open': '06:00', 'close': '22:00'},
      'friday': {'enabled': true, 'open': '06:00', 'close': '22:00'},
      'saturday': {'enabled': true, 'open': '06:00', 'close': '20:00'},
      'sunday': {'enabled': false, 'open': '08:00', 'close': '18:00'},
    };
  }
}

class _DashboardCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;

  const _DashboardCard({this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _StationDashboardPageState._panelColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                color: AppTheme.textLight,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 5),
              Text(
                subtitle!,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 18),
          ],
          child,
        ],
      ),
    );
  }
}

class _FuelPriceField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _FuelPriceField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
        LengthLimitingTextInputFormatter(7),
      ],
      style: const TextStyle(
        color: AppTheme.textLight,
        fontWeight: FontWeight.w600,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
      decoration: InputDecoration(
        labelText: label,
        helperText: 'Preço por litro',
        prefixText: 'R\$  ',
        prefixStyle: const TextStyle(color: AppTheme.textMuted),
        filled: true,
        fillColor: AppTheme.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _StationDashboardPageState._borderColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _StationDashboardPageState._borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _TimeButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.textLight,
        side: const BorderSide(color: _StationDashboardPageState._borderColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.schedule_rounded, size: 16),
      label: Text(label),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final StationReview review;
  final bool alreadyReported;
  final VoidCallback onReport;

  const _ReviewCard({
    required this.review,
    required this.alreadyReported,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                child: Text(
                  _initials(review.authorName),
                  style: const TextStyle(
                    color: AppTheme.primaryInteractive,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < review.rating.round()
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 17,
                          color: AppTheme.rating,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: alreadyReported ? null : onReport,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  disabledForegroundColor: AppTheme.textMuted,
                  side: BorderSide(
                    color: alreadyReported
                        ? _StationDashboardPageState._borderColor
                        : AppTheme.error.withValues(alpha: 0.45),
                  ),
                ),
                icon: Icon(
                  alreadyReported
                      ? Icons.check_circle_outline
                      : Icons.flag_outlined,
                  size: 16,
                ),
                label: Text(alreadyReported ? 'Reportada' : 'Denunciar'),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              review.comment,
              style: const TextStyle(color: AppTheme.textMuted, height: 1.5),
            ),
          ],
          const SizedBox(height: 13),
          Text(
            _relativeDate(review.createdAt),
            style: TextStyle(
              color: AppTheme.textMuted.withValues(alpha: 0.75),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return 'U';
    if (words.length == 1) return words.first[0].toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  static String _relativeDate(DateTime? date) {
    if (date == null) return 'Data não informada';
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 1) return 'Agora';
    if (difference.inHours < 1) {
      return 'Há ${difference.inMinutes} min';
    }
    if (difference.inDays < 1) {
      return 'Há ${difference.inHours} h';
    }
    if (difference.inDays < 7) {
      return 'Há ${difference.inDays} ${difference.inDays == 1 ? 'dia' : 'dias'}';
    }
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _ReportReviewDialog extends StatefulWidget {
  final String authorName;

  const _ReportReviewDialog({required this.authorName});

  @override
  State<_ReportReviewDialog> createState() => _ReportReviewDialogState();
}

class _ReportReviewDialogState extends State<_ReportReviewDialog> {
  static const List<String> _reasons = [
    'Conteúdo ofensivo',
    'Palavrões ou baixo calão',
    'Discurso de ódio',
    'Spam ou conteúdo falso',
    'Outro',
  ];

  String _selectedReason = _reasons.first;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.card,
      title: const Text(
        'Denunciar avaliação',
        style: TextStyle(color: AppTheme.textLight),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informe o motivo da denúncia da avaliação de ${widget.authorName}.',
            style: const TextStyle(color: AppTheme.textMuted, height: 1.4),
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            initialValue: _selectedReason,
            dropdownColor: AppTheme.card,
            decoration: const InputDecoration(
              labelText: 'Motivo',
              border: OutlineInputBorder(),
            ),
            items: _reasons.map((reason) {
              return DropdownMenuItem(value: reason, child: Text(reason));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedReason = value);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
          onPressed: () => Navigator.pop(context, _selectedReason),
          icon: const Icon(Icons.flag_outlined, size: 18),
          label: const Text('Enviar denúncia'),
        ),
      ],
    );
  }
}
