import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/constants/theme_builder.dart';
import 'package:tabibu/core/helpers/blocs_helper.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/core/routing/app_router.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/services/app_update_service.dart';
import 'package:tabibu/core/services/notification_service.dart';
import 'package:tabibu/core/utils/text_scale.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_bloc.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_event.dart';
import 'package:tabibu/features/lock/presentation/unlock_overlay.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_bloc.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_event.dart';
import 'package:tabibu/features/notifications/data/cache/notification_cache_helper.dart';
import 'package:tabibu/features/notifications/data/models/notification_model.dart';
import 'package:tabibu/features/notifications/presentation/inbox_watch.dart';
import 'package:tabibu/features/notifications/presentation/notification_target.dart';
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
  static final ThemeData _light = buildTheme(.light);
  static final ThemeData _dark = buildTheme(.dark);

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
    // Cover first, then read: no content before the lock answer (rule 2).
    context.read<LockBloc>().add(const LockColdStart());
  }

  Future<void> _loadSavedLocale() async {
    final saved =
        (await getIt<HiveHelper>().getCachedOnboarding())?.languageString;
    if (!mounted || saved == null || saved.isEmpty) return;
    setState(() => _locale = Locale(AppLanguage.fromValue(saved).value));
  }

  /// The uid whose inbox is being watched live, or null.
  String? _watchedUid;

  /// Banner and push taps; cancelled on sign-out and dispose (lesson 5).
  StreamSubscription<String>? _tapSub;

  /// A tap that arrived before a role session could open a route.
  String? _heldTap;

  /// Cold-start [NotificationService.launchPayload] is read once per session.
  bool _launchTapConsumed = false;

  /// Keeps the live inbox on while someone with a role is signed in and the
  /// app is in front, so a booking request reaches a doctor as it arrives.
  void _syncInboxWatch(AuthSession session, {bool foreground = true}) {
    final uid = inboxWatchUid(session, foreground: foreground);
    if (uid == _watchedUid) return;
    _watchedUid = uid;
    context.read<NotificationsBloc>().add(
      uid == null
          ? const NotificationsWatchStopped()
          : NotificationsWatchStarted(uid: uid),
    );
  }

  /// Same lifecycle as the inbox watch: listen once a role is known; cancel
  /// when signed out. A held or cold-start tap is replayed once.
  void _syncTapWatch(AuthSession session) {
    final ready = _tapSession(session);
    if (ready == null) {
      unawaited(_tapSub?.cancel());
      _tapSub = null;
      _heldTap = null;
      _launchTapConsumed = false;
      return;
    }
    _tapSub ??= getIt<NotificationService>().taps.listen(_onNotificationTap);
    unawaited(_replayHeldTaps(ready));
  }

  ({String uid, RoleHelper roles})? _tapSession(AuthSession session) =>
      switch (session) {
        PatientSession(:final patient, :final roles) => (
          uid: patient.uid,
          roles: roles,
        ),
        PractitionerSession(:final doctor, :final roles) when roles.hasRole => (
          uid: doctor.uid,
          roles: roles,
        ),
        _ => null,
      };

  void _onNotificationTap(String payload) {
    if (payload.isEmpty) return;
    final ready = _tapSession(context.read<AuthBloc>().state.session);
    if (ready == null) {
      _heldTap = payload;
      return;
    }
    unawaited(_openNotificationTap(payload, ready.uid, ready.roles));
  }

  Future<void> _replayHeldTaps(({String uid, RoleHelper roles}) ready) async {
    final held = _heldTap;
    _heldTap = null;
    if (held != null && held.isNotEmpty) {
      await _openNotificationTap(held, ready.uid, ready.roles);
    }
    if (_launchTapConsumed) return;
    _launchTapConsumed = true;
    final launch = await getIt<NotificationService>().launchPayload();
    if (launch == null || launch.isEmpty || !mounted) return;
    // Already handled as a live tap that was held.
    if (launch == held) return;
    await _openNotificationTap(launch, ready.uid, ready.roles);
  }

  Future<void> _openNotificationTap(
    String payload,
    String uid,
    RoleHelper roles,
  ) async {
    var deepLink = '';
    if (isNotificationDeepLinkPayload(payload)) {
      deepLink = payload;
    } else {
      final row = await _cachedNotification(uid, payload);
      if (row != null) {
        if (!mounted) return;
        context.read<NotificationsBloc>().add(
          NotificationReadRequested(uid: uid, notificationUid: payload),
        );
        deepLink = row.metadata.deepLink;
      }
    }
    if (!mounted) return;
    final target = notificationTapRoute(deepLink, roles);
    if (target == null) return;
    final nav = _router.routerDelegate.navigatorKey.currentContext;
    if (nav == null || !nav.mounted) return;
    unawaited(target.push<void>(nav));
  }

  Future<NotificationModel?> _cachedNotification(
    String uid,
    String notificationUid,
  ) async {
    try {
      final rows = await getIt<NotificationCacheHelper>().getInbox(uid);
      for (final row in rows) {
        if (row.uid == notificationUid) return row;
      }
    } on Object {
      // Cache missing or unread: the tap still opens the inbox.
    }
    return null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final session = context.read<AuthBloc>().state.session;
    if (state == .paused) {
      _hasBeenBackgrounded = true;
      _syncInboxWatch(session, foreground: false);
      context.read<LockBloc>().add(const LockAppBackgrounded());
    }
    if (state == .resumed && _hasBeenBackgrounded) {
      _syncInboxWatch(session);
      context.read<LockBloc>().add(const LockAppResumed());
      unawaited(_onResume());
    }
  }

  /// A release published while the app slept is enforced without a
  /// relaunch, and a role granted meanwhile (a verification) is picked up.
  Future<void> _onResume() async {
    final auth = context.read<AuthBloc>();
    if (auth.state.session is! SignedOutSession &&
        auth.state is! SignOutInProgress) {
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
    unawaited(_tapSub?.cancel());
    _tapSub = null;
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        _syncInboxWatch(state.session);
        _syncTapWatch(state.session);
        switch (state) {
          case LanguageChangeSuccess(:final language):
            setState(() => _locale = Locale(language.value));
          // Photos and license scans leave memory once no longer needed.
          case SignUpSuccess():
            context.read<SignUpBloc>().add(const SignUpDraftCleared());
          case SignOutSuccess():
            context.read<SignUpBloc>().add(const SignUpDraftCleared());
            // PIN hash leaves the device with the session (rule 5).
            context.read<LockBloc>().add(const LockStorageCleared());
            BlocsHelper.resetFeatureBlocs(context);
          default:
        }
      },
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, theme) => MaterialApp.router(
          routerConfig: _router,
          theme: _light,
          darkTheme: _dark,
          themeMode: switch (theme.preference) {
            .light => .light,
            .dark => .dark,
            .system => .system,
          },
          // A switch is one frame, so it cannot tween under a page transition.
          themeAnimationDuration: Duration.zero,
          locale: _locale,
          localizationsDelegates: tabibuLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            final isDark = Theme.of(context).brightness == Brightness.dark;
            // The default for screens that set no style of their own.
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: AppColors.transparent,
                statusBarBrightness: isDark ? .dark : .light,
                statusBarIconBrightness: isDark ? .light : .dark,
              ),
              child: MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: composedTextScaler(
                    base: mediaQuery.textScaler,
                    extraScaleFactor: screenAwareTextScaleFactor(context),
                  ),
                ),
                child: UnlockOverlay(child: child!),
              ),
            );
          },
        ),
      ),
    );
  }
}
