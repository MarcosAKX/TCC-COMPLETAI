import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/adaptive_action_row.dart';
import '../../../core/widgets/app_user_avatar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/responsive_content.dart';
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
      if (mounted) _showMessage('Não foi possível carregar o perfil.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                      await onSave(tempController.text.trim());
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
      builder: (_) => ProfilePasswordSheet(
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
            await _authService.updatePassword(
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
          'Meu Perfil',
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
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryInteractive,
              ),
            )
          : ProfileContent(
              name: _nameController.text,
              email: _emailController.text,
              phone: _phoneController.text,
              onEditName: () => _editInfo(
                title: 'Nome',
                controller: _nameController,
                onSave: _authService.updateName,
              ),
              onEditPhone: () => _editInfo(
                title: 'Celular',
                controller: _phoneController,
                onSave: _authService.updatePhone,
              ),
              onChangePassword: _openChangePasswordModal,
            ),
    );
  }
}

class ProfileContent extends StatelessWidget {
  const ProfileContent({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.onEditName,
    required this.onEditPhone,
    required this.onChangePassword,
  });

  final String name;
  final String email;
  final String phone;
  final VoidCallback onEditName;
  final VoidCallback onEditPhone;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) {
    return ResponsiveContent(
      maxWidth: 520,
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
            AppUserAvatar(displayName: name, size: 72, onTap: onEditName),
            const SizedBox(height: 16),
            Text(
              name.isEmpty ? 'Meu perfil' : name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            _ProfileInfoTile(
              title: 'Nome',
              value: name,
              icon: Icons.person_outline,
              onEdit: onEditName,
            ),
            const SizedBox(height: 16),
            _ProfileInfoTile(
              title: 'E-mail',
              value: email,
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            _ProfileInfoTile(
              title: 'Celular',
              value: phone,
              icon: Icons.phone_outlined,
              onEdit: onEditPhone,
            ),
            const SizedBox(height: 24),
            AdaptiveActionRow(
              children: [
                CustomButton(
                  key: const Key('profile-change-password-action'),
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

class ProfilePasswordSheet extends StatelessWidget {
  const ProfilePasswordSheet({
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
          key: const Key('profile-password-sheet'),
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
                  CustomButton(
                    key: const Key('profile-password-save-action'),
                    text: 'Salvar nova senha',
                    onPressed: onSave,
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

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
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
