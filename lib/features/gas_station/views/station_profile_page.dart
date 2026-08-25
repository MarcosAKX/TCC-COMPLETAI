import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/adaptive_action_row.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../../core/widgets/station_logo.dart';
import '../services/gas_station_service.dart';

class StationProfilePage extends StatefulWidget {
  const StationProfilePage({super.key});

  @override
  State<StationProfilePage> createState() => _StationProfilePageState();
}

class _StationProfilePageState extends State<StationProfilePage> {
  final GasStationService _gasStationService = GasStationService();
  final TextEditingController _stationNameController = TextEditingController();
  final TextEditingController _cnpjController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStationData();
  }

  @override
  void dispose() {
    _stationNameController.dispose();
    _cnpjController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadStationData() async {
    try {
      final data = await _gasStationService.getCurrentStationData();
      if (!mounted) return;

      if (data != null) {
        _stationNameController.text = data['name'] ?? '';
        _cnpjController.text = data['cnpj'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _emailController.text = data['email'] ?? '';
        _addressController.text = data['address'] ?? '';
        _districtController.text = data['neighborhood'] ?? '';
        _cityController.text = data['city'] ?? '';
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Não foi possível carregar o perfil do posto.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editField({
    required String title,
    required String field,
    required TextEditingController controller,
  }) async {
    final tempController = TextEditingController(text: controller.text);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text(
          'Alterar $title',
          style: Theme.of(
            dialogContext,
          ).textTheme.titleLarge?.copyWith(color: AppTheme.textLight),
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.45,
          ),
          child: SingleChildScrollView(
            child: TextField(
              controller: tempController,
              style: Theme.of(
                dialogContext,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.textLight),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryInteractive),
                ),
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
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await _gasStationService.updateStationField(
                        field: field,
                        value: tempController.text.trim(),
                      );
                      if (!mounted) return;

                      setState(() {
                        controller.text = tempController.text.trim();
                      });
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                      _showMessage('$title atualizado com sucesso!');
                    } catch (_) {
                      if (mounted) {
                        _showMessage('Não foi possível atualizar $title.');
                      }
                    }
                  },
                  child: const Text(
                    'Salvar',
                    style: TextStyle(color: AppTheme.primaryInteractive),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    tempController.dispose();
  }

  Future<void> _openChangePasswordModal() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.card,
      isScrollControlled: true,
      builder: (_) => StationPasswordSheet(
        currentPasswordController: oldPasswordController,
        newPasswordController: newPasswordController,
        confirmationController: confirmPasswordController,
        onSave: () async {
          if (oldPasswordController.text.isEmpty ||
              newPasswordController.text.length < 6) {
            _showMessage(
              'Informe a senha atual e uma nova senha com pelo menos 6 caracteres.',
            );
            return;
          }
          if (newPasswordController.text != confirmPasswordController.text) {
            _showMessage('As senhas não coincidem.');
            return;
          }

          try {
            await _gasStationService.updatePassword(
              oldPassword: oldPasswordController.text,
              newPassword: newPasswordController.text,
            );
            if (!mounted) return;

            Navigator.pop(context);
            _showMessage('Senha alterada com sucesso!');
          } catch (_) {
            if (mounted) _showMessage('Erro ao alterar senha.');
          }
        },
      ),
    );

    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Perfil do posto',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Configurações',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            icon: const Icon(Icons.settings, color: AppTheme.textLight),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StationProfileContent(
              stationName: _stationNameController.text,
              cnpj: _cnpjController.text,
              phone: _phoneController.text,
              email: _emailController.text,
              address: _addressController.text,
              neighborhood: _districtController.text,
              city: _cityController.text,
              onEditName: () => _editField(
                title: 'Nome do posto',
                field: 'name',
                controller: _stationNameController,
              ),
              onEditPhone: () => _editField(
                title: 'Telefone',
                field: 'phone',
                controller: _phoneController,
              ),
              onEditAddress: () => _editField(
                title: 'Endereço',
                field: 'address',
                controller: _addressController,
              ),
              onEditNeighborhood: () => _editField(
                title: 'Bairro',
                field: 'neighborhood',
                controller: _districtController,
              ),
              onEditCity: () => _editField(
                title: 'Cidade',
                field: 'city',
                controller: _cityController,
              ),
              onChangePassword: _openChangePasswordModal,
            ),
    );
  }
}

