// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:cloud_functions/cloud_functions.dart' as _i809;
import 'package:firebase_analytics/firebase_analytics.dart' as _i398;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:flutter/services.dart' as _i281;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:tabibu/core/helpers/facilities_helper.dart' as _i598;
import 'package:tabibu/core/helpers/get_it_helper.dart' as _i810;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dIModule = _$DIModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => dIModule.prefs,
      preResolve: true,
    );
    gh.singleton<_i558.FlutterSecureStorage>(() => dIModule.secureStorage);
    gh.singleton<_i59.FirebaseAuth>(() => dIModule.firebaseAuth);
    gh.singleton<_i974.FirebaseFirestore>(() => dIModule.firestore);
    gh.singleton<_i809.FirebaseFunctions>(() => dIModule.firebaseFunctions);
    gh.singleton<_i457.FirebaseStorage>(() => dIModule.firebaseStorage);
    gh.singleton<_i398.FirebaseAnalytics>(() => dIModule.firebaseAnalytics);
    gh.lazySingleton<_i598.FacilitiesHelper>(
      () => _i598.FacilitiesHelper(bundle: gh<_i281.AssetBundle>()),
    );
    return this;
  }
}

class _$DIModule extends _i810.DIModule {}
