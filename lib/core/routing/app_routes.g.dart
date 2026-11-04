// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $decisionRoute,
  $updateRoute,
  $languageRoute,
  $introRoute,
  $getStartedRoute,
  $signInRoute,
  $resetPasswordRoute,
  $signUpRoleRoute,
  $patientAllSetRoute,
  $clinicRecordRoute,
  $verifyEmailRoute,
  $pendingVerificationRoute,
  $verifiedRoute,
  $patientShellRoute,
  $doctorShellRoute,
  $pathologistShellRoute,
  $patientNotificationsRoute,
  $findDoctorRoute,
  $practitionerProfileRoute,
  $patientAppointmentRoute,
  $patientCalendarRoute,
  $patientProfileDetailsRoute,
  $patientEditProfileRoute,
  $patientProfileAreaRoute,
  $patientProfileLanguageRoute,
  $patientProfileThemeRoute,
  $patientProfileNotificationsRoute,
  $patientPrivacyRoute,
  $patientPrivacyPolicyRoute,
  $patientHelpRoute,
  $bookedRoute,
  $patientResultRoute,
  $explainedResultRoute,
  $patientCaseHistoryRoute,
  $shareReportRoute,
  $shareDoneRoute,
  $whoCanSeeRoute,
  $sharedReportsRoute,
  $healthNoticeRoute,
  $doctorNotificationsRoute,
  $reportsReadyRoute,
  $bookingRequestsRoute,
  $doctorAppointmentRoute,
  $doctorCalendarRoute,
  $doctorProfileDetailsRoute,
  $doctorClinicHoursRoute,
  $doctorProfileLanguageRoute,
  $doctorProfileThemeRoute,
  $doctorProfileNotificationsRoute,
  $doctorPrivacyRoute,
  $doctorPrivacyPolicyRoute,
  $doctorHelpRoute,
  $orderRoute,
  $orderSentRoute,
  $mohProtocolRoute,
  $doctorCaseRoute,
  $doctorCaseHistoryRoute,
  $doctorEnterShareCodeRoute,
  $doctorReportRoute,
  $fullReportRoute,
  $alertReviewRoute,
  $alertSentRoute,
  $pathologistNotificationsRoute,
  $pathologistProfileDetailsRoute,
  $pathologistProfileLanguageRoute,
  $pathologistProfileThemeRoute,
  $pathologistProfileNotificationsRoute,
  $pathologistPrivacyRoute,
  $pathologistPrivacyPolicyRoute,
  $pathologistHelpRoute,
  $deskListRoute,
  $deskSearchRoute,
  $caseWorkspaceRoute,
  $pathologistCaseHistoryRoute,
  $pathologistEnterShareCodeRoute,
  $tilesRoute,
  $compareRoute,
  $doctorMdtNewRoute,
  $doctorMdtConsultRoute,
  $doctorMdtInviteRoute,
  $pathologistMdtNewRoute,
  $pathologistMdtConsultRoute,
  $pathologistMdtInviteRoute,
  $patientAppointmentChatRoute,
  $doctorAppointmentChatRoute,
  $patientAppLockRoute,
  $patientCreatePinRoute,
  $patientLockAfterRoute,
  $doctorAppLockRoute,
  $doctorCreatePinRoute,
  $doctorLockAfterRoute,
  $pathologistAppLockRoute,
  $pathologistCreatePinRoute,
  $pathologistLockAfterRoute,
];

RouteBase get $decisionRoute => GoRouteData.$route(
  path: '/decision',
  hasOverriddenOnExit: false,
  factory: $DecisionRoute._fromState,
);

