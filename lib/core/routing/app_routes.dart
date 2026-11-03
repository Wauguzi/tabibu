import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/routing/landing.dart';
import 'package:tabibu/features/alerts/presentation/alert_review_screen.dart';
import 'package:tabibu/features/alerts/presentation/alert_sent_screen.dart';
import 'package:tabibu/features/alerts/presentation/health_notice_screen.dart';
import 'package:tabibu/features/alerts/presentation/moh_protocol_screen.dart';
import 'package:tabibu/features/appointments/presentation/appointments_screen.dart';
import 'package:tabibu/features/appointments/presentation/booked_screen.dart';
import 'package:tabibu/features/appointments/presentation/booking_requests_screen.dart';
import 'package:tabibu/features/appointments/presentation/calendar_screen.dart';
import 'package:tabibu/features/appointments/presentation/doctor_appointment_screen.dart';
import 'package:tabibu/features/appointments/presentation/patient_appointment_screen.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/presentation/clinic_record_screen.dart';
import 'package:tabibu/features/auth/presentation/decision_screen.dart';
import 'package:tabibu/features/auth/presentation/patient_account_screen.dart';
import 'package:tabibu/features/auth/presentation/patient_all_set_screen.dart';
import 'package:tabibu/features/auth/presentation/patient_area_screen.dart';
import 'package:tabibu/features/auth/presentation/patient_name_screen.dart';
import 'package:tabibu/features/auth/presentation/patient_phone_screen.dart';
import 'package:tabibu/features/auth/presentation/pending_verification_screen.dart';
import 'package:tabibu/features/auth/presentation/practitioner_details_screen.dart';
import 'package:tabibu/features/auth/presentation/practitioner_facility_screen.dart';
import 'package:tabibu/features/auth/presentation/practitioner_licence_screen.dart';
import 'package:tabibu/features/auth/presentation/practitioner_review_screen.dart';
import 'package:tabibu/features/auth/presentation/reset_password_screen.dart';
import 'package:tabibu/features/auth/presentation/reset_password_sent_screen.dart';
import 'package:tabibu/features/auth/presentation/role_screen.dart';
import 'package:tabibu/features/auth/presentation/sign_in_screen.dart';
import 'package:tabibu/features/auth/presentation/verified_screen.dart';
import 'package:tabibu/features/auth/presentation/verify_email_screen.dart';
import 'package:tabibu/features/cases/presentation/cases_screen.dart';
import 'package:tabibu/features/cases/presentation/doctor_case_screen.dart';
import 'package:tabibu/features/cases/presentation/enter_share_code_screen.dart';
import 'package:tabibu/features/cases/presentation/patient_result_screen.dart';
import 'package:tabibu/features/cases/presentation/reports_ready_screen.dart';
import 'package:tabibu/features/cases/presentation/results_screen.dart';
import 'package:tabibu/features/cases/presentation/share_done_screen.dart';
import 'package:tabibu/features/cases/presentation/share_report_screen.dart';
import 'package:tabibu/features/cases/presentation/shared_reports_screen.dart';
import 'package:tabibu/features/cases/presentation/who_can_see_screen.dart';
import 'package:tabibu/features/conversations/presentation/appointment_chat_screen.dart';
import 'package:tabibu/features/conversations/presentation/mdt_consult_screen.dart';
import 'package:tabibu/features/conversations/presentation/mdt_invite_screen.dart';
import 'package:tabibu/features/conversations/presentation/mdt_screen.dart';
import 'package:tabibu/features/conversations/presentation/new_mdt_screen.dart';
import 'package:tabibu/features/home/presentation/doctor_home_screen.dart';
import 'package:tabibu/features/home/presentation/home_shell.dart';
import 'package:tabibu/features/home/presentation/patient_home_screen.dart';
import 'package:tabibu/features/notifications/presentation/notifications_screen.dart';
import 'package:tabibu/features/onboarding/presentation/get_started_screen.dart';
import 'package:tabibu/features/onboarding/presentation/intro_screen.dart';
import 'package:tabibu/features/onboarding/presentation/language_screen.dart';
import 'package:tabibu/features/onboarding/presentation/update_required_screen.dart';
import 'package:tabibu/features/orders/presentation/order_screen.dart';
import 'package:tabibu/features/orders/presentation/order_sent_screen.dart';
import 'package:tabibu/features/practitioners/presentation/doctor_profile_screen.dart';
import 'package:tabibu/features/practitioners/presentation/find_doctor_screen.dart';
import 'package:tabibu/features/profile/presentation/profile_screen.dart';
import 'package:tabibu/features/reports/presentation/case_workspace_screen.dart';
import 'package:tabibu/features/reports/presentation/compare_screen.dart';
import 'package:tabibu/features/reports/presentation/doctor_report_screen.dart';
import 'package:tabibu/features/reports/presentation/explained_result_screen.dart';
import 'package:tabibu/features/reports/presentation/full_report_screen.dart';
import 'package:tabibu/features/reports/presentation/signed_screen.dart';
import 'package:tabibu/features/reports/presentation/tiles_screen.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_state.dart';
import 'package:tabibu/features/worklist/presentation/desk_list_screen.dart';
import 'package:tabibu/features/worklist/presentation/desk_screen.dart';
import 'package:tabibu/features/worklist/presentation/desk_search_screen.dart';

