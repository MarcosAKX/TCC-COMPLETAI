import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/step_progress_header.dart';
import '../../../../core/widgets/responsive_form_content.dart';

class RegisterTypePage extends StatelessWidget {
  const RegisterTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveFormContent(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Top bar ──────────────────────────────────────────────
                SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        color: AppTheme.textLight,
                        padding: EdgeInsets.zero,
                      ),
                      const Expanded(
                        child: StepProgressHeader(
                          currentStep: 1,
                          totalSteps: 2,
                        ),
                      ),
                      // Balancing widget so title is truly centered
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // ── Headline ─────────────────────────────────────────────
                const Text(
                  'Bem-vindo(a)!',
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Como você deseja utilizar nossa\nplataforma hoje?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 15,
                    height: 1.55,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 36),

                // ── Cards ─────────────────────────────────────────────────
                _RegisterTypeCard(
                  icon: Icons.directions_car_outlined,
                  title: 'Motorista',
                  description:
                      'Compare preços, horários e avaliações dos postos de Bebedouro.',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.registerUser),
                ),

                const SizedBox(height: 14),

                _RegisterTypeCard(
                  icon: Icons.local_gas_station_outlined,
                  title: 'Posto de\nCombustível',
                  description:
                      'Mantenha preços, horários e serviços do seu posto atualizados.',
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.registerStationStepOne,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Footer ────────────────────────────────────────────────
                const Text(
                  'Já possui uma conta?',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 8),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fazer login'),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _RegisterTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _RegisterTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        splashColor: AppTheme.primary.withValues(alpha: 0.08),
        highlightColor: AppTheme.primary.withValues(alpha: 0.04),
        child: Ink(
          decoration: BoxDecoration(
            // Slightly lighter than background to create the card effect
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Icon container ──────────────────────────────────
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppTheme.primary, size: 26),
                ),

                const SizedBox(width: 18),

                // ── Text block ──────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        description,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13.5,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
