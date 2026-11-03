import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/profile/presentation/privacy_policy_screen.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

final AppLocalizations _en = lookupAppLocalizations(const Locale('en'));
final AppLocalizations _sw = lookupAppLocalizations(const Locale('sw'));

void main() {
  group('PrivacyPolicyScreen', () {
    void tallView(WidgetTester tester) {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }

    testWidgets('a patient: six sections under the draft line', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/privacy/policy',
      );
      await tester.pumpAndSettle();

      expect(find.text(_en.privacyPolicyTitle), findsOneWidget);
      expect(find.text(_en.privacyDraftPatient('27 Oct 2026')), findsOneWidget);
      for (final section in [
        (_en.privacyP1Title, _en.privacyP1Body),
        (_en.privacyP2Title, _en.privacyP2Body),
        (_en.privacyP3Title, _en.privacyP3Body),
        (_en.privacyP4Title, _en.privacyP4Body),
        (_en.privacyP5Title, _en.privacyP5Body),
        (_en.privacyP6Title, _en.privacyP6Body),
      ]) {
        expect(find.text(section.$1), findsOneWidget, reason: section.$1);
        expect(find.text(section.$2), findsOneWidget, reason: section.$1);
      }
    });

    testWidgets('a doctor: five clinician sections', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(
        RoleSessions.doctor(),
        '/doctor/profile/privacy/policy',
      );
      await tester.pumpAndSettle();

      expect(
        find.text(_en.privacyDraftClinician('27 Oct 2026')),
        findsOneWidget,
      );
      for (final section in [
        (_en.privacyD1Title, _en.privacyD1Body),
        (_en.privacyD2Title, _en.privacyD2Body),
        (_en.privacyD3Title, _en.privacyD3Body),
        (_en.privacyD4Title, _en.privacyD4Body),
        (_en.privacyD5Title, _en.privacyD5Body),
      ]) {
        expect(find.text(section.$1), findsOneWidget, reason: section.$1);
        expect(find.text(section.$2), findsOneWidget, reason: section.$1);
      }
    });

    testWidgets('a pathologist: mixed sections, clinician draft line', (
      tester,
    ) async {
      tallView(tester);
      await tester.pumpRoleApp(
        RoleSessions.pathologist,
        '/pathologist/profile/privacy/policy',
      );
      await tester.pumpAndSettle();

      expect(
        find.text(_en.privacyDraftClinician('27 Oct 2026')),
        findsOneWidget,
      );
      for (final section in [
        (_en.privacyD1Title, _en.privacyA1Body),
        (_en.privacyA2Title, _en.privacyA2Body),
        (_en.privacyA3Title, _en.privacyA3Body),
        (_en.privacyD4Title, _en.privacyA4Body),
        (_en.privacyD5Title, _en.privacyD5Body),
      ]) {
        expect(find.text(section.$1), findsOneWidget, reason: section.$1);
        expect(find.text(section.$2), findsOneWidget, reason: section.$1);
      }
    });

    testWidgets('the draft date localises', (tester) async {
      tallView(tester);
      await tester.pumpApp(
        const PrivacyPolicyScreen(role: .patient),
        locale: const Locale('sw'),
        themeMode: ThemeMode.dark,
      );
      await tester.pump();

      expect(find.text(_sw.privacyDraftPatient('27 Okt 2026')), findsOneWidget);
    });
  });
}