part 'app_routes.g.dart';

// Screen ids follow the designs (A1 to F5).

/// The route for each [Landing], shared by the decision route and every
/// screen that finishes a sign-in or sign-up step.
GoRouteData routeForLanding(Landing landing) => switch (landing) {
  .update => const UpdateRoute(),
  .onboarding => const LanguageRoute(),
  .signIn => const SignInRoute(),
  .verifyEmail => const VerifyEmailRoute(),
  .finishSignUp => const SignUpRoleRoute(),
  .clinicRecord => const ClinicRecordRoute(),
  .pending => const PendingVerificationRoute(),
  .patientHome => const PatientHomeRoute(),
  .doctorHome => const DoctorHomeRoute(),
  .pathologistHome => const PathologistHomeRoute(),
};

/// Sends a person who has just signed in or signed up where [session]
/// belongs, by the same order as a cold start.
void goToSession(BuildContext context, AuthSession session) => routeForLanding(
  resolveLanding(session: session, updateRequired: false, isOnboarded: true),
).go(context);

@TypedGoRoute<DecisionRoute>(path: RoutePaths.decision)
class DecisionRoute extends GoRouteData with $DecisionRoute {
  const DecisionRoute({this.from});

  /// A deep link the guard held back, followed once the session is known.
  final String? from;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DecisionScreen(from: from);
}

@TypedGoRoute<UpdateRoute>(path: RoutePaths.update)
class UpdateRoute extends GoRouteData with $UpdateRoute {
  const UpdateRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const UpdateRequiredScreen();
}

// ── Onboarding (A2 to A6) ──────────────────────────────────────────────────

@TypedGoRoute<LanguageRoute>(path: '/language')
class LanguageRoute extends GoRouteData with $LanguageRoute {
  const LanguageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const LanguageScreen();
}

/// A3 to A5, one paged screen.
@TypedGoRoute<IntroRoute>(path: '/intro')
class IntroRoute extends GoRouteData with $IntroRoute {
  const IntroRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const IntroScreen();
}

@TypedGoRoute<GetStartedRoute>(path: '/get-started')
class GetStartedRoute extends GoRouteData with $GetStartedRoute {
  const GetStartedRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const GetStartedScreen();
}

// ── Sign-in (B) ────────────────────────────────────────────────────────────

/// B1, and B2 as its wrong-password state.
@TypedGoRoute<SignInRoute>(path: '/sign-in')
class SignInRoute extends GoRouteData with $SignInRoute {
  const SignInRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SignInScreen();
}

@TypedGoRoute<ResetPasswordRoute>(
  path: '/reset-password',
  routes: [TypedGoRoute<ResetPasswordSentRoute>(path: 'sent')],
)
class ResetPasswordRoute extends GoRouteData with $ResetPasswordRoute {
  const ResetPasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ResetPasswordScreen();
}

class ResetPasswordSentRoute extends GoRouteData with $ResetPasswordSentRoute {
  const ResetPasswordSentRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ResetPasswordSentScreen();
}

// ── Sign-up (C, D, E, F) ───────────────────────────────────────────────────
// The draft lives in SignUpBloc, so these routes take no parameters. The
// practitioner steps serve doctors (E) and pathologists (F); the draft's role
// decides the copy.

