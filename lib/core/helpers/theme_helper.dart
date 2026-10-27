import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';

/// The theme choice, in preferences rather than Hive: it is read
/// synchronously for `ThemeBloc`'s first state, so the first frame is
/// already in the right theme, and it survives sign-out.
@lazySingleton
class ThemeHelper {
  ThemeHelper({SharedPreferences? preferences})
    : _prefs = preferences ?? getIt<SharedPreferences>();

  final SharedPreferences _prefs;

  static const _key = 'themePreference';

  ThemePreference read() => ThemePreference.fromValue(_prefs.getString(_key));

  Future<void> write(ThemePreference preference) =>
      _prefs.setString(_key, preference.value);
}
