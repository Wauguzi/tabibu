import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/reference_data_helper.dart';
import 'package:tabibu/features/alerts/presentation/alert_review_screen.dart';
import 'package:tabibu/features/alerts/presentation/alert_sent_screen.dart';
import 'package:tabibu/features/alerts/presentation/health_notice_screen.dart';
import 'package:tabibu/features/alerts/presentation/moh_protocol_screen.dart';
import 'package:tabibu/features/appointments/presentation/booked_screen.dart';
import 'package:tabibu/features/appointments/presentation/booking_requests_screen.dart';
import 'package:tabibu/features/appointments/presentation/doctor_appointment_screen.dart';
import 'package:tabibu/features/appointments/presentation/patient_appointment_screen.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/presentation/doctor_case_screen.dart';
import 'package:tabibu/features/cases/presentation/patient_result_screen.dart';
import 'package:tabibu/features/cases/presentation/reports_ready_screen.dart';
import 'package:tabibu/features/notifications/presentation/notifications_screen.dart';
import 'package:tabibu/features/orders/presentation/order_screen.dart';
import 'package:tabibu/features/orders/presentation/order_sent_screen.dart';
import 'package:tabibu/features/practitioners/presentation/doctor_profile_screen.dart';
import 'package:tabibu/features/practitioners/presentation/find_doctor_screen.dart';
import 'package:tabibu/features/preread/data/datasources/preread_storage.dart';
import 'package:tabibu/features/reports/presentation/case_workspace_screen.dart';
import 'package:tabibu/features/reports/presentation/compare_screen.dart';
import 'package:tabibu/features/reports/presentation/doctor_report_screen.dart';
import 'package:tabibu/features/reports/presentation/explained_result_screen.dart';
import 'package:tabibu/features/reports/presentation/full_report_screen.dart';
import 'package:tabibu/features/reports/presentation/tiles_screen.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_state.dart';
import 'package:tabibu/features/worklist/presentation/desk_list_screen.dart';
import 'package:tabibu/features/worklist/presentation/desk_search_screen.dart';

import '../../helpers/helpers.dart';

class _MockReferenceData extends Mock implements ReferenceDataHelper {}

class _MockPrereadStorage extends Mock implements PrereadStorage {}

void main() {
  final patient = RoleSessions.patient;
  final doctor = RoleSessions.doctor();
  final approver = RoleSessions.doctor(isAlertApprover: true);
  final pathologist = RoleSessions.pathologist;

  final routes = <(String, AuthSession, Type)>[
    ('/patient/notifications', patient, NotificationsScreen),
    ('/patient/doctors', patient, FindDoctorScreen),
    ('/patient/doctors/d1', patient, DoctorProfileScreen),
    ('/patient/appointment/a1', patient, PatientAppointmentScreen),
    ('/patient/appointment/a1/booked', patient, BookedScreen),
    ('/patient/result/c1', patient, PatientResultScreen),
    ('/patient/result/c1/explained', patient, ExplainedResultScreen),
    ('/patient/notice/n1', patient, HealthNoticeScreen),
    ('/doctor/notifications', doctor, NotificationsScreen),
    ('/doctor/reports-ready', doctor, ReportsReadyScreen),
    ('/doctor/booking-requests', doctor, BookingRequestsScreen),
    ('/doctor/appointment/a1', doctor, DoctorAppointmentScreen),
    ('/doctor/order?appointment-uid=a1', doctor, OrderScreen),
    ('/doctor/order', doctor, OrderScreen),
    ('/doctor/case/c1/sent', doctor, OrderSentScreen),
    ('/doctor/protocol/malaria', doctor, MohProtocolScreen),
    ('/doctor/case/c1', doctor, DoctorCaseScreen),
    ('/doctor/case/c1/report', doctor, DoctorReportScreen),
    ('/doctor/case/c1/report/full', doctor, FullReportScreen),
    ('/doctor/alert/a1', approver, AlertReviewScreen),
    ('/doctor/alert/a1/sent', approver, AlertSentScreen),
    ('/pathologist/notifications', pathologist, NotificationsScreen),
    ('/pathologist/cases', pathologist, DeskListScreen),
    ('/pathologist/search', pathologist, DeskSearchScreen),
    ('/pathologist/case/c1', pathologist, CaseWorkspaceScreen),
    ('/pathologist/case/c1/tiles', pathologist, TilesScreen),
    ('/pathologist/case/c1/compare', pathologist, CompareScreen),
  ];

  // The approver guard (F-6) is a redirect, tested in landing_test.dart;
  // pumpRoleApp's router has no redirect.
  group('Tier 1 routes', () {
    // Screens that read reference data or slide images straight from DI.
    setUp(() {
      final reference = _MockReferenceData();
      when(reference.publicHealthGuidance).thenAnswer((_) async => []);
      when(reference.notifiableDiseases).thenAnswer((_) async => []);
      when(reference.activeLabTests).thenAnswer((_) async => []);
      when(reference.labTestTypes).thenAnswer((_) async => []);
      when(reference.insurers).thenAnswer((_) async => []);
      getIt
        ..registerSingleton<ReferenceDataHelper>(reference)
        ..registerSingleton<PrereadStorage>(_MockPrereadStorage());
    });

    tearDown(() async {
      await getIt.unregister<ReferenceDataHelper>();
      await getIt.unregister<PrereadStorage>();
    });

    for (final (location, session, screen) in routes) {
      testWidgets('$location opens $screen', (tester) async {
        await tester.pumpRoleApp(session, location);
        // A built screen may show a spinner, which never settles.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(screen), findsOneWidget);
      });
    }

    testWidgets('the desk list reads its filter from the query', (
      tester,
    ) async {
      await tester.pumpRoleApp(
        pathologist,
        '/pathologist/cases?filter=notifiable',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final screen = tester.widget<DeskListScreen>(find.byType(DeskListScreen));
      expect(screen.filter, DeskFilter.notifiable);
    });

    testWidgets('an unknown desk filter reads as all', (tester) async {
      await tester.pumpRoleApp(pathologist, '/pathologist/cases?filter=nope');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final screen = tester.widget<DeskListScreen>(find.byType(DeskListScreen));
      expect(screen.filter, DeskFilter.all);
    });
  });
}