@TypedGoRoute<SignUpRoleRoute>(
  path: RoutePaths.signUp,
  routes: [
    TypedGoRoute<PatientNameRoute>(path: 'patient/name'),
    TypedGoRoute<PatientAccountRoute>(path: 'patient/account'),
    TypedGoRoute<PatientPhoneRoute>(path: 'patient/phone'),
    TypedGoRoute<PatientAreaRoute>(path: 'patient/area'),
    TypedGoRoute<PractitionerDetailsRoute>(path: 'practitioner/details'),
    TypedGoRoute<PractitionerLicenceRoute>(path: 'practitioner/licence'),
    TypedGoRoute<PractitionerFacilityRoute>(path: 'practitioner/facility'),
    TypedGoRoute<PractitionerReviewRoute>(path: 'practitioner/review'),
  ],
)
class SignUpRoleRoute extends GoRouteData with $SignUpRoleRoute {
  const SignUpRoleRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const RoleScreen();
}

class PatientNameRoute extends GoRouteData with $PatientNameRoute {
  const PatientNameRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PatientNameScreen();
}

/// Creates the Auth account.
class PatientAccountRoute extends GoRouteData with $PatientAccountRoute {
  const PatientAccountRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PatientAccountScreen();
}

class PatientPhoneRoute extends GoRouteData with $PatientPhoneRoute {
  const PatientPhoneRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PatientPhoneScreen();
}

/// Submits the patient sign-up.
class PatientAreaRoute extends GoRouteData with $PatientAreaRoute {
  const PatientAreaRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PatientAreaScreen();
}

/// E1 and F1; creates the Auth account, or skips that when one is signed in.
class PractitionerDetailsRoute extends GoRouteData
    with $PractitionerDetailsRoute {
  const PractitionerDetailsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PractitionerDetailsScreen();
}

class PractitionerLicenceRoute extends GoRouteData
    with $PractitionerLicenceRoute {
  const PractitionerLicenceRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PractitionerLicenceScreen();
}

class PractitionerFacilityRoute extends GoRouteData
    with $PractitionerFacilityRoute {
  const PractitionerFacilityRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PractitionerFacilityScreen();
}

/// Uploads the files and submits.
class PractitionerReviewRoute extends GoRouteData
    with $PractitionerReviewRoute {
  const PractitionerReviewRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PractitionerReviewScreen();
}

// ── Account states after sign-up ───────────────────────────────────────────

// Under RoutePaths.account, which the guard holds for signed-in accounts.

@TypedGoRoute<PatientAllSetRoute>(path: '${RoutePaths.account}/all-set')
class PatientAllSetRoute extends GoRouteData with $PatientAllSetRoute {
  const PatientAllSetRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PatientAllSetScreen();
}

/// A clinic already holds this phone and birth date; the doctor links the
/// account in person (T-15).
@TypedGoRoute<ClinicRecordRoute>(path: '${RoutePaths.account}/clinic-record')
class ClinicRecordRoute extends GoRouteData with $ClinicRecordRoute {
  const ClinicRecordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ClinicRecordScreen();
}

/// E5, and the rejected state.
/// Between the account step and the next profile step: the address must be
/// confirmed before any profile is created (the callables refuse otherwise).
@TypedGoRoute<VerifyEmailRoute>(path: '${RoutePaths.account}/verify-email')
class VerifyEmailRoute extends GoRouteData with $VerifyEmailRoute {
  const VerifyEmailRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const VerifyEmailScreen();
}

@TypedGoRoute<PendingVerificationRoute>(path: '${RoutePaths.account}/pending')
class PendingVerificationRoute extends GoRouteData
    with $PendingVerificationRoute {
  const PendingVerificationRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PendingVerificationScreen();
}

/// E6 and F5, shown once after verification.
@TypedGoRoute<VerifiedRoute>(path: '${RoutePaths.account}/verified')
class VerifiedRoute extends GoRouteData with $VerifiedRoute {
  const VerifiedRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const VerifiedScreen();
}

// ── Role homes ─────────────────────────────────────────────────────────────
// Guarded by role claim. Each role is a StatefulShellRoute of four tabs under
// its home path (architecture §8); a tab keeps its state while another shows.

