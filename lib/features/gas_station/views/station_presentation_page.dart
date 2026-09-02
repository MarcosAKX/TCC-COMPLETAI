import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../../core/widgets/station_visual_cover.dart';
import '../models/station_presentation.dart';
import '../services/station_presentation_service.dart';

class StationPresentationPage extends StatefulWidget {
  const StationPresentationPage({super.key, this.service, this.imagePicker});

  final StationPresentationService? service;
  final ImagePicker? imagePicker;

  @override
  State<StationPresentationPage> createState() =>
      _StationPresentationPageState();
}

class _StationPresentationPageState extends State<StationPresentationPage> {
  late final StationPresentationService _service =
      widget.service ?? StationPresentationService();
  late final ImagePicker _imagePicker = widget.imagePicker ?? ImagePicker();

  StationPresentation? _presentation;
  StationCoverImage? _newCover;
  Uint8List? _selectedCoverBytes;
  Uint8List? _persistedCoverBytes;
  String _draftBrand = 'Bandeira branca';
  bool _localCoverRemoved = false;
  bool _persistedCoverMarkedForRemoval = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _allowPop = false;
  String? _loadError;
  String? _message;

  @override
  void initState() {
    super.initState();
    unawaited(_loadPresentation());
  }

  Future<void> _loadPresentation() async {
    try {
      final presentation = await _service.loadCurrent();
      if (!mounted) return;
      setState(() {
        _presentation = presentation;
        _draftBrand = presentation.stationBrand;
        _persistedCoverBytes = presentation.coverImageBytes;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadError = 'Não foi possível carregar a exibição.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickCover() async {
    try {
      final file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null || !mounted) return;

      final bytes = await file.readAsBytes();
      final selection = StationCoverProcessor.normalize(
        bytes: bytes,
        fileName: file.name,
        mimeType: file.mimeType,
      );

      if (!mounted) return;
      setState(() {
        _newCover = selection;
        _selectedCoverBytes = selection.bytes;
        _localCoverRemoved = false;
        _persistedCoverMarkedForRemoval = false;
        _message = null;
      });
    } on ArgumentError {
      _showMessage('Escolha uma foto JPG, PNG ou WebP de até 5 MB.');
    } catch (_) {
      _showMessage('Não foi possível selecionar a foto. Tente novamente.');
    }
  }

  Future<void> _removeCover() async {
    final hasLocalCover = _selectedCoverBytes != null || _newCover != null;
    final hasPersistedCover = _persistedCoverBytes != null;
    if (!hasLocalCover && !hasPersistedCover) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover foto?'),
        content: Text(
          hasLocalCover
              ? 'A foto selecionada será descartada.'
              : 'A foto deixará de aparecer para os clientes após salvar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remover foto'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() {
      if (hasLocalCover) {
        _newCover = null;
        _selectedCoverBytes = null;
        _localCoverRemoved = true;
      } else {
        _persistedCoverMarkedForRemoval = true;
      }
      _message = null;
    });
  }

  Future<void> _savePresentation(String brand) async {
    final current = _presentation;
    if (current == null || _isSaving) return;

    setState(() {
      _isSaving = true;
      _message = null;
    });

    try {
      final Future<StationPresentation> operation =
          _persistedCoverMarkedForRemoval
          ? _service.removeCover(current: current, stationBrand: brand)
          : _service.savePresentation(
              current: current,
              stationBrand: brand,
              newCover: _newCover,
            );
      final saved = await operation.timeout(const Duration(seconds: 20));
      if (!mounted) return;
      setState(() {
        _presentation = saved;
        _draftBrand = saved.stationBrand;
        _newCover = null;
        _selectedCoverBytes = null;
        _persistedCoverBytes = saved.coverImageBytes;
        _localCoverRemoved = false;
        _persistedCoverMarkedForRemoval = false;
      });
      _popAuthorized(true);
    } on TimeoutException {
      _showMessage('A operação demorou demais. Tente novamente.');
    } on FirebaseException catch (error) {
      _showMessage(
        error.code == 'permission-denied'
            ? 'As permissões do Firestore ainda não permitem salvar esta exibição.'
            : 'Não foi possível salvar a exibição. Tente novamente.',
      );
    } on StateError {
      _showMessage('Sua sessão expirou. Entre novamente.');
    } on ArgumentError catch (error) {
      _showMessage(error.message?.toString() ?? 'Dados inválidos.');
    } catch (_) {
      _showMessage('Não foi possível salvar a exibição. Tente novamente.');
    } finally {
      if (mounted && _isSaving) setState(() => _isSaving = false);
    }
  }

  void _handleBrandChanged(String value) {
    if (!mounted) return;
    setState(() => _draftBrand = value);
  }

  bool get _hasPendingChanges {
    final current = _presentation;
    if (current == null) return false;
    return _draftBrand.trim() != current.stationBrand.trim() ||
        _newCover != null ||
        _localCoverRemoved ||
        _persistedCoverMarkedForRemoval;
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasPendingChanges) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text(
          'As mudanças desta exibição ainda não foram salvas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Continuar editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Descartar alterações'),
          ),
        ],
      ),
    );
    return discard == true;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    setState(() => _message = message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _popAuthorized([Object? result]) {
    if (!mounted) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowPop || !_hasPendingChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _allowPop || !await _confirmDiscard()) return;
        if (!context.mounted) return;
        _popAuthorized(result);
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Editar exibição'),
          actions: [
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.only(right: 18),
                child: Center(
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
            ? _buildLoadError()
            : _buildContent(),
      ),
    );
  }

  Widget _buildLoadError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_loadError!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _loadError = null;
                });
                unawaited(_loadPresentation());
              },
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final presentation = _presentation;
    if (presentation == null) return const SizedBox.shrink();
    return StationPresentationContent(
      initialPresentation: presentation,
      initialCoverBytes: _persistedCoverMarkedForRemoval
          ? null
          : _persistedCoverBytes,
      selectedCoverBytes: _selectedCoverBytes,
      hasPersistedCover:
          _persistedCoverBytes != null && !_persistedCoverMarkedForRemoval,
      isSaving: _isSaving,
      onPickCover: _pickCover,
      onRemoveCover: () => unawaited(_removeCover()),
      onSave: _savePresentation,
      onBrandChanged: _handleBrandChanged,
      message: _message,
    );
  }
}

