import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/theme_helper.dart';
import 'package:tabibu/features/themes/blocs/theme_bloc/theme_bloc.dart';
import 'package:tabibu/features/themes/blocs/theme_bloc/theme_event.dart';
import 'package:tabibu/features/themes/blocs/theme_bloc/theme_state.dart';

class _MockThemeHelper extends Mock implements ThemeHelper {}

void main() {
  late _MockThemeHelper helper;

  setUpAll(() => registerFallbackValue(ThemePreference.system));

  setUp(() {
    helper = _MockThemeHelper();
    when(helper.read).thenReturn(ThemePreference.dark);
    when(() => helper.write(any())).thenAnswer((_) async {});
  });

  test('starts in the saved theme, so the first frame is right', () {
    expect(
      ThemeBloc(themeHelper: helper).state,
      const ThemeState(preference: ThemePreference.dark),
    );
  });

  blocTest<ThemeBloc, ThemeState>(
    'applies a choice at once and saves it',
    build: () => ThemeBloc(themeHelper: helper),
    act: (bloc) =>
        bloc.add(const ThemeChangeRequested(preference: ThemePreference.light)),
    expect: () => [const ThemeState(preference: ThemePreference.light)],
    verify: (_) => verify(() => helper.write(ThemePreference.light)).called(1),
  );

  blocTest<ThemeBloc, ThemeState>(
    'a failed save still leaves the theme applied',
    setUp: () => when(() => helper.write(any())).thenThrow(Exception('disk')),
    build: () => ThemeBloc(themeHelper: helper),
    act: (bloc) => bloc.add(
      const ThemeChangeRequested(preference: ThemePreference.system),
    ),
    expect: () => [const ThemeState(preference: ThemePreference.system)],
  );
}