mixin $DecisionRoute on GoRouteData {
  static DecisionRoute _fromState(GoRouterState state) =>
      DecisionRoute(from: state.uri.queryParameters['from']);

  DecisionRoute get _self => this as DecisionRoute;

  @override
  String get location => GoRouteData.$location(
    '/decision',
    queryParams: {if (_self.from != null) 'from': _self.from},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $updateRoute => GoRouteData.$route(
  path: '/update',
  hasOverriddenOnExit: false,
  factory: $UpdateRoute._fromState,
);

mixin $UpdateRoute on GoRouteData {
  static UpdateRoute _fromState(GoRouterState state) => const UpdateRoute();

  @override
  String get location => GoRouteData.$location('/update');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $languageRoute => GoRouteData.$route(
  path: '/language',
  hasOverriddenOnExit: false,
  factory: $LanguageRoute._fromState,
);

mixin $LanguageRoute on GoRouteData {
  static LanguageRoute _fromState(GoRouterState state) => const LanguageRoute();

  @override
  String get location => GoRouteData.$location('/language');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $introRoute => GoRouteData.$route(
  path: '/intro',
  hasOverriddenOnExit: false,
  factory: $IntroRoute._fromState,
);

mixin $IntroRoute on GoRouteData {
  static IntroRoute _fromState(GoRouterState state) => const IntroRoute();

  @override
  String get location => GoRouteData.$location('/intro');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $getStartedRoute => GoRouteData.$route(
  path: '/get-started',
  hasOverriddenOnExit: false,
  factory: $GetStartedRoute._fromState,
);

mixin $GetStartedRoute on GoRouteData {
  static GetStartedRoute _fromState(GoRouterState state) =>
      const GetStartedRoute();

  @override
  String get location => GoRouteData.$location('/get-started');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $signInRoute => GoRouteData.$route(
  path: '/sign-in',
  hasOverriddenOnExit: false,
  factory: $SignInRoute._fromState,
);

mixin $SignInRoute on GoRouteData {
  static SignInRoute _fromState(GoRouterState state) => const SignInRoute();

  @override
  String get location => GoRouteData.$location('/sign-in');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $resetPasswordRoute => GoRouteData.$route(
  path: '/reset-password',
  hasOverriddenOnExit: false,
  factory: $ResetPasswordRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'sent',
      hasOverriddenOnExit: false,
      factory: $ResetPasswordSentRoute._fromState,
    ),
  ],
);

mixin $ResetPasswordRoute on GoRouteData {
  static ResetPasswordRoute _fromState(GoRouterState state) =>
      const ResetPasswordRoute();

  @override
  String get location => GoRouteData.$location('/reset-password');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ResetPasswordSentRoute on GoRouteData {
  static ResetPasswordSentRoute _fromState(GoRouterState state) =>
      const ResetPasswordSentRoute();

  @override
  String get location => GoRouteData.$location('/reset-password/sent');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $signUpRoleRoute => GoRouteData.$route(
  path: '/sign-up',
  hasOverriddenOnExit: false,
  factory: $SignUpRoleRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'patient/name',
      hasOverriddenOnExit: false,
      factory: $PatientNameRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'patient/account',
      hasOverriddenOnExit: false,
      factory: $PatientAccountRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'patient/phone',
      hasOverriddenOnExit: false,
      factory: $PatientPhoneRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'patient/area',
      hasOverriddenOnExit: false,
      factory: $PatientAreaRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'practitioner/details',
      hasOverriddenOnExit: false,
      factory: $PractitionerDetailsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'practitioner/licence',
      hasOverriddenOnExit: false,
      factory: $PractitionerLicenceRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'practitioner/facility',
      hasOverriddenOnExit: false,
      factory: $PractitionerFacilityRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'practitioner/review',
      hasOverriddenOnExit: false,
      factory: $PractitionerReviewRoute._fromState,
    ),
  ],
);

mixin $SignUpRoleRoute on GoRouteData {
  static SignUpRoleRoute _fromState(GoRouterState state) =>
      const SignUpRoleRoute();

  @override
  String get location => GoRouteData.$location('/sign-up');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PatientNameRoute on GoRouteData {
  static PatientNameRoute _fromState(GoRouterState state) =>
      const PatientNameRoute();

  @override
  String get location => GoRouteData.$location('/sign-up/patient/name');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PatientAccountRoute on GoRouteData {
  static PatientAccountRoute _fromState(GoRouterState state) =>
      const PatientAccountRoute();

  @override
  String get location => GoRouteData.$location('/sign-up/patient/account');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PatientPhoneRoute on GoRouteData {
  static PatientPhoneRoute _fromState(GoRouterState state) =>
      const PatientPhoneRoute();

  @override
  String get location => GoRouteData.$location('/sign-up/patient/phone');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PatientAreaRoute on GoRouteData {
  static PatientAreaRoute _fromState(GoRouterState state) =>
      const PatientAreaRoute();

  @override
  String get location => GoRouteData.$location('/sign-up/patient/area');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PractitionerDetailsRoute on GoRouteData {
  static PractitionerDetailsRoute _fromState(GoRouterState state) =>
      const PractitionerDetailsRoute();

  @override
  String get location => GoRouteData.$location('/sign-up/practitioner/details');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PractitionerLicenceRoute on GoRouteData {
  static PractitionerLicenceRoute _fromState(GoRouterState state) =>
      const PractitionerLicenceRoute();

  @override
  String get location => GoRouteData.$location('/sign-up/practitioner/licence');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PractitionerFacilityRoute on GoRouteData {
  static PractitionerFacilityRoute _fromState(GoRouterState state) =>
      const PractitionerFacilityRoute();

  @override
  String get location =>
      GoRouteData.$location('/sign-up/practitioner/facility');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PractitionerReviewRoute on GoRouteData {
  static PractitionerReviewRoute _fromState(GoRouterState state) =>
      const PractitionerReviewRoute();

  @override
  String get location => GoRouteData.$location('/sign-up/practitioner/review');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientAllSetRoute => GoRouteData.$route(
  path: '/account/all-set',
  hasOverriddenOnExit: false,
  factory: $PatientAllSetRoute._fromState,
);

mixin $PatientAllSetRoute on GoRouteData {
  static PatientAllSetRoute _fromState(GoRouterState state) =>
      const PatientAllSetRoute();

  @override
  String get location => GoRouteData.$location('/account/all-set');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $clinicRecordRoute => GoRouteData.$route(
  path: '/account/clinic-record',
  hasOverriddenOnExit: false,
  factory: $ClinicRecordRoute._fromState,
);

mixin $ClinicRecordRoute on GoRouteData {
  static ClinicRecordRoute _fromState(GoRouterState state) =>
      const ClinicRecordRoute();

  @override
  String get location => GoRouteData.$location('/account/clinic-record');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $verifyEmailRoute => GoRouteData.$route(
  path: '/account/verify-email',
  hasOverriddenOnExit: false,
  factory: $VerifyEmailRoute._fromState,
);

mixin $VerifyEmailRoute on GoRouteData {
  static VerifyEmailRoute _fromState(GoRouterState state) =>
      const VerifyEmailRoute();

  @override
  String get location => GoRouteData.$location('/account/verify-email');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pendingVerificationRoute => GoRouteData.$route(
  path: '/account/pending',
  hasOverriddenOnExit: false,
  factory: $PendingVerificationRoute._fromState,
);

mixin $PendingVerificationRoute on GoRouteData {
  static PendingVerificationRoute _fromState(GoRouterState state) =>
      const PendingVerificationRoute();

  @override
  String get location => GoRouteData.$location('/account/pending');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $verifiedRoute => GoRouteData.$route(
  path: '/account/verified',
  hasOverriddenOnExit: false,
  factory: $VerifiedRoute._fromState,
);

mixin $VerifiedRoute on GoRouteData {
  static VerifiedRoute _fromState(GoRouterState state) => const VerifiedRoute();

  @override
  String get location => GoRouteData.$location('/account/verified');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientShellRoute => StatefulShellRouteData.$route(
  factory: $PatientShellRouteExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/patient',
          hasOverriddenOnExit: false,
          factory: $PatientHomeRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/patient/appointments',
          hasOverriddenOnExit: false,
          factory: $PatientAppointmentsRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/patient/results',
          hasOverriddenOnExit: false,
          factory: $PatientResultsRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/patient/profile',
          hasOverriddenOnExit: false,
          factory: $PatientProfileRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $PatientShellRouteExtension on PatientShellRoute {
  static PatientShellRoute _fromState(GoRouterState state) =>
      const PatientShellRoute();
}

mixin $PatientHomeRoute on GoRouteData {
  static PatientHomeRoute _fromState(GoRouterState state) =>
      const PatientHomeRoute();

  @override
  String get location => GoRouteData.$location('/patient');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PatientAppointmentsRoute on GoRouteData {
  static PatientAppointmentsRoute _fromState(GoRouterState state) =>
      const PatientAppointmentsRoute();

  @override
  String get location => GoRouteData.$location('/patient/appointments');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PatientResultsRoute on GoRouteData {
  static PatientResultsRoute _fromState(GoRouterState state) =>
      const PatientResultsRoute();

  @override
  String get location => GoRouteData.$location('/patient/results');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PatientProfileRoute on GoRouteData {
  static PatientProfileRoute _fromState(GoRouterState state) =>
      const PatientProfileRoute();

  @override
  String get location => GoRouteData.$location('/patient/profile');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorShellRoute => StatefulShellRouteData.$route(
  factory: $DoctorShellRouteExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/doctor',
          hasOverriddenOnExit: false,
          factory: $DoctorHomeRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/doctor/cases',
          hasOverriddenOnExit: false,
          factory: $DoctorCasesRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/doctor/mdt',
          hasOverriddenOnExit: false,
          factory: $DoctorMdtRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/doctor/profile',
          hasOverriddenOnExit: false,
          factory: $DoctorProfileRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $DoctorShellRouteExtension on DoctorShellRoute {
  static DoctorShellRoute _fromState(GoRouterState state) =>
      const DoctorShellRoute();
}

mixin $DoctorHomeRoute on GoRouteData {
  static DoctorHomeRoute _fromState(GoRouterState state) =>
      const DoctorHomeRoute();

  @override
  String get location => GoRouteData.$location('/doctor');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $DoctorCasesRoute on GoRouteData {
  static DoctorCasesRoute _fromState(GoRouterState state) =>
      const DoctorCasesRoute();

  @override
  String get location => GoRouteData.$location('/doctor/cases');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $DoctorMdtRoute on GoRouteData {
  static DoctorMdtRoute _fromState(GoRouterState state) =>
      const DoctorMdtRoute();

  @override
  String get location => GoRouteData.$location('/doctor/mdt');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $DoctorProfileRoute on GoRouteData {
  static DoctorProfileRoute _fromState(GoRouterState state) =>
      const DoctorProfileRoute();

  @override
  String get location => GoRouteData.$location('/doctor/profile');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pathologistShellRoute => StatefulShellRouteData.$route(
  factory: $PathologistShellRouteExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/pathologist',
          hasOverriddenOnExit: false,
          factory: $PathologistHomeRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/pathologist/signed',
          hasOverriddenOnExit: false,
          factory: $PathologistSignedRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/pathologist/mdt',
          hasOverriddenOnExit: false,
          factory: $PathologistMdtRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/pathologist/profile',
          hasOverriddenOnExit: false,
          factory: $PathologistProfileRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $PathologistShellRouteExtension on PathologistShellRoute {
  static PathologistShellRoute _fromState(GoRouterState state) =>
      const PathologistShellRoute();
}

mixin $PathologistHomeRoute on GoRouteData {
  static PathologistHomeRoute _fromState(GoRouterState state) =>
      const PathologistHomeRoute();

  @override
  String get location => GoRouteData.$location('/pathologist');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PathologistSignedRoute on GoRouteData {
  static PathologistSignedRoute _fromState(GoRouterState state) =>
      const PathologistSignedRoute();

  @override
  String get location => GoRouteData.$location('/pathologist/signed');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PathologistMdtRoute on GoRouteData {
  static PathologistMdtRoute _fromState(GoRouterState state) =>
      const PathologistMdtRoute();

  @override
  String get location => GoRouteData.$location('/pathologist/mdt');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PathologistProfileRoute on GoRouteData {
  static PathologistProfileRoute _fromState(GoRouterState state) =>
      const PathologistProfileRoute();

  @override
  String get location => GoRouteData.$location('/pathologist/profile');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientNotificationsRoute => GoRouteData.$route(
  path: '/patient/notifications',
  hasOverriddenOnExit: false,
  factory: $PatientNotificationsRoute._fromState,
);

mixin $PatientNotificationsRoute on GoRouteData {
  static PatientNotificationsRoute _fromState(GoRouterState state) =>
      const PatientNotificationsRoute();

  @override
  String get location => GoRouteData.$location('/patient/notifications');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $findDoctorRoute => GoRouteData.$route(
  path: '/patient/doctors',
  hasOverriddenOnExit: false,
  factory: $FindDoctorRoute._fromState,
);

mixin $FindDoctorRoute on GoRouteData {
  static FindDoctorRoute _fromState(GoRouterState state) =>
      const FindDoctorRoute();

  @override
  String get location => GoRouteData.$location('/patient/doctors');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $practitionerProfileRoute => GoRouteData.$route(
  path: '/patient/doctors/:doctorUid',
  hasOverriddenOnExit: false,
  factory: $PractitionerProfileRoute._fromState,
);

mixin $PractitionerProfileRoute on GoRouteData {
  static PractitionerProfileRoute _fromState(GoRouterState state) =>
      PractitionerProfileRoute(doctorUid: state.pathParameters['doctorUid']!);

  PractitionerProfileRoute get _self => this as PractitionerProfileRoute;

  @override
  String get location => GoRouteData.$location(
    '/patient/doctors/${Uri.encodeComponent(_self.doctorUid)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientAppointmentRoute => GoRouteData.$route(
  path: '/patient/appointment/:appointmentUid',
  hasOverriddenOnExit: false,
  factory: $PatientAppointmentRoute._fromState,
);

mixin $PatientAppointmentRoute on GoRouteData {
  static PatientAppointmentRoute _fromState(GoRouterState state) =>
      PatientAppointmentRoute(
        appointmentUid: state.pathParameters['appointmentUid']!,
      );

  PatientAppointmentRoute get _self => this as PatientAppointmentRoute;

  @override
  String get location => GoRouteData.$location(
    '/patient/appointment/${Uri.encodeComponent(_self.appointmentUid)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientCalendarRoute => GoRouteData.$route(
  path: '/patient/calendar',
  hasOverriddenOnExit: false,
  factory: $PatientCalendarRoute._fromState,
);

mixin $PatientCalendarRoute on GoRouteData {
  static PatientCalendarRoute _fromState(GoRouterState state) =>
      const PatientCalendarRoute();

  @override
  String get location => GoRouteData.$location('/patient/calendar');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientProfileDetailsRoute => GoRouteData.$route(
  path: '/patient/profile/details',
  hasOverriddenOnExit: false,
  factory: $PatientProfileDetailsRoute._fromState,
);

mixin $PatientProfileDetailsRoute on GoRouteData {
  static PatientProfileDetailsRoute _fromState(GoRouterState state) =>
      const PatientProfileDetailsRoute();

  @override
  String get location => GoRouteData.$location('/patient/profile/details');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientEditProfileRoute => GoRouteData.$route(
  path: '/patient/profile/edit',
  hasOverriddenOnExit: false,
  factory: $PatientEditProfileRoute._fromState,
);

mixin $PatientEditProfileRoute on GoRouteData {
  static PatientEditProfileRoute _fromState(GoRouterState state) =>
      const PatientEditProfileRoute();

  @override
  String get location => GoRouteData.$location('/patient/profile/edit');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientProfileAreaRoute => GoRouteData.$route(
  path: '/patient/profile/area',
  hasOverriddenOnExit: false,
  factory: $PatientProfileAreaRoute._fromState,
);

mixin $PatientProfileAreaRoute on GoRouteData {
  static PatientProfileAreaRoute _fromState(GoRouterState state) =>
      const PatientProfileAreaRoute();

  @override
  String get location => GoRouteData.$location('/patient/profile/area');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientProfileLanguageRoute => GoRouteData.$route(
  path: '/patient/profile/language',
  hasOverriddenOnExit: false,
  factory: $PatientProfileLanguageRoute._fromState,
);

mixin $PatientProfileLanguageRoute on GoRouteData {
  static PatientProfileLanguageRoute _fromState(GoRouterState state) =>
      const PatientProfileLanguageRoute();

  @override
  String get location => GoRouteData.$location('/patient/profile/language');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientProfileThemeRoute => GoRouteData.$route(
  path: '/patient/profile/theme',
  hasOverriddenOnExit: false,
  factory: $PatientProfileThemeRoute._fromState,
);

mixin $PatientProfileThemeRoute on GoRouteData {
  static PatientProfileThemeRoute _fromState(GoRouterState state) =>
      const PatientProfileThemeRoute();

  @override
  String get location => GoRouteData.$location('/patient/profile/theme');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientProfileNotificationsRoute => GoRouteData.$route(
  path: '/patient/profile/notifications',
  hasOverriddenOnExit: false,
  factory: $PatientProfileNotificationsRoute._fromState,
);

mixin $PatientProfileNotificationsRoute on GoRouteData {
  static PatientProfileNotificationsRoute _fromState(GoRouterState state) =>
      const PatientProfileNotificationsRoute();

  @override
  String get location =>
      GoRouteData.$location('/patient/profile/notifications');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientPrivacyRoute => GoRouteData.$route(
  path: '/patient/profile/privacy',
  hasOverriddenOnExit: false,
  factory: $PatientPrivacyRoute._fromState,
);

mixin $PatientPrivacyRoute on GoRouteData {
  static PatientPrivacyRoute _fromState(GoRouterState state) =>
      const PatientPrivacyRoute();

  @override
  String get location => GoRouteData.$location('/patient/profile/privacy');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientPrivacyPolicyRoute => GoRouteData.$route(
  path: '/patient/profile/privacy/policy',
  hasOverriddenOnExit: false,
  factory: $PatientPrivacyPolicyRoute._fromState,
);

mixin $PatientPrivacyPolicyRoute on GoRouteData {
  static PatientPrivacyPolicyRoute _fromState(GoRouterState state) =>
      const PatientPrivacyPolicyRoute();

  @override
  String get location =>
      GoRouteData.$location('/patient/profile/privacy/policy');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientHelpRoute => GoRouteData.$route(
  path: '/patient/profile/help',
  hasOverriddenOnExit: false,
  factory: $PatientHelpRoute._fromState,
);

mixin $PatientHelpRoute on GoRouteData {
  static PatientHelpRoute _fromState(GoRouterState state) =>
      const PatientHelpRoute();

  @override
  String get location => GoRouteData.$location('/patient/profile/help');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $bookedRoute => GoRouteData.$route(
  path: '/patient/appointment/:appointmentUid/booked',
  hasOverriddenOnExit: false,
  factory: $BookedRoute._fromState,
);

mixin $BookedRoute on GoRouteData {
  static BookedRoute _fromState(GoRouterState state) =>
      BookedRoute(appointmentUid: state.pathParameters['appointmentUid']!);

  BookedRoute get _self => this as BookedRoute;

  @override
  String get location => GoRouteData.$location(
    '/patient/appointment/${Uri.encodeComponent(_self.appointmentUid)}/booked',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientResultRoute => GoRouteData.$route(
  path: '/patient/result/:caseUid',
  hasOverriddenOnExit: false,
  factory: $PatientResultRoute._fromState,
);

mixin $PatientResultRoute on GoRouteData {
  static PatientResultRoute _fromState(GoRouterState state) =>
      PatientResultRoute(caseUid: state.pathParameters['caseUid']!);

  PatientResultRoute get _self => this as PatientResultRoute;

  @override
  String get location => GoRouteData.$location(
    '/patient/result/${Uri.encodeComponent(_self.caseUid)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $explainedResultRoute => GoRouteData.$route(
  path: '/patient/result/:caseUid/explained',
  hasOverriddenOnExit: false,
  factory: $ExplainedResultRoute._fromState,
);

mixin $ExplainedResultRoute on GoRouteData {
  static ExplainedResultRoute _fromState(GoRouterState state) =>
      ExplainedResultRoute(caseUid: state.pathParameters['caseUid']!);

  ExplainedResultRoute get _self => this as ExplainedResultRoute;

  @override
  String get location => GoRouteData.$location(
    '/patient/result/${Uri.encodeComponent(_self.caseUid)}/explained',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientCaseHistoryRoute => GoRouteData.$route(
  path: '/patient/result/:caseUid/history',
  hasOverriddenOnExit: false,
  factory: $PatientCaseHistoryRoute._fromState,
);

mixin $PatientCaseHistoryRoute on GoRouteData {
  static PatientCaseHistoryRoute _fromState(GoRouterState state) =>
      PatientCaseHistoryRoute(caseUid: state.pathParameters['caseUid']!);

  PatientCaseHistoryRoute get _self => this as PatientCaseHistoryRoute;

  @override
  String get location => GoRouteData.$location(
    '/patient/result/${Uri.encodeComponent(_self.caseUid)}/history',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $shareReportRoute => GoRouteData.$route(
  path: '/patient/result/:caseUid/share',
  hasOverriddenOnExit: false,
  factory: $ShareReportRoute._fromState,
);

mixin $ShareReportRoute on GoRouteData {
  static ShareReportRoute _fromState(GoRouterState state) =>
      ShareReportRoute(caseUid: state.pathParameters['caseUid']!);

  ShareReportRoute get _self => this as ShareReportRoute;

  @override
  String get location => GoRouteData.$location(
    '/patient/result/${Uri.encodeComponent(_self.caseUid)}/share',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $shareDoneRoute => GoRouteData.$route(
  path: '/patient/result/:caseUid/share/done',
  hasOverriddenOnExit: false,
  factory: $ShareDoneRoute._fromState,
);

mixin $ShareDoneRoute on GoRouteData {
  static ShareDoneRoute _fromState(GoRouterState state) =>
      ShareDoneRoute(caseUid: state.pathParameters['caseUid']!);

  ShareDoneRoute get _self => this as ShareDoneRoute;

  @override
  String get location => GoRouteData.$location(
    '/patient/result/${Uri.encodeComponent(_self.caseUid)}/share/done',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $whoCanSeeRoute => GoRouteData.$route(
  path: '/patient/result/:caseUid/who-can-see',
  hasOverriddenOnExit: false,
  factory: $WhoCanSeeRoute._fromState,
);

mixin $WhoCanSeeRoute on GoRouteData {
  static WhoCanSeeRoute _fromState(GoRouterState state) =>
      WhoCanSeeRoute(caseUid: state.pathParameters['caseUid']!);

  WhoCanSeeRoute get _self => this as WhoCanSeeRoute;

  @override
  String get location => GoRouteData.$location(
    '/patient/result/${Uri.encodeComponent(_self.caseUid)}/who-can-see',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $sharedReportsRoute => GoRouteData.$route(
  path: '/patient/shares',
  hasOverriddenOnExit: false,
  factory: $SharedReportsRoute._fromState,
);

mixin $SharedReportsRoute on GoRouteData {
  static SharedReportsRoute _fromState(GoRouterState state) =>
      const SharedReportsRoute();

  @override
  String get location => GoRouteData.$location('/patient/shares');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $healthNoticeRoute => GoRouteData.$route(
  path: '/patient/notice/:alertUid',
  hasOverriddenOnExit: false,
  factory: $HealthNoticeRoute._fromState,
);

mixin $HealthNoticeRoute on GoRouteData {
  static HealthNoticeRoute _fromState(GoRouterState state) =>
      HealthNoticeRoute(alertUid: state.pathParameters['alertUid']!);

  HealthNoticeRoute get _self => this as HealthNoticeRoute;

  @override
  String get location => GoRouteData.$location(
    '/patient/notice/${Uri.encodeComponent(_self.alertUid)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorNotificationsRoute => GoRouteData.$route(
  path: '/doctor/notifications',
  hasOverriddenOnExit: false,
  factory: $DoctorNotificationsRoute._fromState,
);

mixin $DoctorNotificationsRoute on GoRouteData {
  static DoctorNotificationsRoute _fromState(GoRouterState state) =>
      const DoctorNotificationsRoute();

  @override
  String get location => GoRouteData.$location('/doctor/notifications');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $reportsReadyRoute => GoRouteData.$route(
  path: '/doctor/reports-ready',
  hasOverriddenOnExit: false,
  factory: $ReportsReadyRoute._fromState,
);

mixin $ReportsReadyRoute on GoRouteData {
  static ReportsReadyRoute _fromState(GoRouterState state) =>
      const ReportsReadyRoute();

  @override
  String get location => GoRouteData.$location('/doctor/reports-ready');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $bookingRequestsRoute => GoRouteData.$route(
  path: '/doctor/booking-requests',
  hasOverriddenOnExit: false,
  factory: $BookingRequestsRoute._fromState,
);

mixin $BookingRequestsRoute on GoRouteData {
  static BookingRequestsRoute _fromState(GoRouterState state) =>
      const BookingRequestsRoute();

  @override
  String get location => GoRouteData.$location('/doctor/booking-requests');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorAppointmentRoute => GoRouteData.$route(
  path: '/doctor/appointment/:appointmentUid',
  hasOverriddenOnExit: false,
  factory: $DoctorAppointmentRoute._fromState,
);

mixin $DoctorAppointmentRoute on GoRouteData {
  static DoctorAppointmentRoute _fromState(GoRouterState state) =>
      DoctorAppointmentRoute(
        appointmentUid: state.pathParameters['appointmentUid']!,
      );

  DoctorAppointmentRoute get _self => this as DoctorAppointmentRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/appointment/${Uri.encodeComponent(_self.appointmentUid)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorCalendarRoute => GoRouteData.$route(
  path: '/doctor/calendar',
  hasOverriddenOnExit: false,
  factory: $DoctorCalendarRoute._fromState,
);

mixin $DoctorCalendarRoute on GoRouteData {
  static DoctorCalendarRoute _fromState(GoRouterState state) =>
      const DoctorCalendarRoute();

  @override
  String get location => GoRouteData.$location('/doctor/calendar');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorProfileDetailsRoute => GoRouteData.$route(
  path: '/doctor/profile/details',
  hasOverriddenOnExit: false,
  factory: $DoctorProfileDetailsRoute._fromState,
);

mixin $DoctorProfileDetailsRoute on GoRouteData {
  static DoctorProfileDetailsRoute _fromState(GoRouterState state) =>
      const DoctorProfileDetailsRoute();

  @override
  String get location => GoRouteData.$location('/doctor/profile/details');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorClinicHoursRoute => GoRouteData.$route(
  path: '/doctor/profile/hours',
  hasOverriddenOnExit: false,
  factory: $DoctorClinicHoursRoute._fromState,
);

mixin $DoctorClinicHoursRoute on GoRouteData {
  static DoctorClinicHoursRoute _fromState(GoRouterState state) =>
      const DoctorClinicHoursRoute();

  @override
  String get location => GoRouteData.$location('/doctor/profile/hours');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorProfileLanguageRoute => GoRouteData.$route(
  path: '/doctor/profile/language',
  hasOverriddenOnExit: false,
  factory: $DoctorProfileLanguageRoute._fromState,
);

mixin $DoctorProfileLanguageRoute on GoRouteData {
  static DoctorProfileLanguageRoute _fromState(GoRouterState state) =>
      const DoctorProfileLanguageRoute();

  @override
  String get location => GoRouteData.$location('/doctor/profile/language');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorProfileThemeRoute => GoRouteData.$route(
  path: '/doctor/profile/theme',
  hasOverriddenOnExit: false,
  factory: $DoctorProfileThemeRoute._fromState,
);

mixin $DoctorProfileThemeRoute on GoRouteData {
  static DoctorProfileThemeRoute _fromState(GoRouterState state) =>
      const DoctorProfileThemeRoute();

  @override
  String get location => GoRouteData.$location('/doctor/profile/theme');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorProfileNotificationsRoute => GoRouteData.$route(
  path: '/doctor/profile/notifications',
  hasOverriddenOnExit: false,
  factory: $DoctorProfileNotificationsRoute._fromState,
);

mixin $DoctorProfileNotificationsRoute on GoRouteData {
  static DoctorProfileNotificationsRoute _fromState(GoRouterState state) =>
      const DoctorProfileNotificationsRoute();

  @override
  String get location => GoRouteData.$location('/doctor/profile/notifications');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorPrivacyRoute => GoRouteData.$route(
  path: '/doctor/profile/privacy',
  hasOverriddenOnExit: false,
  factory: $DoctorPrivacyRoute._fromState,
);

mixin $DoctorPrivacyRoute on GoRouteData {
  static DoctorPrivacyRoute _fromState(GoRouterState state) =>
      const DoctorPrivacyRoute();

  @override
  String get location => GoRouteData.$location('/doctor/profile/privacy');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorPrivacyPolicyRoute => GoRouteData.$route(
  path: '/doctor/profile/privacy/policy',
  hasOverriddenOnExit: false,
  factory: $DoctorPrivacyPolicyRoute._fromState,
);

mixin $DoctorPrivacyPolicyRoute on GoRouteData {
  static DoctorPrivacyPolicyRoute _fromState(GoRouterState state) =>
      const DoctorPrivacyPolicyRoute();

  @override
  String get location =>
      GoRouteData.$location('/doctor/profile/privacy/policy');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorHelpRoute => GoRouteData.$route(
  path: '/doctor/profile/help',
  hasOverriddenOnExit: false,
  factory: $DoctorHelpRoute._fromState,
);

mixin $DoctorHelpRoute on GoRouteData {
  static DoctorHelpRoute _fromState(GoRouterState state) =>
      const DoctorHelpRoute();

  @override
  String get location => GoRouteData.$location('/doctor/profile/help');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $orderRoute => GoRouteData.$route(
  path: '/doctor/order',
  hasOverriddenOnExit: false,
  factory: $OrderRoute._fromState,
);

mixin $OrderRoute on GoRouteData {
  static OrderRoute _fromState(GoRouterState state) => OrderRoute(
    appointmentUid: state.uri.queryParameters['appointment-uid'] ?? '',
    caseUid: state.uri.queryParameters['case-uid'] ?? '',
  );

  OrderRoute get _self => this as OrderRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/order',
    queryParams: {
      if (_self.appointmentUid != '') 'appointment-uid': _self.appointmentUid,
      if (_self.caseUid != '') 'case-uid': _self.caseUid,
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $orderSentRoute => GoRouteData.$route(
  path: '/doctor/case/:caseUid/sent',
  hasOverriddenOnExit: false,
  factory: $OrderSentRoute._fromState,
);

mixin $OrderSentRoute on GoRouteData {
  static OrderSentRoute _fromState(GoRouterState state) =>
      OrderSentRoute(caseUid: state.pathParameters['caseUid']!);

  OrderSentRoute get _self => this as OrderSentRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/case/${Uri.encodeComponent(_self.caseUid)}/sent',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $mohProtocolRoute => GoRouteData.$route(
  path: '/doctor/protocol/:protocolId',
  hasOverriddenOnExit: false,
  factory: $MohProtocolRoute._fromState,
);

mixin $MohProtocolRoute on GoRouteData {
  static MohProtocolRoute _fromState(GoRouterState state) =>
      MohProtocolRoute(protocolId: state.pathParameters['protocolId']!);

  MohProtocolRoute get _self => this as MohProtocolRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/protocol/${Uri.encodeComponent(_self.protocolId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorCaseRoute => GoRouteData.$route(
  path: '/doctor/case/:caseUid',
  hasOverriddenOnExit: false,
  factory: $DoctorCaseRoute._fromState,
);

mixin $DoctorCaseRoute on GoRouteData {
  static DoctorCaseRoute _fromState(GoRouterState state) =>
      DoctorCaseRoute(caseUid: state.pathParameters['caseUid']!);

  DoctorCaseRoute get _self => this as DoctorCaseRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/case/${Uri.encodeComponent(_self.caseUid)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorCaseHistoryRoute => GoRouteData.$route(
  path: '/doctor/case/:caseUid/history',
  hasOverriddenOnExit: false,
  factory: $DoctorCaseHistoryRoute._fromState,
);

mixin $DoctorCaseHistoryRoute on GoRouteData {
  static DoctorCaseHistoryRoute _fromState(GoRouterState state) =>
      DoctorCaseHistoryRoute(caseUid: state.pathParameters['caseUid']!);

  DoctorCaseHistoryRoute get _self => this as DoctorCaseHistoryRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/case/${Uri.encodeComponent(_self.caseUid)}/history',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorEnterShareCodeRoute => GoRouteData.$route(
  path: '/doctor/share/:shareUid',
  hasOverriddenOnExit: false,
  factory: $DoctorEnterShareCodeRoute._fromState,
);

mixin $DoctorEnterShareCodeRoute on GoRouteData {
  static DoctorEnterShareCodeRoute _fromState(GoRouterState state) =>
      DoctorEnterShareCodeRoute(shareUid: state.pathParameters['shareUid']!);

  DoctorEnterShareCodeRoute get _self => this as DoctorEnterShareCodeRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/share/${Uri.encodeComponent(_self.shareUid)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorReportRoute => GoRouteData.$route(
  path: '/doctor/case/:caseUid/report',
  hasOverriddenOnExit: false,
  factory: $DoctorReportRoute._fromState,
);

mixin $DoctorReportRoute on GoRouteData {
  static DoctorReportRoute _fromState(GoRouterState state) =>
      DoctorReportRoute(caseUid: state.pathParameters['caseUid']!);

  DoctorReportRoute get _self => this as DoctorReportRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/case/${Uri.encodeComponent(_self.caseUid)}/report',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $fullReportRoute => GoRouteData.$route(
  path: '/doctor/case/:caseUid/report/full',
  hasOverriddenOnExit: false,
  factory: $FullReportRoute._fromState,
);

mixin $FullReportRoute on GoRouteData {
  static FullReportRoute _fromState(GoRouterState state) =>
      FullReportRoute(caseUid: state.pathParameters['caseUid']!);

  FullReportRoute get _self => this as FullReportRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/case/${Uri.encodeComponent(_self.caseUid)}/report/full',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $alertReviewRoute => GoRouteData.$route(
  path: '/doctor/alert/:alertUid',
  hasOverriddenOnExit: false,
  factory: $AlertReviewRoute._fromState,
);

mixin $AlertReviewRoute on GoRouteData {
  static AlertReviewRoute _fromState(GoRouterState state) =>
      AlertReviewRoute(alertUid: state.pathParameters['alertUid']!);

  AlertReviewRoute get _self => this as AlertReviewRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/alert/${Uri.encodeComponent(_self.alertUid)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $alertSentRoute => GoRouteData.$route(
  path: '/doctor/alert/:alertUid/sent',
  hasOverriddenOnExit: false,
  factory: $AlertSentRoute._fromState,
);

mixin $AlertSentRoute on GoRouteData {
  static AlertSentRoute _fromState(GoRouterState state) =>
      AlertSentRoute(alertUid: state.pathParameters['alertUid']!);

  AlertSentRoute get _self => this as AlertSentRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/alert/${Uri.encodeComponent(_self.alertUid)}/sent',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pathologistNotificationsRoute => GoRouteData.$route(
  path: '/pathologist/notifications',
  hasOverriddenOnExit: false,
  factory: $PathologistNotificationsRoute._fromState,
);

mixin $PathologistNotificationsRoute on GoRouteData {
  static PathologistNotificationsRoute _fromState(GoRouterState state) =>
      const PathologistNotificationsRoute();

  @override
  String get location => GoRouteData.$location('/pathologist/notifications');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pathologistProfileDetailsRoute => GoRouteData.$route(
  path: '/pathologist/profile/details',
  hasOverriddenOnExit: false,
  factory: $PathologistProfileDetailsRoute._fromState,
);

mixin $PathologistProfileDetailsRoute on GoRouteData {
  static PathologistProfileDetailsRoute _fromState(GoRouterState state) =>
      const PathologistProfileDetailsRoute();

  @override
  String get location => GoRouteData.$location('/pathologist/profile/details');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pathologistProfileLanguageRoute => GoRouteData.$route(
  path: '/pathologist/profile/language',
  hasOverriddenOnExit: false,
  factory: $PathologistProfileLanguageRoute._fromState,
);

mixin $PathologistProfileLanguageRoute on GoRouteData {
  static PathologistProfileLanguageRoute _fromState(GoRouterState state) =>
      const PathologistProfileLanguageRoute();

  @override
  String get location => GoRouteData.$location('/pathologist/profile/language');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pathologistProfileThemeRoute => GoRouteData.$route(
  path: '/pathologist/profile/theme',
  hasOverriddenOnExit: false,
  factory: $PathologistProfileThemeRoute._fromState,
);

mixin $PathologistProfileThemeRoute on GoRouteData {
  static PathologistProfileThemeRoute _fromState(GoRouterState state) =>
      const PathologistProfileThemeRoute();

  @override
  String get location => GoRouteData.$location('/pathologist/profile/theme');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pathologistProfileNotificationsRoute => GoRouteData.$route(
  path: '/pathologist/profile/notifications',
  hasOverriddenOnExit: false,
  factory: $PathologistProfileNotificationsRoute._fromState,
);

mixin $PathologistProfileNotificationsRoute on GoRouteData {
  static PathologistProfileNotificationsRoute _fromState(GoRouterState state) =>
      const PathologistProfileNotificationsRoute();

  @override
  String get location =>
      GoRouteData.$location('/pathologist/profile/notifications');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pathologistPrivacyRoute => GoRouteData.$route(
  path: '/pathologist/profile/privacy',
  hasOverriddenOnExit: false,
  factory: $PathologistPrivacyRoute._fromState,
);

mixin $PathologistPrivacyRoute on GoRouteData {
  static PathologistPrivacyRoute _fromState(GoRouterState state) =>
      const PathologistPrivacyRoute();

  @override
  String get location => GoRouteData.$location('/pathologist/profile/privacy');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pathologistPrivacyPolicyRoute => GoRouteData.$route(
  path: '/pathologist/profile/privacy/policy',
  hasOverriddenOnExit: false,
  factory: $PathologistPrivacyPolicyRoute._fromState,
);

mixin $PathologistPrivacyPolicyRoute on GoRouteData {
  static PathologistPrivacyPolicyRoute _fromState(GoRouterState state) =>
      const PathologistPrivacyPolicyRoute();

  @override
  String get location =>
      GoRouteData.$location('/pathologist/profile/privacy/policy');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pathologistHelpRoute => GoRouteData.$route(
  path: '/pathologist/profile/help',
  hasOverriddenOnExit: false,
  factory: $PathologistHelpRoute._fromState,
);

mixin $PathologistHelpRoute on GoRouteData {
  static PathologistHelpRoute _fromState(GoRouterState state) =>
      const PathologistHelpRoute();

  @override
  String get location => GoRouteData.$location('/pathologist/profile/help');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $deskListRoute => GoRouteData.$route(
  path: '/pathologist/cases',
  hasOverriddenOnExit: false,
  factory: $DeskListRoute._fromState,
);

mixin $DeskListRoute on GoRouteData {
  static DeskListRoute _fromState(GoRouterState state) =>
      DeskListRoute(filter: state.uri.queryParameters['filter'] ?? 'all');

  DeskListRoute get _self => this as DeskListRoute;

  @override
  String get location => GoRouteData.$location(
    '/pathologist/cases',
    queryParams: {if (_self.filter != 'all') 'filter': _self.filter},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $deskSearchRoute => GoRouteData.$route(
  path: '/pathologist/search',
  hasOverriddenOnExit: false,
  factory: $DeskSearchRoute._fromState,
);

mixin $DeskSearchRoute on GoRouteData {
  static DeskSearchRoute _fromState(GoRouterState state) =>
      const DeskSearchRoute();

  @override
  String get location => GoRouteData.$location('/pathologist/search');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $caseWorkspaceRoute => GoRouteData.$route(
  path: '/pathologist/case/:caseUid',
  hasOverriddenOnExit: false,
  factory: $CaseWorkspaceRoute._fromState,
);

mixin $CaseWorkspaceRoute on GoRouteData {
  static CaseWorkspaceRoute _fromState(GoRouterState state) =>
      CaseWorkspaceRoute(caseUid: state.pathParameters['caseUid']!);

  CaseWorkspaceRoute get _self => this as CaseWorkspaceRoute;

  @override
  String get location => GoRouteData.$location(
    '/pathologist/case/${Uri.encodeComponent(_self.caseUid)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pathologistCaseHistoryRoute => GoRouteData.$route(
  path: '/pathologist/case/:caseUid/history',
  hasOverriddenOnExit: false,
  factory: $PathologistCaseHistoryRoute._fromState,
);

mixin $PathologistCaseHistoryRoute on GoRouteData {
  static PathologistCaseHistoryRoute _fromState(GoRouterState state) =>
      PathologistCaseHistoryRoute(caseUid: state.pathParameters['caseUid']!);

  PathologistCaseHistoryRoute get _self => this as PathologistCaseHistoryRoute;

  @override
  String get location => GoRouteData.$location(
    '/pathologist/case/${Uri.encodeComponent(_self.caseUid)}/history',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pathologistEnterShareCodeRoute => GoRouteData.$route(
  path: '/pathologist/share/:shareUid',
  hasOverriddenOnExit: false,
  factory: $PathologistEnterShareCodeRoute._fromState,
);

mixin $PathologistEnterShareCodeRoute on GoRouteData {
  static PathologistEnterShareCodeRoute _fromState(GoRouterState state) =>
      PathologistEnterShareCodeRoute(
        shareUid: state.pathParameters['shareUid']!,
      );

  PathologistEnterShareCodeRoute get _self =>
      this as PathologistEnterShareCodeRoute;

  @override
  String get location => GoRouteData.$location(
    '/pathologist/share/${Uri.encodeComponent(_self.shareUid)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $tilesRoute => GoRouteData.$route(
  path: '/pathologist/case/:caseUid/tiles',
  hasOverriddenOnExit: false,
  factory: $TilesRoute._fromState,
);

mixin $TilesRoute on GoRouteData {
  static TilesRoute _fromState(GoRouterState state) =>
      TilesRoute(caseUid: state.pathParameters['caseUid']!);

  TilesRoute get _self => this as TilesRoute;

  @override
  String get location => GoRouteData.$location(
    '/pathologist/case/${Uri.encodeComponent(_self.caseUid)}/tiles',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $compareRoute => GoRouteData.$route(
  path: '/pathologist/case/:caseUid/compare',
  hasOverriddenOnExit: false,
  factory: $CompareRoute._fromState,
);

mixin $CompareRoute on GoRouteData {
  static CompareRoute _fromState(GoRouterState state) =>
      CompareRoute(caseUid: state.pathParameters['caseUid']!);

  CompareRoute get _self => this as CompareRoute;

  @override
  String get location => GoRouteData.$location(
    '/pathologist/case/${Uri.encodeComponent(_self.caseUid)}/compare',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorMdtNewRoute => GoRouteData.$route(
  path: '/doctor/mdt/new',
  hasOverriddenOnExit: false,
  factory: $DoctorMdtNewRoute._fromState,
);

mixin $DoctorMdtNewRoute on GoRouteData {
  static DoctorMdtNewRoute _fromState(GoRouterState state) =>
      DoctorMdtNewRoute(caseUid: state.uri.queryParameters['case-uid']);

  DoctorMdtNewRoute get _self => this as DoctorMdtNewRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/mdt/new',
    queryParams: {if (_self.caseUid != null) 'case-uid': _self.caseUid},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorMdtConsultRoute => GoRouteData.$route(
  path: '/doctor/mdt/:conversationUid',
  hasOverriddenOnExit: false,
  factory: $DoctorMdtConsultRoute._fromState,
);

mixin $DoctorMdtConsultRoute on GoRouteData {
  static DoctorMdtConsultRoute _fromState(GoRouterState state) =>
      DoctorMdtConsultRoute(
        conversationUid: state.pathParameters['conversationUid']!,
      );

  DoctorMdtConsultRoute get _self => this as DoctorMdtConsultRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/mdt/${Uri.encodeComponent(_self.conversationUid)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorMdtInviteRoute => GoRouteData.$route(
  path: '/doctor/mdt/:conversationUid/invite',
  hasOverriddenOnExit: false,
  factory: $DoctorMdtInviteRoute._fromState,
);

mixin $DoctorMdtInviteRoute on GoRouteData {
  static DoctorMdtInviteRoute _fromState(GoRouterState state) =>
      DoctorMdtInviteRoute(
        conversationUid: state.pathParameters['conversationUid']!,
      );

  DoctorMdtInviteRoute get _self => this as DoctorMdtInviteRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/mdt/${Uri.encodeComponent(_self.conversationUid)}/invite',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pathologistMdtNewRoute => GoRouteData.$route(
  path: '/pathologist/mdt/new',
  hasOverriddenOnExit: false,
  factory: $PathologistMdtNewRoute._fromState,
);

mixin $PathologistMdtNewRoute on GoRouteData {
  static PathologistMdtNewRoute _fromState(GoRouterState state) =>
      PathologistMdtNewRoute(caseUid: state.uri.queryParameters['case-uid']);

  PathologistMdtNewRoute get _self => this as PathologistMdtNewRoute;

  @override
  String get location => GoRouteData.$location(
    '/pathologist/mdt/new',
    queryParams: {if (_self.caseUid != null) 'case-uid': _self.caseUid},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pathologistMdtConsultRoute => GoRouteData.$route(
  path: '/pathologist/mdt/:conversationUid',
  hasOverriddenOnExit: false,
  factory: $PathologistMdtConsultRoute._fromState,
);

mixin $PathologistMdtConsultRoute on GoRouteData {
  static PathologistMdtConsultRoute _fromState(GoRouterState state) =>
      PathologistMdtConsultRoute(
        conversationUid: state.pathParameters['conversationUid']!,
      );

  PathologistMdtConsultRoute get _self => this as PathologistMdtConsultRoute;

  @override
  String get location => GoRouteData.$location(
    '/pathologist/mdt/${Uri.encodeComponent(_self.conversationUid)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pathologistMdtInviteRoute => GoRouteData.$route(
  path: '/pathologist/mdt/:conversationUid/invite',
  hasOverriddenOnExit: false,
  factory: $PathologistMdtInviteRoute._fromState,
);

mixin $PathologistMdtInviteRoute on GoRouteData {
  static PathologistMdtInviteRoute _fromState(GoRouterState state) =>
      PathologistMdtInviteRoute(
        conversationUid: state.pathParameters['conversationUid']!,
      );

  PathologistMdtInviteRoute get _self => this as PathologistMdtInviteRoute;

  @override
  String get location => GoRouteData.$location(
    '/pathologist/mdt/${Uri.encodeComponent(_self.conversationUid)}/invite',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientAppointmentChatRoute => GoRouteData.$route(
  path: '/patient/appointment/:appointmentUid/chat',
  hasOverriddenOnExit: false,
  factory: $PatientAppointmentChatRoute._fromState,
);

mixin $PatientAppointmentChatRoute on GoRouteData {
  static PatientAppointmentChatRoute _fromState(GoRouterState state) =>
      PatientAppointmentChatRoute(
        appointmentUid: state.pathParameters['appointmentUid']!,
      );

  PatientAppointmentChatRoute get _self => this as PatientAppointmentChatRoute;

  @override
  String get location => GoRouteData.$location(
    '/patient/appointment/${Uri.encodeComponent(_self.appointmentUid)}/chat',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorAppointmentChatRoute => GoRouteData.$route(
  path: '/doctor/appointment/:appointmentUid/chat',
  hasOverriddenOnExit: false,
  factory: $DoctorAppointmentChatRoute._fromState,
);

mixin $DoctorAppointmentChatRoute on GoRouteData {
  static DoctorAppointmentChatRoute _fromState(GoRouterState state) =>
      DoctorAppointmentChatRoute(
        appointmentUid: state.pathParameters['appointmentUid']!,
      );

  DoctorAppointmentChatRoute get _self => this as DoctorAppointmentChatRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/appointment/${Uri.encodeComponent(_self.appointmentUid)}/chat',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientAppLockRoute => GoRouteData.$route(
  path: '/patient/lock',
  hasOverriddenOnExit: false,
  factory: $PatientAppLockRoute._fromState,
);

mixin $PatientAppLockRoute on GoRouteData {
  static PatientAppLockRoute _fromState(GoRouterState state) =>
      const PatientAppLockRoute();

  @override
  String get location => GoRouteData.$location('/patient/lock');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientCreatePinRoute => GoRouteData.$route(
  path: '/patient/lock/create',
  hasOverriddenOnExit: false,
  factory: $PatientCreatePinRoute._fromState,
);

mixin $PatientCreatePinRoute on GoRouteData {
  static PatientCreatePinRoute _fromState(GoRouterState state) =>
      const PatientCreatePinRoute();

  @override
  String get location => GoRouteData.$location('/patient/lock/create');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientLockAfterRoute => GoRouteData.$route(
  path: '/patient/lock/after',
  hasOverriddenOnExit: false,
  factory: $PatientLockAfterRoute._fromState,
);

mixin $PatientLockAfterRoute on GoRouteData {
  static PatientLockAfterRoute _fromState(GoRouterState state) =>
      const PatientLockAfterRoute();

  @override
  String get location => GoRouteData.$location('/patient/lock/after');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorAppLockRoute => GoRouteData.$route(
  path: '/doctor/lock',
  hasOverriddenOnExit: false,
  factory: $DoctorAppLockRoute._fromState,
);

mixin $DoctorAppLockRoute on GoRouteData {
  static DoctorAppLockRoute _fromState(GoRouterState state) =>
      const DoctorAppLockRoute();

  @override
  String get location => GoRouteData.$location('/doctor/lock');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorCreatePinRoute => GoRouteData.$route(
  path: '/doctor/lock/create',
  hasOverriddenOnExit: false,
  factory: $DoctorCreatePinRoute._fromState,
);

mixin $DoctorCreatePinRoute on GoRouteData {
  static DoctorCreatePinRoute _fromState(GoRouterState state) =>
      const DoctorCreatePinRoute();

  @override
  String get location => GoRouteData.$location('/doctor/lock/create');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorLockAfterRoute => GoRouteData.$route(
  path: '/doctor/lock/after',
  hasOverriddenOnExit: false,
  factory: $DoctorLockAfterRoute._fromState,
);

mixin $DoctorLockAfterRoute on GoRouteData {
  static DoctorLockAfterRoute _fromState(GoRouterState state) =>
      const DoctorLockAfterRoute();

  @override
  String get location => GoRouteData.$location('/doctor/lock/after');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pathologistAppLockRoute => GoRouteData.$route(
  path: '/pathologist/lock',
  hasOverriddenOnExit: false,
  factory: $PathologistAppLockRoute._fromState,
);

mixin $PathologistAppLockRoute on GoRouteData {
  static PathologistAppLockRoute _fromState(GoRouterState state) =>
      const PathologistAppLockRoute();

  @override
  String get location => GoRouteData.$location('/pathologist/lock');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pathologistCreatePinRoute => GoRouteData.$route(
  path: '/pathologist/lock/create',
  hasOverriddenOnExit: false,
  factory: $PathologistCreatePinRoute._fromState,
);

mixin $PathologistCreatePinRoute on GoRouteData {
  static PathologistCreatePinRoute _fromState(GoRouterState state) =>
      const PathologistCreatePinRoute();

  @override
  String get location => GoRouteData.$location('/pathologist/lock/create');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pathologistLockAfterRoute => GoRouteData.$route(
  path: '/pathologist/lock/after',
  hasOverriddenOnExit: false,
  factory: $PathologistLockAfterRoute._fromState,
);

mixin $PathologistLockAfterRoute on GoRouteData {
  static PathologistLockAfterRoute _fromState(GoRouterState state) =>
      const PathologistLockAfterRoute();

  @override
  String get location => GoRouteData.$location('/pathologist/lock/after');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
