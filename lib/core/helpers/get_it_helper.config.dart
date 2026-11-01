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
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
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
import 'package:tabibu/core/helpers/reference_data_helper.dart' as _i762;
import 'package:tabibu/core/helpers/theme_helper.dart' as _i655;
import 'package:tabibu/core/services/analytics_service.dart' as _i399;
import 'package:tabibu/core/services/app_update_service.dart' as _i75;
import 'package:tabibu/core/services/file_picker_service.dart' as _i282;
import 'package:tabibu/core/services/internet_service.dart' as _i76;
import 'package:tabibu/core/services/notification_service.dart' as _i1051;
import 'package:tabibu/core/services/rasp_service.dart' as _i390;
import 'package:tabibu/features/alerts/data/cache/alert_cache_helper.dart'
    as _i738;
import 'package:tabibu/features/alerts/data/datasources/alert_firebase.dart'
    as _i113;
import 'package:tabibu/features/alerts/data/datasources/alert_topic_service.dart'
    as _i265;
import 'package:tabibu/features/appointments/data/cache/appointment_cache_helper.dart'
    as _i393;
import 'package:tabibu/features/appointments/data/datasources/appointment_firebase.dart'
    as _i656;
import 'package:tabibu/features/auth/data/datasources/auth_firebase.dart'
    as _i82;
import 'package:tabibu/features/auth/data/datasources/profile_storage.dart'
    as _i275;
import 'package:tabibu/features/cases/data/cache/case_cache_helper.dart'
    as _i614;
import 'package:tabibu/features/cases/data/datasources/case_firebase.dart'
    as _i449;
import 'package:tabibu/features/cases/data/datasources/share_code_firebase.dart'
    as _i374;
import 'package:tabibu/features/conversations/data/cache/conversation_cache_helper.dart'
    as _i679;
import 'package:tabibu/features/conversations/data/datasources/conversation_firebase.dart'
    as _i746;
import 'package:tabibu/features/notifications/data/cache/notification_cache_helper.dart'
    as _i219;
import 'package:tabibu/features/notifications/data/datasources/notification_firebase.dart'
    as _i1063;
import 'package:tabibu/features/reports/data/cache/report_cache_helper.dart'
    as _i726;
import 'package:tabibu/features/reports/data/datasources/report_firebase.dart'
    as _i1004;
import 'package:tabibu/features/worklist/data/cache/worklist_cache_helper.dart'
    as _i407;
import 'package:tabibu/features/worklist/data/datasources/worklist_firebase.dart'
    as _i638;

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
    gh.singleton<_i892.FirebaseMessaging>(() => dIModule.firebaseMessaging);
    gh.singleton<_i398.FirebaseAnalytics>(() => dIModule.firebaseAnalytics);
    gh.singleton<_i1051.NotificationService>(
      () => dIModule.notificationService,
    );
    gh.singleton<_i390.RaspService>(() => dIModule.raspService);
    gh.lazySingleton<_i598.FacilitiesHelper>(() => _i598.FacilitiesHelper());
    gh.lazySingleton<_i762.ReferenceDataHelper>(
      () => _i762.ReferenceDataHelper(),
    );
    gh.lazySingleton<_i75.AppUpdateService>(() => _i75.AppUpdateService());
    gh.lazySingleton<_i282.FilePickerService>(() => _i282.FilePickerService());
    gh.lazySingleton<_i76.InternetService>(() => _i76.InternetService());
    gh.lazySingleton<_i265.AlertTopicService>(
      () => _i265.AlertTopicService(
        messaging: gh<_i892.FirebaseMessaging>(),
        preferences: gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i399.AnalyticsService>(
      () => _i399.AnalyticsService(analytics: gh<_i398.FirebaseAnalytics>()),
    );
    gh.lazySingleton<_i113.AlertFirebase>(
      () => _i113.AlertFirebase(
        firestore: gh<_i974.FirebaseFirestore>(),
        functions: gh<_i809.FirebaseFunctions>(),
      ),
    );
    gh.lazySingleton<_i449.CaseFirebase>(
      () => _i449.CaseFirebase(
        firestore: gh<_i974.FirebaseFirestore>(),
        functions: gh<_i809.FirebaseFunctions>(),
      ),
    );
    gh.lazySingleton<_i374.ShareCodeFirebase>(
      () => _i374.ShareCodeFirebase(
        firestore: gh<_i974.FirebaseFirestore>(),
        functions: gh<_i809.FirebaseFunctions>(),
      ),
    );
    gh.lazySingleton<_i1004.ReportFirebase>(
      () => _i1004.ReportFirebase(
        firestore: gh<_i974.FirebaseFirestore>(),
        functions: gh<_i809.FirebaseFunctions>(),
      ),
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
    gh.lazySingleton<_i726.ReportCacheHelper>(
      () => _i726.ReportCacheHelper(
        db: gh<_i705.DBHelper>(),
        remote: gh<_i1004.ReportFirebase>(),
      ),
    );
    gh.lazySingleton<_i738.AlertCacheHelper>(
      () => _i738.AlertCacheHelper(
        db: gh<_i705.DBHelper>(),
        remote: gh<_i113.AlertFirebase>(),
      ),
    );
    gh.lazySingleton<_i1063.NotificationFirebase>(
      () =>
          _i1063.NotificationFirebase(firestore: gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i638.WorklistFirebase>(
      () => _i638.WorklistFirebase(firestore: gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i614.CaseCacheHelper>(
      () => _i614.CaseCacheHelper(
        db: gh<_i705.DBHelper>(),
        cases: gh<_i449.CaseFirebase>(),
        shares: gh<_i374.ShareCodeFirebase>(),
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
    gh.lazySingleton<_i656.AppointmentFirebase>(
      () => _i656.AppointmentFirebase(
        firestore: gh<_i974.FirebaseFirestore>(),
        functions: gh<_i809.FirebaseFunctions>(),
        storage: gh<_i457.FirebaseStorage>(),
      ),
    );
    gh.lazySingleton<_i746.ConversationFirebase>(
      () => _i746.ConversationFirebase(
        firestore: gh<_i974.FirebaseFirestore>(),
        functions: gh<_i809.FirebaseFunctions>(),
        storage: gh<_i457.FirebaseStorage>(),
      ),
    );
    gh.lazySingleton<_i407.WorklistCacheHelper>(
      () => _i407.WorklistCacheHelper(
        db: gh<_i705.DBHelper>(),
        remote: gh<_i638.WorklistFirebase>(),
      ),
    );
    gh.lazySingleton<_i219.NotificationCacheHelper>(
      () => _i219.NotificationCacheHelper(
        db: gh<_i705.DBHelper>(),
        remote: gh<_i1063.NotificationFirebase>(),
      ),
    );
    gh.lazySingleton<_i210.NotificationsHelper>(
      () => _i210.NotificationsHelper(
        notificationService: gh<_i1051.NotificationService>(),
        hiveHelper: gh<_i418.HiveHelper>(),
      ),
    );
    gh.lazySingleton<_i679.ConversationCacheHelper>(
      () => _i679.ConversationCacheHelper(
        db: gh<_i705.DBHelper>(),
        remote: gh<_i746.ConversationFirebase>(),
        hive: gh<_i418.HiveHelper>(),
      ),
    );
    gh.lazySingleton<_i393.AppointmentCacheHelper>(
      () => _i393.AppointmentCacheHelper(
        db: gh<_i705.DBHelper>(),
        remote: gh<_i656.AppointmentFirebase>(),
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
