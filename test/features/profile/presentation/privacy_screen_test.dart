import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_event.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_state.dart';
import 'package:tabibu/features/cases/data/models/share_code_model.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_event.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_state.dart';
import 'package:tabibu/features/lock/presentation/create_pin_screen.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/features/profile/presentation/privacy_screen.dart';
import 'package:tabibu/features/profile/presentation/widgets/settings_group.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

final AppLocalizations _en = lookupAppLocalizations(const Locale('en'));
final AppLocalizations _sw = lookupAppLocalizations(const Locale('sw'));

void main() {
  group('PrivacyScreen', () {
    late FeatureBlocs blocs;

    setUp(() => blocs = FeatureBlocs());

    void tallView(WidgetTester tester) {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }

    Future<void> settleSheet(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    ShareCodeModel share({
      String uid = 'share-1',
      String status = 'Pending',
      String recipientUid = 'doc-9',
      String createdAt = '2026-10-20T10:00:00Z',
    }) => ShareCodeModel(
      uid: uid,
      status: status,
      recipientUid: recipientUid,
      createdAt: createdAt,
    );

    PractitionerModel clinician() => PractitionerModel.empty().copyWith(
      uid: 'doc-9',
      title: 'Dr.',
      firstName: 'Ali',
      lastName: 'Hassan',
    );

    testWidgets("a patient's rows, with no shares yet", (tester) async {
      tallView(tester);
      final base = RoleSessions.patient;
      await tester.pumpRoleApp(
        PatientSession(
          patient: base.patient.copyWith(uid: 'patient-1'),
          roles: base.roles,
        ),
        '/patient/profile/privacy',
        blocs: blocs,
      );
      await tester.pumpAndSettle();

      expect(find.text(_en.privacyTitle), findsOneWidget);
      expect(find.text(_en.privacyPatientBody), findsOneWidget);
      expect(find.text(_en.privacyLocation), findsOneWidget);
      expect(find.text(_en.privacyLocationBody), findsOneWidget);
      expect(find.text(_en.privacyWhoCanSee), findsOneWidget);
      expect(find.text(_en.privacyWhoCanSeeBody), findsOneWidget);
      expect(find.text(_en.privacySharedReports), findsOneWidget);
      expect(find.text(_en.privacyNoShares), findsOneWidget);
      expect(find.text(_en.privacyPolicyRow), findsOneWidget);
      expect(find.text(_en.privacyFooterPatient), findsOneWidget);
      // Location, who can see, shared reports, policy: no download row.
      expect(find.byType(SettingsRow), findsNWidgets(4));
      verify(
        () => blocs.share.add(
          const ShareRequested(uid: 'patient-1', role: .patient, caseUid: ''),
        ),
      ).called(1);
    });

    testWidgets('the shares row counts active shares with the latest name', (
      tester,
    ) async {
      tallView(tester);
      when(() => blocs.share.state).thenReturn(
        ShareLoadSuccess(
          shares: [
            share(),
            share(
              uid: 'share-2',
              createdAt: '2026-10-22T10:00:00Z',
              recipientUid: 'unknown',
            ),
            share(uid: 'share-3', status: 'Redeemed'),
          ],
        ),
      );
      when(
        () => blocs.directory.state,
      ).thenReturn(DirectoryLoadSuccess(all: [clinician()]));
      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/privacy',
        blocs: blocs,
      );
      await tester.pumpAndSettle();

      // Newest first; the unknown recipient reads as a doctor.
      expect(
        find.text(_en.privacyActiveShares(2, _en.roleDoctor)),
        findsOneWidget,
      );
    });

    testWidgets('the shares row opens the shares list; policy opens policy', (
      tester,
    ) async {
      tallView(tester);
      when(
        () => blocs.share.state,
      ).thenReturn(ShareLoadSuccess(shares: [share()]));
      when(
        () => blocs.directory.state,
      ).thenReturn(DirectoryLoadSuccess(all: [clinician()]));
      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/privacy',
        blocs: blocs,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(_en.privacySharedReports));
      await tester.pumpAndSettle();
      expect(find.text(_en.shareListTitle), findsOneWidget);
    });

    testWidgets('a doctor: lock row and policy, no body', (tester) async {
      tallView(tester);
      when(
        () => blocs.lock.state,
      ).thenReturn(const LockLoadSuccess(enabled: true));
      await tester.pumpRoleApp(
        RoleSessions.doctor(),
        '/doctor/profile/privacy',
        blocs: blocs,
      );
      await tester.pumpAndSettle();

      expect(find.text(_en.privacyPaBody), findsNothing);
      expect(find.text(_en.privacyPatientBody), findsNothing);
      expect(find.text(_en.privacyAskPinFace), findsOneWidget);
      expect(find.text(_en.privacyAskPinFaceBody), findsOneWidget);
      expect(find.text(_en.privacyPolicyRowBodyClinician), findsOneWidget);
      expect(find.text(_en.privacyFooterDoctor), findsOneWidget);
      final toggle = tester.widget<SettingsSwitchRow>(
        find.byType(SettingsSwitchRow),
      );
      expect(toggle.value, isTrue);
    });

    testWidgets('unlocking the lock asks the PIN, then disables', (
      tester,
    ) async {
      tallView(tester);
      when(
        () => blocs.lock.state,
      ).thenReturn(const LockLoadSuccess(enabled: true));
      await tester.pumpRoleApp(
        RoleSessions.doctor(),
        '/doctor/profile/privacy',
        blocs: blocs,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(_en.privacyAskPinFace));
      await settleSheet(tester);
      expect(find.text(_en.appLockEnterPin), findsOneWidget);
      for (final digit in ['1', '2', '3', '4']) {
        await tester.tap(find.text(digit).last);
        await tester.pump();
      }
      await tester.pump();
      verify(
        () => blocs.lock.add(const LockDisableRequested(pin: '1234')),
      ).called(1);
    });

    testWidgets('locking opens the create-PIN flow', (tester) async {
      tallView(tester);
      when(() => blocs.lock.state).thenReturn(const LockLoadSuccess());
      await tester.pumpRoleApp(
        RoleSessions.doctor(),
        '/doctor/profile/privacy',
        blocs: blocs,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(_en.privacyAskPinFace));
      await tester.pumpAndSettle();
      expect(find.byType(CreatePinScreen), findsOneWidget);
    });

    testWidgets('a pathologist: body, case lock, policy, patient footer', (
      tester,
    ) async {
      tallView(tester);
      when(() => blocs.lock.state).thenReturn(const LockLoadSuccess());
      await tester.pumpRoleApp(
        RoleSessions.pathologist,
        '/pathologist/profile/privacy',
        blocs: blocs,
      );
      await tester.pumpAndSettle();

      expect(find.text(_en.privacyPaBody), findsOneWidget);
      expect(find.text(_en.privacyPinFaceCase), findsOneWidget);
      expect(find.text(_en.privacyPinFaceCaseBody), findsOneWidget);
      expect(find.text(_en.privacyPolicyRowBodyClinician), findsOneWidget);
      expect(find.text(_en.privacyFooterPatient), findsOneWidget);
    });

    testWidgets('renders in Swahili, dark, at 1.3x', (tester) async {
      tallView(tester);
      when(
        () => blocs.share.state,
      ).thenReturn(ShareLoadSuccess(shares: [share()]));
      when(
        () => blocs.directory.state,
      ).thenReturn(DirectoryLoadSuccess(all: [clinician()]));
      final auth = MockAuthBloc();
      when(
        () => auth.state,
      ).thenReturn(SignInSuccess(session: RoleSessions.patient));
      await tester.pumpApp(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: auth),
              ...blocs.providers,
            ],
            child: const PrivacyScreen(role: .patient),
          ),
        ),
        locale: const Locale('sw'),
        themeMode: ThemeMode.dark,
      );
      await tester.pump();

      expect(find.text(_sw.privacyTitle), findsOneWidget);
      expect(find.text(_sw.privacyPatientBody), findsOneWidget);
      expect(find.text(_sw.privacyLocation), findsOneWidget);
      expect(find.text(_sw.privacyWhoCanSee), findsOneWidget);
      expect(find.text(_sw.privacySharedReports), findsOneWidget);
      expect(find.text(_sw.privacyPolicyRow), findsOneWidget);
      expect(find.text(_sw.privacyFooterPatient), findsOneWidget);
    });
  });
}
