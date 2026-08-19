import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'app_routes.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove a faixa de debug
      debugShowCheckedModeBanner: false,

      // Nome do aplicativo
      title: 'Completai!',

      // Tema global do app
      theme: AppTheme.lightTheme,

      // Primeira tela aberta
      initialRoute: AppRoutes.splash,

      scrollBehavior: const _AppScrollBehavior(),

      // Rotas disponíveis
      routes: AppRoutes.routes,
    );
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    ...super.dragDevices,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}
