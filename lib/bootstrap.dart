// ignore_for_file: document_ignores, avoid_catches_without_on_clauses

import 'dart:async';
import 'dart:developer';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabibu/core/helpers/blocs_helper.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/google_sign_in_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/services/notification_service.dart';
import 'package:tabibu/core/services/rasp_service.dart';
import 'package:tabibu/firebase_options.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    if (kReleaseMode) {
      try {
        unawaited(
          FirebaseCrashlytics.instance.recordError(
            error,
            stackTrace,
            reason: 'BlocObserver: ${bloc.runtimeType}',
          ),
        );
      } catch (_) {}
    }
    super.onError(bloc, error, stackTrace);
  }
}

/// An `EventChannel` cancel that reached an already-disposed native handler.
/// Recorded as non-fatal; a failure to activate a stream stays fatal.
bool _isPlatformStreamTeardownError(FlutterErrorDetails details) {
  if (details.exception is! MissingPluginException) return false;
  final context = details.context?.toString() ?? '';
  return context.contains('de-activating platform stream');
}

/// Every network/platform-channel call awaited ahead of `runApp()` in
/// [bootstrap] is bounded by this. Nothing before `runApp()` has a Flutter
/// frame, an error zone, or a Crashlytics hook yet — a hang there is
/// invisible to every tool this app normally relies on to catch bugs, and
/// leaves the user stuck on the native splash screen forever.
const _bootstrapStepTimeout = Duration(seconds: 10);

/// Set only by `make run-dev`, from the Keychain; never in a release build.
const _appCheckDebugToken = String.fromEnvironment('APP_CHECK_DEBUG_TOKEN');

/// [isProd] turns on freeRASP's enforcement. It follows the build mode, not
/// the flavor: a debug build of any flavor is signed with the debug key, so
/// enforcing certificates there would terminate it.
Future<void> bootstrap(
  FutureOr<Widget> Function() builder, {
  bool isProd = kReleaseMode,
}) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // Bare catch: some Firebase failures throw Errors, not Exceptions.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(_bootstrapStepTimeout);
  } catch (e, s) {
    if (kDebugMode) {
      debugPrint('[Bootstrap] Firebase initialization failed: $e\n$s');
    }
  }

  final debugToken = _appCheckDebugToken.isEmpty ? null : _appCheckDebugToken;
  try {
    await FirebaseAppCheck.instance
        .activate(
          providerAndroid: kReleaseMode
              ? const AndroidPlayIntegrityProvider()
              : AndroidDebugProvider(debugToken: debugToken),
          providerApple: kReleaseMode
              ? const AppleAppAttestProvider()
              : AppleDebugProvider(debugToken: debugToken),
        )
        .timeout(_bootstrapStepTimeout);
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[Bootstrap] App Check activation failed: $e');
    }
  }

  try {
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(kReleaseMode)
        .timeout(_bootstrapStepTimeout);
  } catch (_) {}

  // Crashlytics is reached only inside the handlers, so a failed
  // Firebase.initializeApp() cannot crash the app here.
  FlutterError.onError = (details) {
    if (kReleaseMode) {
      try {
        unawaited(
          _isPlatformStreamTeardownError(details)
              ? FirebaseCrashlytics.instance.recordFlutterError(details)
              : FirebaseCrashlytics.instance.recordFlutterFatalError(details),
        );
      } catch (_) {}
    } else {
      log(details.exceptionAsString(), stackTrace: details.stack);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kReleaseMode) {
      try {
        unawaited(
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
        );
      } catch (_) {}
    } else {
      log('Unhandled platform error: $error', stackTrace: stack);
    }
    return true;
  };

  // Defaults let the app through when nothing has been fetched yet.
  try {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: _bootstrapStepTimeout,
        minimumFetchInterval: kReleaseMode
            ? const Duration(hours: 12)
            : Duration.zero,
      ),
    );
    await remoteConfig.setDefaults(const {
      'force_update': false,
      'min_required_version': '',
      'store_url_android': '',
      'store_url_ios': '',
      'update_title': '',
      'update_message': '',
    });
    await remoteConfig.fetchAndActivate().timeout(_bootstrapStepTimeout);
    if (kDebugMode) {
      debugPrint(
        '[Bootstrap] Remote Config: min_required_version='
        '${remoteConfig.getString('min_required_version')}, '
        'force_update=${remoteConfig.getBool('force_update')}',
      );
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[Bootstrap] Remote Config failed, using defaults: $e');
    }
  }

  // The cache and the auth layer resolve through DI, so it comes first.
  try {
    await configureDI().timeout(_bootstrapStepTimeout);
  } catch (e) {
    if (kDebugMode) debugPrint('[Bootstrap] DI failed: $e');
  }

  try {
    await GoogleSignInHelper.initialize().timeout(_bootstrapStepTimeout);
  } catch (e) {
    if (kDebugMode) debugPrint('[Bootstrap] Google sign-in init failed: $e');
  }

  // Bounded because the key lives in secure storage, whose platform channel
  // can deadlock on a corrupted Keystore entry (§15 rule 2).
  try {
    await getIt<HiveHelper>().initBoxes().timeout(_bootstrapStepTimeout);
  } catch (e) {
    if (kDebugMode) debugPrint('[Bootstrap] Cache init failed: $e');
  }

  // Raises the OS permission dialog before the first frame exists, so it is
  // bounded like every other step.
  try {
    await getIt<NotificationService>().initialize().timeout(
      _bootstrapStepTimeout,
    );
  } catch (e) {
    if (kDebugMode) debugPrint('[Bootstrap] Notifications init failed: $e');
  }

  // After notifications, so a detection at startup can be shown. Screen
  // capture is blocked inside initialize().
  try {
    await getIt<RaspService>()
        .initialize(isProd: isProd)
        .timeout(_bootstrapStepTimeout);
  } catch (e) {
    if (kDebugMode) debugPrint('[Bootstrap] RASP init failed: $e');
  }

  runApp(
    MultiBlocProvider(
      providers: BlocsHelper.initializeBlocs(),
      child: await builder(),
    ),
  );
}