class StationPresentationContent extends StatefulWidget {
  const StationPresentationContent({
    super.key,
    required this.initialPresentation,
    this.initialCoverUrl,
    this.initialCoverBytes,
    required this.selectedCoverBytes,
    required this.isSaving,
    required this.onPickCover,
    required this.onRemoveCover,
    required this.onSave,
    this.onBrandChanged,
    this.message,
    this.hasPersistedCover = false,
    this.stationName = 'Meu posto',
    this.locationLabel = 'Localização não informada',
    this.isOpen = false,
  });

  final StationPresentation initialPresentation;
  final String? initialCoverUrl;
  final Uint8List? initialCoverBytes;
  final Uint8List? selectedCoverBytes;
  final bool isSaving;
  final Future<void> Function() onPickCover;
  final VoidCallback onRemoveCover;
  final Future<void> Function(String brand) onSave;
  final ValueChanged<String>? onBrandChanged;
  final String? message;
  final bool hasPersistedCover;
  final String stationName;
  final String locationLabel;
  final bool isOpen;

  @override
  State<StationPresentationContent> createState() =>
      _StationPresentationContentState();
}

class _StationPresentationContentState
    extends State<StationPresentationContent> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedBrand;
  late final TextEditingController _customBrandController;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    final savedBrand = widget.initialPresentation.stationBrand.trim();
    _selectedBrand = stationBrandOptions.contains(savedBrand)
        ? savedBrand
        : 'Outra';
    _customBrandController = TextEditingController(
      text: _selectedBrand == 'Outra' && savedBrand != 'Outra'
          ? savedBrand
          : '',
    )..addListener(_handleCustomBrandChanged);
  }

  @override
  void dispose() {
    _customBrandController
      ..removeListener(_handleCustomBrandChanged)
      ..dispose();
    super.dispose();
  }

  void _handleCustomBrandChanged() {
    if (_selectedBrand == 'Outra') {
      widget.onBrandChanged?.call(_customBrandController.text);
    }
  }

  void _selectBrand(String? value) {
    if (value == null) return;
    setState(() {
      _selectedBrand = value;
      _validationMessage = null;
    });
    widget.onBrandChanged?.call(
      value == 'Outra' ? _customBrandController.text : value,
    );
  }

  String? _validateCustomBrand(String? value) {
    if (_selectedBrand != 'Outra') return null;
    try {
      normalizeStationBrand('Outra', value ?? '');
      return null;
    } on ArgumentError catch (error) {
      return error.message?.toString();
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    try {
      final normalized = normalizeStationBrand(
        _selectedBrand,
        _customBrandController.text,
      );
      setState(() => _validationMessage = null);
      await widget.onSave(normalized);
    } on ArgumentError catch (error) {
      if (!mounted) return;
      setState(() => _validationMessage = error.message?.toString());
    } catch (_) {
      // Persistence errors are translated by StationPresentationPage. This
      // fallback also keeps the pure content safe for injected callbacks.
      if (!mounted) return;
      setState(
        () => _validationMessage =
            'Não foi possível salvar a exibição. Tente novamente.',
      );
    }
  }

  Widget _buildBrandSection() {
    return _PresentationSection(
      title: 'Identidade do posto',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            key: const Key('station-brand-selector'),
            initialValue: _selectedBrand,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Bandeira'),
            items: stationBrandOptions
                .map(
                  (brand) => DropdownMenuItem<String>(
                    value: brand,
                    child: Text(brand),
                  ),
                )
                .toList(),
            onChanged: widget.isSaving ? null : _selectBrand,
          ),
          if (_selectedBrand == 'Outra') ...[
            const SizedBox(height: 14),
            TextFormField(
              key: const Key('station-brand-custom'),
              controller: _customBrandController,
              maxLength: 60,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Nome da bandeira',
                hintText: 'Ex.: Rede Regional',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
              validator: _validateCustomBrand,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoActions({required bool hasCover, required double scale}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 480 || scale >= 1.5;
        final pickButton = OutlinedButton.icon(
          onPressed: widget.isSaving ? null : widget.onPickCover,
          style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(hasCover ? 'Substituir foto' : 'Selecionar foto'),
        );
        final removeButton = OutlinedButton.icon(
          onPressed: widget.isSaving || !hasCover ? null : widget.onRemoveCover,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, 48),
            foregroundColor: AppTheme.error,
            side: BorderSide(color: AppTheme.error.withValues(alpha: 0.55)),
          ),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Remover foto'),
        );
        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              pickButton,
              if (hasCover) ...[const SizedBox(height: 10), removeButton],
            ],
          );
        }
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [pickButton, if (hasCover) removeButton],
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 52,
      child: FilledButton.icon(
        onPressed: widget.isSaving ? null : _save,
        icon: widget.isSaving
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_outlined),
        label: const Text('Salvar exibição'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCover =
        widget.selectedCoverBytes != null ||
        widget.initialCoverBytes != null ||
        (widget.initialCoverUrl?.trim().isNotEmpty ?? false) ||
        widget.hasPersistedCover;
    final scale = MediaQuery.textScalerOf(context).scale(1);

    return ResponsiveContent(
      maxWidth: 720,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      scrollable: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Editar exibição',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Escolha como o posto será apresentado para quem procura onde abastecer.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            _buildBrandSection(),
            if (widget.message != null || _validationMessage != null) ...[
              const SizedBox(height: 14),
              Text(
                widget.message ?? _validationMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            StationVisualCover(
              stationName: widget.stationName,
              locationLabel: widget.locationLabel,
              isOpen: widget.isOpen,
              compact: true,
              coverImageUrl: widget.selectedCoverBytes == null
                  ? widget.initialCoverUrl
                  : null,
              coverImageBytes:
                  widget.selectedCoverBytes ?? widget.initialCoverBytes,
              stationBrand: _selectedBrand == 'Outra'
                  ? (_customBrandController.text.trim().isEmpty
                        ? 'Bandeira branca'
                        : _customBrandController.text.trim())
                  : _selectedBrand,
            ),
            const SizedBox(height: 8),
            _buildPhotoActions(hasCover: hasCover, scale: scale),
            const SizedBox(height: 22),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }
}

class _PresentationSection extends StatelessWidget {
  const _PresentationSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
