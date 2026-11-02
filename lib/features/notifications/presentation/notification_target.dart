import 'package:go_router/go_router.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/core/routing/app_routes.dart';

/// The screen a notification's `metadata.deepLink` opens for this reader, or
/// null when it has no Tier 1 screen (the tap then only marks it read, F-7).
/// The paths are the server's (`functions/src`), never typed in by a person,
/// but an unknown or malformed one still opens nothing.
GoRouteData? notificationTarget(String deepLink, RoleHelper roles) {
  final segments = Uri.tryParse(deepLink)?.pathSegments ?? const <String>[];
  final role = roles.role;
  if (segments.length < 2 || role == null) return null;
  final id = segments[1];

  return switch ((segments[0], segments.length, role)) {
    ('appointments', 2, .patient) => PatientAppointmentRoute(
      appointmentUid: id,
    ),
    ('appointments', 2, .doctor) => DoctorAppointmentRoute(appointmentUid: id),
    // A case, its report, its discussion booking or its approved text all
    // open the reader's view of the case.
    ('cases', _, .patient) when _caseLink(segments) => PatientResultRoute(
      caseUid: id,
    ),
    ('cases', 2, .doctor) => DoctorCaseRoute(caseUid: id),
    ('cases', _, .doctor) when _caseLink(segments) => DoctorReportRoute(
      caseUid: id,
    ),
    ('cases', _, .pathologist) when _caseLink(segments) => CaseWorkspaceRoute(
      caseUid: id,
    ),
    ('alerts', 2, .patient) => HealthNoticeRoute(alertUid: id),
    ('alerts', 3, .doctor)
        when segments[2] == 'review' && roles.canApproveAlerts =>
      AlertReviewRoute(alertUid: id),
    _ => null,
  };
}

bool _caseLink(List<String> segments) =>
    segments.length == 2 ||
    (segments.length == 3 && segments[2] == 'book-discussion') ||
    (segments.length == 4 && {'reports', 'texts'}.contains(segments[2]));
