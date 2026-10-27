import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/constants/theme_builder.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/routing/app_router.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/services/app_update_service.dart';
import 'package:tabibu/core/utils/text_scale.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/themes/blocs/theme_bloc/theme_bloc.dart';
import 'package:tabibu/features/themes/blocs/theme_bloc/theme_state.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Localization delegates for the app.
///
/// Deliberately not [AppLocalizations.localizationsDelegates]: the generated
/// list wires up flutter_localizations' GlobalMaterialLocalizations, which
/// satisfies the framework's MaterialLocalizations type, not material_ui's
/// own forked type. English hides the mismatch; every other locale throws on
/// the first TextField, AppBar or dialog. Guarded by
/// test/app/localizations_delegates_test.dart.
const tabibuLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  // material_ui's own — NOT flutter_localizations'.
  GlobalMaterialLocalizations.delegate,
  // cupertino_ui's own — NOT flutter_localizations'.
  GlobalCupertinoLocalizations.delegate,
  // WidgetsLocalizations is NOT forked; the framework delegate is correct.
  GlobalWidgetsLocalizations.delegate,
];

/// The blocs come from `bootstrap` (`BlocsHelper`), above this widget, so
/// the router can be built from the [AuthBloc] they provide.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  static final ThemeData _light = buildTheme(Brightness.light);
  static final ThemeData _dark = buildTheme(Brightness.dark);

  late final GoRouter _router = TabibuRouter.create(context.read<AuthBloc>());

  /// Null until the saved choice is read, so the device's language applies.
  Locale? _locale;

  /// Only a real return from the background re-runs the checks; the
  /// `inactive → resumed` of a cold start is the decision route's (§9).
  bool _hasBeenBackgrounded = false;
  bool _isShowingUpdate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_loadSavedLocale());
  }

  Future<void> _loadSavedLocale() async {
    final saved =
        (await getIt<HiveHelper>().getCachedOnboarding())?.languageString;
    if (!mounted || saved == null || saved.isEmpty) return;
    setState(() => _locale = Locale(AppLanguage.fromValue(saved).value));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _hasBeenBackgrounded = true;
    if (state == AppLifecycleState.resumed && _hasBeenBackgrounded) {
      unawaited(_onResume());
    }
  }

  /// A release published while the app slept is enforced without a
  /// relaunch, and a role granted meanwhile (a verification) is picked up.
  Future<void> _onResume() async {
    final auth = context.read<AuthBloc>();
    if (auth.state.session is! SignedOutSession) {
      auth.add(const SessionRequested());
    }
    if (_isShowingUpdate) return;
    final updates = getIt<AppUpdateService>();
    await updates.refresh();
    if (!await updates.isUpdateRequired() || !mounted) return;
    _isShowingUpdate = true;
    _router.go(const UpdateRoute().location);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state) {
          case LanguageChangeSuccess(:final language):
            setState(() => _locale = Locale(language.value));
          // Photos and license scans leave memory once no longer needed.
          case SignUpSuccess() || SignOutSuccess():
            context.read<SignUpBloc>().add(const SignUpDraftCleared());
          default:
        }
      },
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, theme) => MaterialApp.router(
          routerConfig: _router,
          theme: _light,
          darkTheme: _dark,
          themeMode: switch (theme.preference) {
            ThemePreference.light => ThemeMode.light,
            ThemePreference.dark => ThemeMode.dark,
            ThemePreference.system => ThemeMode.system,
          },
          locale: _locale,
          localizationsDelegates: tabibuLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: composedTextScaler(
                  base: mediaQuery.textScaler,
                  extraScaleFactor: screenAwareTextScaleFactor(context),
                ),
              ),
              child: child!,
            );
          },
        ),
      ),
    );
  }
}