class StationProfileContent extends StatelessWidget {
  const StationProfileContent({
    super.key,
    required this.stationName,
    required this.cnpj,
    required this.phone,
    required this.email,
    required this.address,
    required this.neighborhood,
    required this.city,
    required this.onEditName,
    required this.onEditPhone,
    required this.onEditAddress,
    required this.onEditNeighborhood,
    required this.onEditCity,
    required this.onChangePassword,
  });

  final String stationName;
  final String cnpj;
  final String phone;
  final String email;
  final String address;
  final String neighborhood;
  final String city;
  final VoidCallback onEditName;
  final VoidCallback onEditPhone;
  final VoidCallback onEditAddress;
  final VoidCallback onEditNeighborhood;
  final VoidCallback onEditCity;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) {
    return ResponsiveContent(
      maxWidth: 560,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      scrollable: true,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outline),
        ),
        child: Column(
          children: [
            StationLogo(stationName: stationName, size: 72),
            const SizedBox(height: 16),
            Text(
              stationName.isEmpty ? 'Perfil do posto' : stationName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            _StationInfoTile(
              title: 'Nome do posto',
              value: stationName,
              icon: Icons.local_gas_station,
              onEdit: onEditName,
            ),
            const SizedBox(height: 16),
            _StationInfoTile(
              title: 'CNPJ',
              value: cnpj,
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 16),
            _StationInfoTile(
              title: 'Telefone',
              value: phone,
              icon: Icons.phone_outlined,
              onEdit: onEditPhone,
            ),
            const SizedBox(height: 16),
            _StationInfoTile(
              title: 'E-mail administrativo',
              value: email,
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            _StationInfoTile(
              title: 'Endereço',
              value: address,
              icon: Icons.map_outlined,
              onEdit: onEditAddress,
            ),
            const SizedBox(height: 16),
            _StationInfoTile(
              title: 'Bairro',
              value: neighborhood,
              icon: Icons.location_city,
              onEdit: onEditNeighborhood,
            ),
            const SizedBox(height: 16),
            _StationInfoTile(
              title: 'Cidade',
              value: city,
              icon: Icons.location_on_outlined,
              onEdit: onEditCity,
            ),
            const SizedBox(height: 24),
            AdaptiveActionRow(
              children: [
                CustomButton(
                  key: const Key('station-profile-change-password-action'),
                  text: 'Alterar senha',
                  onPressed: onChangePassword,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StationPasswordSheet extends StatelessWidget {
  const StationPasswordSheet({
    super.key,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmationController,
    required this.onSave,
  });

  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmationController;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maximumHeight =
        (mediaQuery.size.height - mediaQuery.viewInsets.bottom)
            .clamp(0.0, mediaQuery.size.height * 0.92)
            .toDouble();

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          key: const Key('station-password-sheet'),
          constraints: BoxConstraints(maxHeight: maximumHeight),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Alterar senha',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      CustomTextField(
                        label: 'Senha atual',
                        hint: '********',
                        icon: Icons.lock_outline,
                        controller: currentPasswordController,
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Nova senha',
                        hint: '********',
                        icon: Icons.lock_outline,
                        controller: newPasswordController,
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Confirmar nova senha',
                        hint: '********',
                        icon: Icons.lock_outline,
                        controller: confirmationController,
                        obscureText: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomButton(text: 'Salvar nova senha', onPressed: onSave),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StationInfoTile extends StatelessWidget {
  const _StationInfoTile({
    required this.title,
    required this.value,
    required this.icon,
    this.onEdit,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: AppTheme.primaryInteractive),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              tooltip: 'Editar $title',
              onPressed: onEdit,
              icon: const Icon(Icons.edit, color: AppTheme.primaryInteractive),
            ),
        ],
      ),
    );
  }
}
