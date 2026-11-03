import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/profile/presentation/help_screen.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

final AppLocalizations _en = lookupAppLocalizations(const Locale('en'));
final AppLocalizations _sw = lookupAppLocalizations(const Locale('sw'));

void main() {
  group('HelpScreen', () {
    void tallView(WidgetTester tester) {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }

    testWidgets('a patient: call row and four questions, first open', (
      tester,
    ) async {
      tallView(tester);
      await tester.pumpRoleApp(RoleSessions.patient, '/patient/profile/help');
      await tester.pumpAndSettle();

      expect(find.text(_en.helpTitle), findsOneWidget);
      expect(find.text(_en.helpTalkToUs), findsOneWidget);
      expect(find.text(_en.helpCallUs), findsOneWidget);
      expect(find.text(_en.helpCallUsBody), findsOneWidget);
      expect(find.text(_en.helpQuestions), findsOneWidget);
      expect(find.text(_en.helpChangeAppointment), findsOneWidget);
      expect(find.text(_en.helpChangeAppointmentBody), findsOneWidget);
      expect(find.text(_en.helpWhenResultsBody), findsNothing);
      expect(find.text(_en.helpKiswahiliBody), findsNothing);
      expect(find.text(_en.helpSafeBody), findsNothing);
    });

    testWidgets('tapping a question opens it and closes the first', (
      tester,
    ) async {
      tallView(tester);
      await tester.pumpRoleApp(RoleSessions.patient, '/patient/profile/help');
      await tester.pumpAndSettle();

      await tester.tap(find.text(_en.helpWhenResults));
      await tester.pump();

      expect(find.text(_en.helpWhenResultsBody), findsOneWidget);
      expect(find.text(_en.helpChangeAppointmentBody), findsNothing);
    });

    testWidgets('the call row dials out', (tester) async {
      tallView(tester);
      var launched = '';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/url_launcher'),
            (call) async {
              final args = call.arguments as Map<Object?, Object?>;
              launched = args['url'] as String? ?? '';
              return true;
            },
          );
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('plugins.flutter.io/url_launcher'),
              null,
            );
      });
      await tester.pumpRoleApp(RoleSessions.patient, '/patient/profile/help');
      await tester.pumpAndSettle();

      await tester.tap(find.text(_en.helpCallUs));
      await tester.pump();

      expect(launched, 'tel:+254707716621');
    });

    testWidgets('a doctor: clinician support and three guides', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(RoleSessions.doctor(), '/doctor/profile/help');
      await tester.pumpAndSettle();

      expect(find.text(_en.helpClinicianSupport), findsOneWidget);
      expect(find.text(_en.helpCallClinician), findsOneWidget);
      expect(find.text(_en.helpCallClinicianBody), findsOneWidget);
      expect(find.text(_en.helpGuides), findsOneWidget);
      expect(find.text(_en.helpOrderingTestBody), findsOneWidget);
      expect(find.text(_en.helpApprovingAlertsBody), findsNothing);
      expect(find.text(_en.helpMdtConsultBody), findsNothing);
    });

    testWidgets('a pathologist: two guides, no relabelling', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(
        RoleSessions.pathologist,
        '/pathologist/profile/help',
      );
      await tester.pumpAndSettle();

      expect(find.text(_en.helpClinicianSupport), findsOneWidget);
      expect(find.text(_en.helpPreread), findsOneWidget);
      expect(find.text(_en.helpPrereadBody), findsOneWidget);
      expect(find.text(_en.helpSigning), findsOneWidget);
      expect(find.text(_en.helpSigningBody), findsNothing);
    });

    testWidgets('renders in Swahili, dark, at 1.3x', (tester) async {
      tallView(tester);
      await tester.pumpApp(
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: HelpScreen(role: .patient),
        ),
        locale: const Locale('sw'),
        themeMode: ThemeMode.dark,
      );
      await tester.pump();

      expect(find.text(_sw.helpTitle), findsOneWidget);
      expect(find.text(_sw.helpTalkToUs), findsOneWidget);
      expect(find.text(_sw.helpCallUs), findsOneWidget);
      expect(find.text(_sw.helpQuestions), findsOneWidget);
      expect(find.text(_sw.helpChangeAppointmentBody), findsOneWidget);
    });
  });
}
