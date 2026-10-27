import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/theme_helper.dart';

void main() {
  test('nothing saved, or something unknown, follows the device', () async {
    SharedPreferences.setMockInitialValues({'themePreference': 'sepia'});
    final helper = ThemeHelper(
      preferences: await SharedPreferences.getInstance(),
    );
    expect(helper.read(), ThemePreference.system);
  });

  test('a saved choice reads back', () async {
    SharedPreferences.setMockInitialValues({});
    final helper = ThemeHelper(
      preferences: await SharedPreferences.getInstance(),
    );
    await helper.write(ThemePreference.dark);
    expect(helper.read(), ThemePreference.dark);
  });
}
