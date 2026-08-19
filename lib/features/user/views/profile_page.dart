import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_user_avatar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/responsive_form_content.dart';
import '../../auth/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || Navigator.canPop(context)) return;
      Navigator.pushReplacementNamed(context, AppRoutes.stationList);
    });
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await _authService.getCurrentUserData();

      if (!mounted) return;

      if (data != null) {
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Não foi possível carregar o perfil.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editInfo({
    required String title,
    required TextEditingController controller,
    required Future<void> Function(String value) onSave,
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
                  await onSave(tempController.text.trim());

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
                      await _authService.updatePassword(
                        oldPassword: oldPasswordController.text,
                        newPassword: newPasswordController.text,
                      );

                      if (!mounted) {
                        return;
                      }

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

          if (onEdit != null)
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
          'Meu Perfil',
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

      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveFormContent(
            maxWidth: 520,
            child: Container(
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: AppTheme.card,

                borderRadius: BorderRadius.circular(20),

                border: Border.all(color: AppTheme.outline),
              ),

              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryInteractive,
                      ),
                    )
                  : Column(
                      children: [
                        AppUserAvatar(
                          displayName: _nameController.text,
                          size: 72,
                          onTap: () => _editInfo(
                            title: 'Nome',
                            controller: _nameController,
                            onSave: _authService.updateName,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          _nameController.text.isEmpty
                              ? 'Meu perfil'
                              : _nameController.text,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),

                        const SizedBox(height: 24),

                        _buildInfoTile(
                          title: 'Nome',
                          value: _nameController.text,
                          icon: Icons.person_outline,
                          onEdit: () {
                            _editInfo(
                              title: 'Nome',

                              controller: _nameController,

                              onSave: _authService.updateName,
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildInfoTile(
                          title: 'E-mail',
                          value: _emailController.text,
                          icon: Icons.email_outlined,
                        ),

                        const SizedBox(height: 16),

                        _buildInfoTile(
                          title: 'Celular',
                          value: _phoneController.text,
                          icon: Icons.phone_outlined,
                          onEdit: () {
                            _editInfo(
                              title: 'Celular',

                              controller: _phoneController,

                              onSave: _authService.updatePhone,
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
