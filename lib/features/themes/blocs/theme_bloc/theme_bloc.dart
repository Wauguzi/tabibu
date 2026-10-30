import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/theme_helper.dart';
import 'package:tabibu/features/themes/blocs/theme_bloc/theme_event.dart';
import 'package:tabibu/features/themes/blocs/theme_bloc/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc({ThemeHelper? themeHelper})
    : _helper = themeHelper ?? getIt<ThemeHelper>(),
      super(
        ThemeState(preference: (themeHelper ?? getIt<ThemeHelper>()).read()),
      ) {
    // Rapid taps through the choices: only the last one matters.
    on<ThemeChangeRequested>(
      _onThemeChangeRequested,
      transformer: restartable(),
    );
  }

  final ThemeHelper _helper;

  /// Applied before it is saved, so the switch is instant; a failed save
  /// only means the next launch starts in the old theme.
  Future<void> _onThemeChangeRequested(
    ThemeChangeRequested event,
    Emitter<ThemeState> emit,
  ) async {
    emit(ThemeState(preference: event.preference));
    try {
      await _helper.write(event.preference);
    } on Object catch (_) {}
  }
}