/// The branch data every role tab shares; a branch carries nothing of its own.
class RoleTabBranch extends StatefulShellBranchData {
  const RoleTabBranch();
}

@TypedStatefulShellRoute<PatientShellRoute>(
  branches: [
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [TypedGoRoute<PatientHomeRoute>(path: RoutePaths.patient)],
    ),
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [
        TypedGoRoute<PatientAppointmentsRoute>(
          path: '${RoutePaths.patient}/appointments',
        ),
      ],
    ),
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [
        TypedGoRoute<PatientResultsRoute>(
          path: '${RoutePaths.patient}/results',
        ),
      ],
    ),
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [
        TypedGoRoute<PatientProfileRoute>(
          path: '${RoutePaths.patient}/profile',
        ),
      ],
    ),
  ],
)
class PatientShellRoute extends StatefulShellRouteData {
  const PatientShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => HomeShell(role: .patient, navigationShell: navigationShell);
}

class PatientHomeRoute extends GoRouteData with $PatientHomeRoute {
  const PatientHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PatientHomeScreen();
}

class PatientAppointmentsRoute extends GoRouteData
    with $PatientAppointmentsRoute {
  const PatientAppointmentsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AppointmentsScreen();
}

class PatientResultsRoute extends GoRouteData with $PatientResultsRoute {
  const PatientResultsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ResultsScreen();
}

class PatientProfileRoute extends GoRouteData with $PatientProfileRoute {
  const PatientProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileScreen(role: .patient);
}

@TypedStatefulShellRoute<DoctorShellRoute>(
  branches: [
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [TypedGoRoute<DoctorHomeRoute>(path: RoutePaths.doctor)],
    ),
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [
        TypedGoRoute<DoctorCasesRoute>(path: '${RoutePaths.doctor}/cases'),
      ],
    ),
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [TypedGoRoute<DoctorMdtRoute>(path: '${RoutePaths.doctor}/mdt')],
    ),
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [
        TypedGoRoute<DoctorProfileRoute>(path: '${RoutePaths.doctor}/profile'),
      ],
    ),
  ],
)
class DoctorShellRoute extends StatefulShellRouteData {
  const DoctorShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => HomeShell(role: .doctor, navigationShell: navigationShell);
}

class DoctorHomeRoute extends GoRouteData with $DoctorHomeRoute {
  const DoctorHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const DoctorHomeScreen();
}

class DoctorCasesRoute extends GoRouteData with $DoctorCasesRoute {
  const DoctorCasesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CasesScreen();
}

class DoctorMdtRoute extends GoRouteData with $DoctorMdtRoute {
  const DoctorMdtRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const MdtScreen(role: .doctor);
}

class DoctorProfileRoute extends GoRouteData with $DoctorProfileRoute {
  const DoctorProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileScreen(role: .doctor);
}

@TypedStatefulShellRoute<PathologistShellRoute>(
  branches: [
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [
        TypedGoRoute<PathologistHomeRoute>(path: RoutePaths.pathologist),
      ],
    ),
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [
        TypedGoRoute<PathologistSignedRoute>(
          path: '${RoutePaths.pathologist}/signed',
        ),
      ],
    ),
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [
        TypedGoRoute<PathologistMdtRoute>(
          path: '${RoutePaths.pathologist}/mdt',
        ),
      ],
    ),
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [
        TypedGoRoute<PathologistProfileRoute>(
          path: '${RoutePaths.pathologist}/profile',
        ),
      ],
    ),
  ],
)
class PathologistShellRoute extends StatefulShellRouteData {
  const PathologistShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => HomeShell(role: .pathologist, navigationShell: navigationShell);
}

class PathologistHomeRoute extends GoRouteData with $PathologistHomeRoute {
  const PathologistHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const DeskScreen();
}

class PathologistSignedRoute extends GoRouteData with $PathologistSignedRoute {
  const PathologistSignedRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SignedScreen();
}

class PathologistMdtRoute extends GoRouteData with $PathologistMdtRoute {
  const PathologistMdtRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const MdtScreen(role: .pathologist);
}

class PathologistProfileRoute extends GoRouteData
    with $PathologistProfileRoute {
  const PathologistProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileScreen(role: .pathologist);
}

