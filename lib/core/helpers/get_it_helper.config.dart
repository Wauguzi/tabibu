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
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:tabibu/core/helpers/auth_helper.dart' as _i569;
import 'package:tabibu/core/helpers/db_helper.dart' as _i705;
import 'package:tabibu/core/helpers/facilities_helper.dart' as _i598;
import 'package:tabibu/core/helpers/get_it_helper.dart' as _i810;
import 'package:tabibu/core/helpers/hive_helper.dart' as _i418;
import 'package:tabibu/core/helpers/notifications_helper.dart' as _i210;
import 'package:tabibu/core/helpers/theme_helper.dart' as _i655;
import 'package:tabibu/core/services/analytics_service.dart' as _i399;
import 'package:tabibu/core/services/app_update_service.dart' as _i75;
import 'package:tabibu/core/services/file_picker_service.dart' as _i282;
import 'package:tabibu/core/services/internet_service.dart' as _i76;
import 'package:tabibu/core/services/notification_service.dart' as _i1051;
import 'package:tabibu/core/services/rasp_service.dart' as _i390;
import 'package:tabibu/features/auth/data/datasources/auth_firebase.dart'
    as _i82;
import 'package:tabibu/features/auth/data/datasources/profile_storage.dart'
    as _i275;

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
    gh.singleton<_i1051.NotificationService>(
      () => dIModule.notificationService,
    );
    gh.singleton<_i390.RaspService>(() => dIModule.raspService);
    gh.lazySingleton<_i598.FacilitiesHelper>(() => _i598.FacilitiesHelper());
    gh.lazySingleton<_i75.AppUpdateService>(() => _i75.AppUpdateService());
    gh.lazySingleton<_i282.FilePickerService>(() => _i282.FilePickerService());
    gh.lazySingleton<_i76.InternetService>(() => _i76.InternetService());
    gh.lazySingleton<_i399.AnalyticsService>(
      () => _i399.AnalyticsService(analytics: gh<_i398.FirebaseAnalytics>()),
    );
    gh.singleton<_i705.DBHelper>(() => _i705.DBHelperImpl());
    gh.lazySingleton<_i655.ThemeHelper>(
      () => _i655.ThemeHelper(preferences: gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i82.AuthFirebase>(
      () => _i82.AuthFirebase(
        auth: gh<_i59.FirebaseAuth>(),
        firestore: gh<_i974.FirebaseFirestore>(),
        functions: gh<_i809.FirebaseFunctions>(),
      ),
    );
    gh.singleton<_i418.HiveHelper>(
      () => _i418.HiveHelperImpl(
        dbHelper: gh<_i705.DBHelper>(),
        secureStorage: gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i275.ProfileStorage>(
      () => _i275.ProfileStorage(storage: gh<_i457.FirebaseStorage>()),
    );
    gh.lazySingleton<_i210.NotificationsHelper>(
      () => _i210.NotificationsHelper(
        notificationService: gh<_i1051.NotificationService>(),
        hiveHelper: gh<_i418.HiveHelper>(),
      ),
    );
    gh.lazySingleton<_i569.AuthHelper>(
      () => _i569.AuthHelper(
        authFirebase: gh<_i82.AuthFirebase>(),
        hiveHelper: gh<_i418.HiveHelper>(),
        profileStorage: gh<_i275.ProfileStorage>(),
        notificationService: gh<_i1051.NotificationService>(),
      ),
    );
    return this;
  }
}

class _$DIModule extends _i810.DIModule {}
