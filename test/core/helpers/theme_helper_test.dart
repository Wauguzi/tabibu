import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/theme_helper.dart';

void main() {
  test('something unknown starts in light', () async {
    SharedPreferences.setMockInitialValues({'themePreference': 'sepia'});
    final helper = ThemeHelper(
      preferences: await SharedPreferences.getInstance(),
    );
    expect(helper.read(), ThemePreference.light);
  });

  test('nothing saved starts in light', () async {
    SharedPreferences.setMockInitialValues({});
    final helper = ThemeHelper(
      preferences: await SharedPreferences.getInstance(),
    );
    expect(helper.read(), ThemePreference.light);
  });

  test('a saved system choice still follows the device', () async {
    SharedPreferences.setMockInitialValues({'themePreference': 'system'});
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