// Tier 1 screens off the tabs. Each sits on the root navigator under its role's
// prefix, so it covers the tab bar (as every design does) and the role guard
// applies unchanged. Routes carry ids only (F-2).

/// P-02.
@TypedGoRoute<PatientNotificationsRoute>(
  path: '${RoutePaths.patient}/notifications',
)
class PatientNotificationsRoute extends GoRouteData
    with $PatientNotificationsRoute {
  const PatientNotificationsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const NotificationsScreen(role: .patient);
}

/// P-03.
@TypedGoRoute<FindDoctorRoute>(path: '${RoutePaths.patient}/doctors')
class FindDoctorRoute extends GoRouteData with $FindDoctorRoute {
  const FindDoctorRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const FindDoctorScreen();
}

/// P-04.
@TypedGoRoute<PractitionerProfileRoute>(
  path: '${RoutePaths.patient}/doctors/:doctorUid',
)
class PractitionerProfileRoute extends GoRouteData
    with $PractitionerProfileRoute {
  const PractitionerProfileRoute({required this.doctorUid});

  final String doctorUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DoctorProfileScreen(doctorUid: doctorUid);
}

/// P-09, P-10.
@TypedGoRoute<PatientAppointmentRoute>(
  path: '${RoutePaths.patient}/appointment/:appointmentUid',
)
class PatientAppointmentRoute extends GoRouteData
    with $PatientAppointmentRoute {
  const PatientAppointmentRoute({required this.appointmentUid});

  final String appointmentUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      PatientAppointmentScreen(
        appointmentUid: appointmentUid,
        moved: state.extra == true,
      );
}

/// The patient's month view.
@TypedGoRoute<PatientCalendarRoute>(path: '${RoutePaths.patient}/calendar')
class PatientCalendarRoute extends GoRouteData with $PatientCalendarRoute {
  const PatientCalendarRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CalendarScreen(role: .patient);
}

/// P-07; reached with pushReplacement (F-1).
@TypedGoRoute<BookedRoute>(
  path: '${RoutePaths.patient}/appointment/:appointmentUid/booked',
)
class BookedRoute extends GoRouteData with $BookedRoute {
  const BookedRoute({required this.appointmentUid});

  final String appointmentUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BookedScreen(appointmentUid: appointmentUid);
}

/// P-11b, P-13.
@TypedGoRoute<PatientResultRoute>(path: '${RoutePaths.patient}/result/:caseUid')
class PatientResultRoute extends GoRouteData with $PatientResultRoute {
  const PatientResultRoute({required this.caseUid});

  final String caseUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      PatientResultScreen(caseUid: caseUid);
}

/// P-14; opens only with an approved explanation (F-8).
@TypedGoRoute<ExplainedResultRoute>(
  path: '${RoutePaths.patient}/result/:caseUid/explained',
)
class ExplainedResultRoute extends GoRouteData with $ExplainedResultRoute {
  const ExplainedResultRoute({required this.caseUid});

  final String caseUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ExplainedResultScreen(caseUid: caseUid);
}

/// P-SHARE · Share report.
@TypedGoRoute<ShareReportRoute>(
  path: '${RoutePaths.patient}/result/:caseUid/share',
)
class ShareReportRoute extends GoRouteData with $ShareReportRoute {
  const ShareReportRoute({required this.caseUid});

  final String caseUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ShareReportScreen(caseUid: caseUid);
}

/// P-SHARE · Report shared; reached with pushReplacement (F-1). Carries the
/// case id only; the share and any code live in the ShareBloc (T-18).
@TypedGoRoute<ShareDoneRoute>(
  path: '${RoutePaths.patient}/result/:caseUid/share/done',
)
class ShareDoneRoute extends GoRouteData with $ShareDoneRoute {
  const ShareDoneRoute({required this.caseUid});

  final String caseUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ShareDoneScreen(caseUid: caseUid);
}

/// P-SHARE · Who can see my results.
@TypedGoRoute<WhoCanSeeRoute>(
  path: '${RoutePaths.patient}/result/:caseUid/who-can-see',
)
class WhoCanSeeRoute extends GoRouteData with $WhoCanSeeRoute {
  const WhoCanSeeRoute({required this.caseUid});

  final String caseUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      WhoCanSeeScreen(caseUid: caseUid);
}

