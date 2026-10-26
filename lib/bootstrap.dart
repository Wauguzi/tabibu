// ignore_for_file: document_ignores, avoid_catches_without_on_clauses

import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:tabibu/firebase_options.dart';

class AppBlocObserver extends BlocObserver {
  const new();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

/// Every network/platform-channel call awaited ahead of `runApp()` in
/// [bootstrap] is bounded by this. Nothing before `runApp()` has a Flutter
/// frame, an error zone, or a Crashlytics hook yet — a hang there is
/// invisible to every tool this app normally relies on to catch bugs, and
/// leaves the user stuck on the native splash screen forever.
const _bootstrapStepTimeout = Duration(seconds: 10);

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // Initialize Firebase first — Crashlytics.instance must not be accessed
  // until Firebase.initializeApp() has completed.
  //
  // Use bare catch (not `on Exception`) because some Firebase failures throw
  // Error subclasses (e.g. StateError, TypeError) which don't extend Exception.
  // debugPrint is used instead of log() because dart:developer log() is
  // suppressed by the Dart VM in release mode; debugPrint writes to stdout/
  // logcat and remains visible for post-release diagnostics.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(_bootstrapStepTimeout);
  } catch (e, s) {
    if (kDebugMode) {
      debugPrint('[Bootstrap] Firebase initialization failed: $e\n$s');
    }
  }

  runApp(await builder());
}
