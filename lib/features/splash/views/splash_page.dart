import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/urban_route_signature.dart';

class SplashPage extends StatefulWidget {
  final Duration duration;
  final String loginRoute;

  const SplashPage({
    super.key,
    this.duration = const Duration(milliseconds: 1900),
    this.loginRoute = '/login',
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _routeController;
  Timer? _navigationTimer;
  bool _animationStarted = false;

  @override
  void initState() {
    super.initState();
    _routeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _navigationTimer = Timer(widget.duration, _openLogin);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_animationStarted) return;
    _animationStarted = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _routeController.value = 1;
    } else {
      _routeController.forward();
    }
  }

  void _openLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(widget.loginRoute);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _routeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Completai!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 46,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Seu caminho para abastecer melhor.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.onPrimaryMuted,
                    ),
                  ),
                  const SizedBox(height: 34),
                  AnimatedBuilder(
                    animation: _routeController,
                    builder: (context, _) =>
                        UrbanRouteSignature(progress: _routeController.value),
                  ),
                  const SizedBox(height: 38),
                  const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
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
