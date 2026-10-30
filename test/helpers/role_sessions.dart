import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tabibu/app/view/app.dart' show tabibuLocalizationsDelegates;
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/constants/theme_builder.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';
import 'package:tabibu/l10n/l10n.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

/// A signed-in session for each role, as the role shells read them.
abstract final class RoleSessions {
  static final patient = PatientSession(
    patient: PatientModel.empty().copyWith(
      firstName: 'Amina',
      lastName: 'Wambui',
      phoneNumber: '+254712345678',
      county: 'Nairobi',
      subCounty: 'Embakasi',
      receiveNotifications: true,
    ),
    roles: const RoleHelper(
      role: Role.patient,
      isAdmin: false,
      isAlertApprover: false,
    ),
  );

  static PractitionerSession doctor({bool isAlertApprover = false}) =>
      PractitionerSession(
        doctor: DoctorModel.empty().copyWith(
          title: 'Dr.',
          firstName: 'Wanjiru',
          lastName: 'Kamau',
          specialties: ['General surgery'],
          kmpdcNumber: 'A 12345',
          facilityName: 'Aga Khan University Hospital',
          county: 'Nairobi',
          receiveNotifications: true,
        ),
        roles: RoleHelper(
          role: Role.doctor,
          isAdmin: false,
          isAlertApprover: isAlertApprover,
        ),
      );

  static final pathologist = PractitionerSession(
    doctor: DoctorModel.empty().copyWith(
      title: 'Dr.',
      firstName: 'Achieng',
      lastName: 'Odhiambo',
      isPathologist: true,
      specialties: ['Histopathology', 'Cytology'],
      kmpdcNumber: 'B 67890',
      facilityName: 'Lancet Kenya, Upper Hill',
      isAvailable: true,
    ),
    roles: const RoleHelper(
      role: Role.pathologist,
      isAdmin: false,
      isAlertApprover: false,
    ),
  );
}

extension PumpRoleApp on WidgetTester {
  /// The app's routes at [location], signed in as [session]. Returns the
  /// [AuthBloc] so a test can verify what the screen asked of it; [states]
  /// replays the bloc's states after the first frame.
  Future<MockAuthBloc> pumpRoleApp(
    AuthSession session,
    String location, {
    ThemeMode themeMode = ThemeMode.light,
    List<AuthState>? states,
  }) async {
    PackageInfo.setMockInitialValues(
      appName: 'Tabibu',
      packageName: 'com.tabibukenya.tabibu',
      version: '1.0.02',
      buildNumber: '1002',
      buildSignature: '',
    );
    final bloc = MockAuthBloc();
    final initial = SignInSuccess(session: session);
    if (states == null) {
      when(() => bloc.state).thenReturn(initial);
    } else {
      whenListen(bloc, Stream.fromIterable(states), initialState: initial);
    }
    final router = GoRouter(initialLocation: location, routes: $appRoutes);
    addTearDown(router.dispose);
    // As pumpRouterApp, with the bloc above the app as in the real tree.
    await pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: bloc,
        child: MaterialApp.router(
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: themeMode,
          localizationsDelegates: tabibuLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    return bloc;
  }
}