/// P-SHARE · Shared reports.
@TypedGoRoute<SharedReportsRoute>(path: '${RoutePaths.patient}/shares')
class SharedReportsRoute extends GoRouteData with $SharedReportsRoute {
  const SharedReportsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SharedReportsScreen();
}

/// P-12.
@TypedGoRoute<HealthNoticeRoute>(path: '${RoutePaths.patient}/notice/:alertUid')
class HealthNoticeRoute extends GoRouteData with $HealthNoticeRoute {
  const HealthNoticeRoute({required this.alertUid});

  final String alertUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      HealthNoticeScreen(alertUid: alertUid);
}

/// D-NOTIFICATIONS.
@TypedGoRoute<DoctorNotificationsRoute>(
  path: '${RoutePaths.doctor}/notifications',
)
class DoctorNotificationsRoute extends GoRouteData
    with $DoctorNotificationsRoute {
  const DoctorNotificationsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const NotificationsScreen(role: .doctor);
}

/// D-REPORTS-READY.
@TypedGoRoute<ReportsReadyRoute>(path: '${RoutePaths.doctor}/reports-ready')
class ReportsReadyRoute extends GoRouteData with $ReportsReadyRoute {
  const ReportsReadyRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ReportsReadyScreen();
}

/// D-BOOKINGS.
@TypedGoRoute<BookingRequestsRoute>(
  path: '${RoutePaths.doctor}/booking-requests',
)
class BookingRequestsRoute extends GoRouteData with $BookingRequestsRoute {
  const BookingRequestsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const BookingRequestsScreen();
}

/// D-APPT.
@TypedGoRoute<DoctorAppointmentRoute>(
  path: '${RoutePaths.doctor}/appointment/:appointmentUid',
)
class DoctorAppointmentRoute extends GoRouteData with $DoctorAppointmentRoute {
  const DoctorAppointmentRoute({required this.appointmentUid});

  final String appointmentUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DoctorAppointmentScreen(appointmentUid: appointmentUid);
}

/// The doctor's month view.
@TypedGoRoute<DoctorCalendarRoute>(path: '${RoutePaths.doctor}/calendar')
class DoctorCalendarRoute extends GoRouteData with $DoctorCalendarRoute {
  const DoctorCalendarRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CalendarScreen(role: .doctor);
}

/// D-ORDER-CATALOGUE to D-ORDER-PATHOLOGIST.
@TypedGoRoute<OrderRoute>(
  path: '${RoutePaths.doctor}/appointment/:appointmentUid/order',
)
class OrderRoute extends GoRouteData with $OrderRoute {
  const OrderRoute({required this.appointmentUid});

  final String appointmentUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      OrderScreen(appointmentUid: appointmentUid);
}

/// D-ORDER-SENT; reached with pushReplacement (F-1).
@TypedGoRoute<OrderSentRoute>(path: '${RoutePaths.doctor}/case/:caseUid/sent')
class OrderSentRoute extends GoRouteData with $OrderSentRoute {
  const OrderSentRoute({required this.caseUid});

  final String caseUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      OrderSentScreen(caseUid: caseUid);
}

/// D-MOH-PROTOCOL.
@TypedGoRoute<MohProtocolRoute>(
  path: '${RoutePaths.doctor}/protocol/:protocolId',
)
class MohProtocolRoute extends GoRouteData with $MohProtocolRoute {
  const MohProtocolRoute({required this.protocolId});

  /// A risk-check advisory key, e.g. `VhfProtocol` (F-13).
  final String protocolId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      MohProtocolScreen(protocolId: protocolId);
}

/// D-CASE.
@TypedGoRoute<DoctorCaseRoute>(path: '${RoutePaths.doctor}/case/:caseUid')
class DoctorCaseRoute extends GoRouteData with $DoctorCaseRoute {
  const DoctorCaseRoute({required this.caseUid});

  final String caseUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DoctorCaseScreen(caseUid: caseUid);
}

/// D-SHARE-CODE. Carries the share id only, never the code (T-18).
@TypedGoRoute<DoctorEnterShareCodeRoute>(
  path: '${RoutePaths.doctor}/share/:shareUid',
)
class DoctorEnterShareCodeRoute extends GoRouteData
    with $DoctorEnterShareCodeRoute {
  const DoctorEnterShareCodeRoute({required this.shareUid});

  final String shareUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      EnterShareCodeScreen(role: .doctor, shareUid: shareUid);
}

