import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/ordered_test_model.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';
import 'package:tabibu/features/worklist/presentation/widgets/ai_mark.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../../helpers/helpers.dart';

/// The clock every desk screen test runs on: noon UTC, 15:00 in Nairobi.
final deskNow = DateTime.utc(2026, 11, 2, 12);

const deskUid = 'path-1';

PractitionerSession deskSession() {
  final base = RoleSessions.pathologist;
  return PractitionerSession(
    doctor: base.doctor.copyWith(uid: deskUid),
    roles: base.roles,
  );
}

WorklistEntryModel deskEntry(
  int n, {
  String preread = 'Ready',
  String band = 'High',
  double confidence = 0.94,
  String urgency = 'Routine',
  String profile = 'None',
  Duration? waited = const Duration(hours: 1, minutes: 20),
  String? waitingSince,
}) => WorklistEntryModel(
  uid: 'entry-$n',
  caseUid: 'case-$n',
  orderNumber: 'ODR-JK-AW-02112026-00$n',
  testName: 'Lymph node',
  profile: profile,
  prereadStatus: preread,
  confidenceBand: band,
  confidence: confidence,
  urgency: urgency,
  waitingSince:
      waitingSince ?? (waited == null ? '' : _ago(waited).toIso8601String()),
);

DateTime _ago(Duration d) => deskNow.subtract(d);

/// Six cases, in rank order:
///
/// 1. ready, High 94%, urgent, 1h 20m (the hero)
/// 2. ready, Low 52%, priority, 5h 10m
/// 3. failed pre-read, routine, 6h
/// 4. running pre-read, routine, 30m
/// 5. ready, Moderate 70%, routine, 2h, malaria
/// 6. ready, Low 40%, routine, 9h (below "Up next")
List<WorklistEntryModel> deskEntries() => [
  deskEntry(1, urgency: 'Urgent'),
  deskEntry(
    2,
    band: 'Low',
    confidence: 0.52,
    urgency: 'Priority',
    waited: const Duration(hours: 5, minutes: 10),
  ),
  deskEntry(3, preread: 'Failed', waited: const Duration(hours: 6)),
  deskEntry(4, preread: 'Running', waited: const Duration(minutes: 30)),
  deskEntry(
    5,
    band: 'Moderate',
    confidence: 0.7,
    profile: 'Malaria',
    waited: const Duration(hours: 2),
  ),
  deskEntry(6, band: 'Low', confidence: 0.4, waited: const Duration(hours: 9)),
];

CaseModel deskCase(int n, {String patient = 'Amina Wambui', int age = 46}) =>
    CaseModel(
      uid: 'case-$n',
      patientName: patient,
      patientAgeYears: age,
      tests: [const OrderedTestModel(name: 'Lymph node')],
    );

/// Stub destinations for everything a desk screen can go to, at the real
/// paths. [home] is where the test starts.
GoRouter deskRouter(Widget Function() home, {String initial = '/home'}) {
  final router = GoRouter(
    initialLocation: initial,
    routes: [
      GoRoute(path: '/home', builder: (_, _) => home()),
      GoRoute(path: '/desk', builder: (_, _) => home()),
      GoRoute(
        path: '/pathologist/notifications',
        builder: (_, _) => const Text('stub notifications'),
      ),
      GoRoute(
        path: '/pathologist/search',
        builder: (_, _) => const Text('stub search'),
      ),
      GoRoute(
        path: '/pathologist/cases',
        builder: (_, state) =>
            Text('stub list ${state.uri.queryParameters['filter'] ?? 'all'}'),
      ),
      GoRoute(
        path: '/pathologist/signed',
        builder: (_, _) => const Text('stub signed'),
      ),
      GoRoute(
        path: '/pathologist/case/:caseUid',
        builder: (_, state) =>
            Text('stub case ${state.pathParameters['caseUid']}'),
      ),
    ],
  );
  return router;
}

/// A phone-width surface tall enough to mount every row.
void useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// 390 dp wide, the width the layout is held to.
void usePhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(390 * 3, 15000);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

AppStatusColors statusOf(WidgetTester tester, Finder at) =>
    Theme.of(tester.element(at.first)).extension<AppStatusColors>()!;

/// Every colour a widget in [of] paints with or tints with.
List<Color?> coloursIn(WidgetTester tester, Finder of) => [
  for (final c in tester.widgetList<Container>(
    find.descendant(of: of, matching: find.byType(Container)),
  ))
    (c.decoration as BoxDecoration?)?.color,
  for (final t in tester.widgetList<Text>(
    find.descendant(of: of, matching: find.byType(Text)),
  ))
    t.style?.color,
  for (final i in tester.widgetList<AssetIcon>(
    find.descendant(of: of, matching: find.byType(AssetIcon)),
  ))
    i.color,
];

Set<Color> signedColours(AppStatusColors status) => {
  status.signed,
  status.signedContainer,
  status.signedDot,
  AppColors.mintLight,
  AppColors.mintDark,
  AppColors.signedContainerLight,
  AppColors.signedContainerDark,
};

/// Whether [finder]'s widget has a sparkle icon among its descendants.
bool hasSparkle(WidgetTester tester, Finder finder) => tester
    .widgetList<AssetIcon>(
      find.descendant(of: finder, matching: find.byType(AssetIcon)),
    )
    .any((i) => i.asset == Assets.icons.sparkleIcon);

/// Every AI mark on screen, in tree order.
Finder get aiMarks => find.byType(AiMark);

/// Whether the paragraph shows on one line.
bool isOneLine(WidgetTester tester, Finder text) {
  final paragraph = tester.renderObject<RenderParagraph>(text);
  final length = paragraph.text.toPlainText().length;
  final boxes = paragraph.getBoxesForSelection(
    TextSelection(baseOffset: 0, extentOffset: length),
  );
  return boxes.map((b) => b.top).toSet().length == 1;
}
