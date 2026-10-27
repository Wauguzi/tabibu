import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabibu/core/helpers/get_it_helper.config.dart';

final GetIt getIt = GetIt.instance;

/// Where the callables are deployed (CRQ-0016). The default instance calls
/// us-central1, where nothing is.
const functionsRegion = 'europe-west1';

@InjectableInit()
Future<void> configureDI() async {
  await getIt.init();
}

@module
abstract class DIModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @singleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @singleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @singleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @singleton
  FirebaseFunctions get firebaseFunctions =>
      FirebaseFunctions.instanceFor(region: functionsRegion);

  @singleton
  FirebaseStorage get firebaseStorage => FirebaseStorage.instance;

  @singleton
  FirebaseAnalytics get firebaseAnalytics => FirebaseAnalytics.instance;
}