/// D-REPORT-SUMMARY.
@TypedGoRoute<DoctorReportRoute>(
  path: '${RoutePaths.doctor}/case/:caseUid/report',
)
class DoctorReportRoute extends GoRouteData with $DoctorReportRoute {
  const DoctorReportRoute({required this.caseUid});

  final String caseUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DoctorReportScreen(caseUid: caseUid);
}

/// D-REPORT-FULL.
@TypedGoRoute<FullReportRoute>(
  path: '${RoutePaths.doctor}/case/:caseUid/report/full',
)
class FullReportRoute extends GoRouteData with $FullReportRoute {
  const FullReportRoute({required this.caseUid});

  final String caseUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      FullReportScreen(caseUid: caseUid);
}

/// D-ALERT; approvers only (F-6).
@TypedGoRoute<AlertReviewRoute>(path: '${RoutePaths.doctor}/alert/:alertUid')
class AlertReviewRoute extends GoRouteData with $AlertReviewRoute {
  const AlertReviewRoute({required this.alertUid});

  final String alertUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AlertReviewScreen(alertUid: alertUid);
}

/// D-ALERT-SENT; reached with pushReplacement (F-1).
@TypedGoRoute<AlertSentRoute>(path: '${RoutePaths.doctor}/alert/:alertUid/sent')
class AlertSentRoute extends GoRouteData with $AlertSentRoute {
  const AlertSentRoute({required this.alertUid});

  final String alertUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AlertSentScreen(alertUid: alertUid);
}

/// PA-05.
@TypedGoRoute<PathologistNotificationsRoute>(
  path: '${RoutePaths.pathologist}/notifications',
)
class PathologistNotificationsRoute extends GoRouteData
    with $PathologistNotificationsRoute {
  const PathologistNotificationsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const NotificationsScreen(role: .pathologist);
}

/// PA-02.
@TypedGoRoute<DeskListRoute>(path: '${RoutePaths.pathologist}/cases')
class DeskListRoute extends GoRouteData with $DeskListRoute {
  const DeskListRoute({this.filter = 'all'});

  /// A [DeskFilter] name; an unknown one reads as all (the generator's enum
  /// maps are untyped, so the route carries the name).
  final String filter;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DeskListScreen(filter: DeskFilter.values.asNameMap()[filter] ?? .all);
}

/// PA-03.
@TypedGoRoute<DeskSearchRoute>(path: '${RoutePaths.pathologist}/search')
class DeskSearchRoute extends GoRouteData with $DeskSearchRoute {
  const DeskSearchRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const DeskSearchScreen();
}

/// CS-01 to CS-08.
@TypedGoRoute<CaseWorkspaceRoute>(
  path: '${RoutePaths.pathologist}/case/:caseUid',
)
class CaseWorkspaceRoute extends GoRouteData with $CaseWorkspaceRoute {
  const CaseWorkspaceRoute({required this.caseUid});

  final String caseUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      CaseWorkspaceScreen(caseUid: caseUid);
}

/// D-SHARE-CODE for a pathologist. Carries the share id only (T-18).
@TypedGoRoute<PathologistEnterShareCodeRoute>(
  path: '${RoutePaths.pathologist}/share/:shareUid',
)
class PathologistEnterShareCodeRoute extends GoRouteData
    with $PathologistEnterShareCodeRoute {
  const PathologistEnterShareCodeRoute({required this.shareUid});

  final String shareUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      EnterShareCodeScreen(role: .pathologist, shareUid: shareUid);
}

/// CS-03.
@TypedGoRoute<TilesRoute>(path: '${RoutePaths.pathologist}/case/:caseUid/tiles')
class TilesRoute extends GoRouteData with $TilesRoute {
  const TilesRoute({required this.caseUid});

  final String caseUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TilesScreen(caseUid: caseUid);
}

/// CS-09; the signer only (H-4).
@TypedGoRoute<CompareRoute>(
  path: '${RoutePaths.pathologist}/case/:caseUid/compare',
)
class CompareRoute extends GoRouteData with $CompareRoute {
  const CompareRoute({required this.caseUid});

