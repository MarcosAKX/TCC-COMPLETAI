import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/settings_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _goToProfile(BuildContext context) async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    final stationDoc = await FirebaseFirestore.instance
        .collection('gas_stations')
        .doc(uid)
        .get();

    if (!context.mounted) return;

    if (stationDoc.exists && stationDoc.data()?['type'] == 'gas_station') {
      Navigator.pushReplacementNamed(context, AppRoutes.stationProfile);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.stationList);
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.card,
          title: const Text(
            'Excluir conta',
            style: TextStyle(color: AppTheme.textLight),
          ),
          content: const Text(
            'Tem certeza que deseja excluir sua conta? Essa ação não poderá ser desfeita.',
            style: TextStyle(color: AppTheme.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Excluir',
                style: TextStyle(color: AppTheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;
    if (confirm != true) return;

    final usesPassword = user.providerData.any(
      (provider) => provider.providerId == EmailAuthProvider.PROVIDER_ID,
    );

    String? password;
    if (usesPassword) {
      password = await _requestPassword(context);
      if (!context.mounted) return;
      if (password == null) return;
    }

    try {
      final uid = user.uid;
      final firestore = FirebaseFirestore.instance;

      if (usesPassword && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password!,
        );
        await user.reauthenticateWithCredential(credential);
      }

      final userReference = firestore.collection('users').doc(uid);
      final stationReference = firestore.collection('gas_stations').doc(uid);
      final publicStationReference = firestore
          .collection('public_stations')
          .doc(uid);
      final documents = await Future.wait([
        userReference.get(),
        stationReference.get(),
        publicStationReference.get(),
      ]);

      final userData = documents[0].data();
      final stationData = documents[1].data();
      final publicStationData = documents[2].data();
      final deleteBatch = firestore.batch()
        ..delete(userReference)
        ..delete(stationReference)
        ..delete(publicStationReference);

      await deleteBatch.commit();

      try {
        await user.delete();
      } catch (_) {
        // Se a etapa do Auth falhar, tenta restaurar os perfis removidos para
        // não deixar uma conta válida sem os seus dados.
        final restoreBatch = firestore.batch();
        if (userData != null) {
          restoreBatch.set(userReference, {
            ...userData,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        if (stationData != null) {
          restoreBatch.set(stationReference, {
            ...stationData,
            'fuelPrices': stationData['fuelPrices'] ?? <String, double>{},
            'tags': stationData['tags'] ?? <String>[],
            'services': stationData['services'] ?? <String>[],
            'openingHours':
                stationData['openingHours'] ?? <String, Map<String, dynamic>>{},
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        if (publicStationData != null) {
          restoreBatch.set(publicStationReference, {
            ...publicStationData,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        await restoreBatch.commit();
        rethrow;
      }

      if (!context.mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_deleteErrorMessage(error))));
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível excluir a conta. Tente novamente.'),
        ),
      );
    }
  }

  Future<String?> _requestPassword(BuildContext context) async {
    final controller = TextEditingController();

    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text(
          'Confirme sua senha',
          style: TextStyle(color: AppTheme.textLight),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          style: const TextStyle(color: AppTheme.textLight),
          decoration: const InputDecoration(labelText: 'Senha atual'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text;
              if (value.isNotEmpty) {
                Navigator.pop(dialogContext, value);
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    controller.dispose();
    return password;
  }

  String _deleteErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Senha atual incorreta.';
      case 'requires-recent-login':
        return 'Faça login novamente antes de excluir sua conta.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      default:
        return 'Não foi possível excluir a conta.';
    }
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = AppTheme.primaryInteractive,
    Color textColor = AppTheme.textLight,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: SettingsTile(
          icon: icon,
          title: title,
          destructive:
              iconColor == AppTheme.error || textColor == AppTheme.error,
          onTap: onTap,
        ),
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
          'Configurações',
          style: TextStyle(
            color: AppTheme.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Minha conta',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildOptionTile(
                icon: Icons.person_outline,
                title: 'Editar perfil',
                onTap: () {
                  _goToProfile(context);
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Sessão',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildOptionTile(
                icon: Icons.logout,
                title: 'Sair da conta',
                iconColor: AppTheme.error,
                textColor: AppTheme.error,
                onTap: () {
                  _logout(context);
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Zona de perigo',
                style: TextStyle(
                  color: AppTheme.error,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildOptionTile(
                icon: Icons.delete_outline,
                title: 'Excluir conta',
                iconColor: AppTheme.error,
                textColor: AppTheme.error,
                onTap: () {
                  _deleteAccount(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
