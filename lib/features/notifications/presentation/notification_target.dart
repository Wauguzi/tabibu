import 'package:go_router/go_router.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/features/notifications/data/models/notification_model.dart';

/// Topic pushes and some local banners carry the path itself; inbox taps
/// carry the row uid (notifications engine §7 / `functions/src/push.ts`).
bool isNotificationDeepLinkPayload(String payload) => payload.startsWith('/');

/// The screen a notification's `metadata.deepLink` opens for this reader, or
/// null when it has no Tier 1 screen (a row tap then only marks it read, F-7).
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

/// The enter-code screen for a row that carries a share code, or null when
/// the row has none, the reader is not a doctor or pathologist, or the share
/// id cannot be read from the row id.
///
/// Row ids are `template:resourceKey:recipientUid` (server `NotificationTx`).
/// The route gets the share id only; the code in `metadata.shareCode` is never
/// read here, so it cannot reach a route or a field (T-18).
GoRouteData? shareCodeTarget(NotificationModel row, RoleHelper roles) {
  if (!row.hasShareCode) return null;
  final shareUid = _shareUidOf(row.uid);
  if (shareUid.isEmpty) return null;
  return switch (roles.role) {
    .doctor => DoctorEnterShareCodeRoute(shareUid: shareUid),
    .pathologist => PathologistEnterShareCodeRoute(shareUid: shareUid),
    _ => null,
  };
}

/// `caseShared` keys on the share; a reissue on `{share}-r{n}`; a signed or
/// updated report on its case and report, whose unlock share is
/// `unlock_{case}_{report}` (functions/src).
String _shareUidOf(String rowUid) {
  final parts = rowUid.split(':');
  if (parts.length != 3 || parts[1].isEmpty) return '';
  final key = parts[1];
  return switch (parts[0]) {
    'caseShared' => key,
    'shareCodeReissued' => key.replaceFirst(RegExp(r'-r\d+$'), ''),
    'reportSigned' || 'reportUpdated' => 'unlock_$key',
    _ => '',
  };
}

/// The role's notifications inbox. A push tap with no Tier 1 target lands
/// here (unknown path, wrong role, or outside Tier 1).
GoRouteData? notificationsHome(RoleHelper roles) => switch (roles.role) {
  .patient => const PatientNotificationsRoute(),
  .doctor => const DoctorNotificationsRoute(),
  .pathologist => const PathologistNotificationsRoute(),
  null => null,
};

/// Where a loaded inbox row opens for every tap surface (inbox, push, banner):
/// share-code entry first (T-18), then the deep link. Null when the row has no
/// screen of its own; the inbox then only marks it read, and a push or banner
/// tap falls back to the inbox itself.
GoRouteData? notificationRowTarget(NotificationModel row, RoleHelper roles) =>
    shareCodeTarget(row, roles) ??
    notificationTarget(row.metadata.deepLink, roles);

/// A plain deep-link payload with no row: the Tier 1 screen, else the inbox.
GoRouteData? notificationTapRoute(String deepLink, RoleHelper roles) =>
    notificationTarget(deepLink, roles) ?? notificationsHome(roles);

bool _caseLink(List<String> segments) =>
    segments.length == 2 ||
    (segments.length == 3 && segments[2] == 'book-discussion') ||
    (segments.length == 4 && {'reports', 'texts'}.contains(segments[2]));
