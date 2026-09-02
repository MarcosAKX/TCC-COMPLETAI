import 'package:flutter/material.dart';

import '../features/auth/views/login_page.dart';
import '../features/auth/views/register_type_page.dart';
import '../features/auth/views/register_user_page.dart';
import '../features/auth/views/forgot_password_page.dart';

import '../features/gas_station/views/register_station_step_one_page.dart';
import '../features/gas_station/views/station_dashboard_page.dart';
import '../features/gas_station/views/station_profile_page.dart';
import '../features/gas_station/views/station_presentation_page.dart';

import '../features/user/views/profile_page.dart';
import '../features/user/views/settings_page.dart';
import '../features/user/views/station_list_page.dart';
import '../features/splash/views/splash_page.dart';

class AppRoutes {
  // =========================
  // ROTAS
  // =========================

  static const String splash = '/';

  static const String login = '/login';

  static const String registerType = '/register-type';

  static const String registerUser = '/register-user';

  static const String forgotPassword = '/forgot-password';

  static const String registerStationStepOne = '/register-station-step-one';

  static const String profile = '/profile';

  static const String stationList = '/stations';

  static const String stationProfile = '/station-profile';

  static const String stationDashboard = '/station-dashboard';

  static const String stationPresentation = '/station-presentation';

  static const String settings = '/settings';

  // =========================
  // MAPA DE ROTAS
  // =========================

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashPage(),

    login: (context) => const LoginPage(),

    registerType: (context) => const RegisterTypePage(),

    registerUser: (context) => const RegisterUserPage(),

    forgotPassword: (context) => const ForgotPasswordPage(),

    registerStationStepOne: (context) => const RegisterStationStepOnePage(),

    profile: (context) => const ProfilePage(),

    stationList: (context) => const StationListPage(),

    stationProfile: (context) => const StationProfilePage(),

    stationDashboard: (context) => const StationDashboardPage(),

    stationPresentation: (context) => const StationPresentationPage(),

    settings: (context) => const SettingsPage(),
  };
}
