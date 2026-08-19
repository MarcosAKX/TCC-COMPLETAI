import 'package:completai_app/features/user/services/discovery_tip_preference.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('dispensa da dica permanece salva', () async {
    SharedPreferences.setMockInitialValues({});
    final preference = DiscoveryTipPreference();

    expect(await preference.shouldShow(), isTrue);

    await preference.dismiss();

    expect(await preference.shouldShow(), isFalse);
  });
}
