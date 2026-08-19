import 'package:shared_preferences/shared_preferences.dart';

class DiscoveryTipPreference {
  static const _dismissedKey = 'fuel_discovery_tip_dismissed';

  Future<bool> shouldShow() async {
    final preferences = await SharedPreferences.getInstance();
    return !(preferences.getBool(_dismissedKey) ?? false);
  }

  Future<void> dismiss() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_dismissedKey, true);
  }
}