  final String caseUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      CompareScreen(caseUid: caseUid);
}

// ── MDT (D-MDT, PA-MDT) ────────────────────────────────────────────────────
// Detail routes carry ids only (F-2). `new` is declared before the consult
// route so it is never read as a conversation id.

/// D-MDT · New consult, optionally on a case already chosen.
@TypedGoRoute<DoctorMdtNewRoute>(path: '${RoutePaths.doctor}/mdt/new')
class DoctorMdtNewRoute extends GoRouteData with $DoctorMdtNewRoute {
  const DoctorMdtNewRoute({this.caseUid});

  final String? caseUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      NewMdtScreen(role: .doctor, caseUid: caseUid ?? '');
}

/// D-MDT · A consult, or an invite to one.
@TypedGoRoute<DoctorMdtConsultRoute>(
  path: '${RoutePaths.doctor}/mdt/:conversationUid',
)
class DoctorMdtConsultRoute extends GoRouteData with $DoctorMdtConsultRoute {
  const DoctorMdtConsultRoute({required this.conversationUid});

  final String conversationUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      MdtConsultScreen(role: .doctor, conversationUid: conversationUid);
}

/// D-MDT · Invite a colleague to a consult.
@TypedGoRoute<DoctorMdtInviteRoute>(
  path: '${RoutePaths.doctor}/mdt/:conversationUid/invite',
)
class DoctorMdtInviteRoute extends GoRouteData with $DoctorMdtInviteRoute {
  const DoctorMdtInviteRoute({required this.conversationUid});

  final String conversationUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      MdtInviteScreen(role: .doctor, conversationUid: conversationUid);
}

/// PA-MDT · New consult, optionally on a case already chosen.
@TypedGoRoute<PathologistMdtNewRoute>(path: '${RoutePaths.pathologist}/mdt/new')
class PathologistMdtNewRoute extends GoRouteData with $PathologistMdtNewRoute {
  const PathologistMdtNewRoute({this.caseUid});

  final String? caseUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      NewMdtScreen(role: .pathologist, caseUid: caseUid ?? '');
}

/// PA-MDT · A consult, or an invite to one.
@TypedGoRoute<PathologistMdtConsultRoute>(
  path: '${RoutePaths.pathologist}/mdt/:conversationUid',
)
class PathologistMdtConsultRoute extends GoRouteData
    with $PathologistMdtConsultRoute {
  const PathologistMdtConsultRoute({required this.conversationUid});

  final String conversationUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      MdtConsultScreen(role: .pathologist, conversationUid: conversationUid);
}

/// PA-MDT · Invite a colleague to a consult.
@TypedGoRoute<PathologistMdtInviteRoute>(
  path: '${RoutePaths.pathologist}/mdt/:conversationUid/invite',
)
class PathologistMdtInviteRoute extends GoRouteData
    with $PathologistMdtInviteRoute {
  const PathologistMdtInviteRoute({required this.conversationUid});

  final String conversationUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      MdtInviteScreen(role: .pathologist, conversationUid: conversationUid);
}

// ── Appointment chat (P-CHAT, D-CHAT) ──────────────────────────────────────
// Id only (F-2). Nested under the appointment path so the share and MDT
// detail routes stay flat siblings.

/// P-CHAT · Direct thread for one appointment.
@TypedGoRoute<PatientAppointmentChatRoute>(
  path: '${RoutePaths.patient}/appointment/:appointmentUid/chat',
)
class PatientAppointmentChatRoute extends GoRouteData
    with $PatientAppointmentChatRoute {
  const PatientAppointmentChatRoute({required this.appointmentUid});

  final String appointmentUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AppointmentChatScreen(role: .patient, appointmentUid: appointmentUid);
}

/// D-CHAT · Direct thread for one appointment.
@TypedGoRoute<DoctorAppointmentChatRoute>(
  path: '${RoutePaths.doctor}/appointment/:appointmentUid/chat',
)
class DoctorAppointmentChatRoute extends GoRouteData
    with $DoctorAppointmentChatRoute {
  const DoctorAppointmentChatRoute({required this.appointmentUid});

  final String appointmentUid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AppointmentChatScreen(role: .doctor, appointmentUid: appointmentUid);
}

// ── App lock (P-LOCK) ──────────────────────────────────────────────────────
