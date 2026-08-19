import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/station_logo.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/responsive_form_content.dart';
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    final TextEditingController tempController = TextEditingController(
      text: controller.text,
    );

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppTheme.card,

          title: Text(
            'Alterar $title',
            style: const TextStyle(color: AppTheme.textLight),
          ),

          content: TextField(
            controller: tempController,

            style: const TextStyle(color: AppTheme.textLight),

            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.outline),
              ),

              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.primaryInteractive),
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

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

                  Navigator.pop(context);

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
        );
      },
    );

    tempController.dispose();
  }

  Future<void> _openChangePasswordModal() async {
    final oldPasswordController = TextEditingController();

    final newPasswordController = TextEditingController();

    final confirmPasswordController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      isScrollControlled: true,

      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                const Text(
                  'Alterar senha',
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                CustomTextField(
                  label: 'Senha atual',
                  hint: '********',
                  icon: Icons.lock_outline,
                  controller: oldPasswordController,
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
                  controller: confirmPasswordController,
                  obscureText: true,
                ),

                const SizedBox(height: 24),

                CustomButton(
                  text: 'Salvar nova senha',

                  onPressed: () async {
                    if (oldPasswordController.text.isEmpty ||
                        newPasswordController.text.length < 6) {
                      _showMessage(
                        'Informe a senha atual e uma nova senha com pelo menos 6 caracteres.',
                      );
                      return;
                    }

                    if (newPasswordController.text !=
                        confirmPasswordController.text) {
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
                      if (mounted) {
                        _showMessage('Erro ao alterar senha.');
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
    bool editable = false,
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),

      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: AppTheme.outline),
      ),

      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryInteractive),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          if (editable)
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, color: AppTheme.primaryInteractive),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        backgroundColor: AppTheme.background,

        elevation: 0,

        centerTitle: true,

        title: const Text(
          'Perfil do posto',
          style: TextStyle(
            color: AppTheme.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },

            icon: const Icon(Icons.settings, color: AppTheme.textLight),
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: ResponsiveFormContent(
                  maxWidth: 560,
                  child: Container(
                    padding: const EdgeInsets.all(24),

                    decoration: BoxDecoration(
                      color: AppTheme.card,

                      borderRadius: BorderRadius.circular(20),

                      border: Border.all(color: AppTheme.outline),
                    ),

                    child: Column(
                      children: [
                        StationLogo(
                          stationName: _stationNameController.text,
                          size: 72,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          _stationNameController.text.isEmpty
                              ? 'Perfil do posto'
                              : _stationNameController.text,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),

                        const SizedBox(height: 24),

                        _buildInfoTile(
                          title: 'Nome do posto',
                          value: _stationNameController.text,
                          icon: Icons.local_gas_station,
                          editable: true,
                          onEdit: () {
                            _editField(
                              title: 'Nome do posto',
                              field: 'name',
                              controller: _stationNameController,
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildInfoTile(
                          title: 'CNPJ',
                          value: _cnpjController.text,
                          icon: Icons.badge_outlined,
                        ),

                        const SizedBox(height: 16),

                        _buildInfoTile(
                          title: 'Telefone',
                          value: _phoneController.text,
                          icon: Icons.phone_outlined,
                          editable: true,
                          onEdit: () {
                            _editField(
                              title: 'Telefone',
                              field: 'phone',
                              controller: _phoneController,
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildInfoTile(
                          title: 'E-mail administrativo',
                          value: _emailController.text,
                          icon: Icons.email_outlined,
                        ),

                        const SizedBox(height: 16),

                        _buildInfoTile(
                          title: 'Endereço',
                          value: _addressController.text,
                          icon: Icons.map_outlined,
                          editable: true,
                          onEdit: () {
                            _editField(
                              title: 'Endereço',
                              field: 'address',
                              controller: _addressController,
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildInfoTile(
                          title: 'Bairro',
                          value: _districtController.text,
                          icon: Icons.location_city,
                          editable: true,
                          onEdit: () {
                            _editField(
                              title: 'Bairro',
                              field: 'neighborhood',
                              controller: _districtController,
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildInfoTile(
                          title: 'Cidade',
                          value: _cityController.text,
                          icon: Icons.location_on_outlined,
                          editable: true,
                          onEdit: () {
                            _editField(
                              title: 'Cidade',
                              field: 'city',
                              controller: _cityController,
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        CustomButton(
                          text: 'Alterar senha',
                          onPressed: _openChangePasswordModal,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
