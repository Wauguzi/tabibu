import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/appointments/presentation/widgets/cancel_sheet.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// A sheet opens and closes on animations that never settle under a spinner.
Future<void> _settleSheet(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

AppointmentModel _appointment({required Duration fromNow}) => AppointmentModel(
  uid: 'a1',
  status: 'Accepted',
  doctorUid: 'd1',
  doctorName: 'Dr. Wanjiru Kamau',
  patientName: 'Amina Njoroge',
  scheduledStart: DateTime.now().toUtc().add(fromNow).toIso8601String(),
);

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final sw = lookupAppLocalizations(const Locale('sw'));

  group('CancelSheet', () {
    testWidgets('a patient confirms with a reason and a note', (tester) async {
      _useTallSurface(tester);
      CancelChoice? choice;
      await tester.pumpApp(
        Builder(
          builder: (context) => TabibuButton.primary(
            label: 'open',
            onTap: () async => choice = await CancelSheet.show(
              context,
              appointment: _appointment(fromNow: const Duration(days: 2)),
              isDoctor: false,
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settleSheet(tester);

      expect(find.byType(TabibuBottomSheet), findsOneWidget);
      expect(find.text(en.cancelAppointmentTitle), findsOneWidget);
      for (final reason in [
        en.cancelAppointmentReasonDay,
        en.cancelAppointmentReasonBetter,
        en.cancelAppointmentReasonElsewhere,
        en.cancelAppointmentReasonOther,
      ]) {
        expect(find.text(reason), findsOneWidget);
      }

      await tester.tap(find.text(en.cancelAppointmentReasonBetter));
      await tester.pump();
      await tester.enterText(find.byType(TextField), '  See you next term  ');
      await tester.pump();
      await tester.tap(find.text(en.cancelAppointmentConfirm));
      await _settleSheet(tester);

      expect(find.byType(TabibuBottomSheet), findsNothing);
      expect(choice, (
        reason: en.cancelAppointmentReasonBetter,
        note: 'See you next term',
      ));
    });

    testWidgets('the note cap leaves room for the reason', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(
        Builder(
          builder: (context) => TabibuButton.primary(
            label: 'open',
            onTap: () => CancelSheet.show(
              context,
              appointment: _appointment(fromNow: const Duration(days: 2)),
              isDoctor: false,
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settleSheet(tester);

      final field = find.byType(TabibuTextField);
      expect(tester.widget<TabibuTextField>(field).maxLength, 300);
      await tester.tap(find.text(en.cancelAppointmentReasonBetter));
      await tester.pump();
      expect(
        tester.widget<TabibuTextField>(field).maxLength,
        300 - en.cancelAppointmentReasonBetter.length - 1,
      );

      Navigator.of(tester.element(find.byType(TabibuBottomSheet))).pop();
      await _settleSheet(tester);
    });

    testWidgets('closing without confirming sends nothing', (tester) async {
      _useTallSurface(tester);
      var done = false;
      CancelChoice? choice;
      await tester.pumpApp(
        Builder(
          builder: (context) => TabibuButton.primary(
            label: 'open',
            onTap: () async {
              choice = await CancelSheet.show(
                context,
                appointment: _appointment(fromNow: const Duration(days: 2)),
                isDoctor: false,
              );
              done = true;
            },
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settleSheet(tester);

      // The sheet sheds its route without the confirm tap.
      Navigator.of(tester.element(find.byType(TabibuBottomSheet))).pop();
      await _settleSheet(tester);

      expect(done, isTrue);
      expect(choice, isNull);
    });

    testWidgets('a doctor must pick a reason or write a note', (tester) async {
      _useTallSurface(tester);
      CancelChoice? choice;
      await tester.pumpApp(
        Builder(
          builder: (context) => TabibuButton.primary(
            label: 'open',
            onTap: () async => choice = await CancelSheet.show(
              context,
              appointment: _appointment(fromNow: const Duration(days: 2)),
              isDoctor: true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settleSheet(tester);

      expect(
        find.text(en.cancelAppointmentTitleDoctor('Amina')),
        findsOneWidget,
      );
      await tester.tap(find.text(en.cancelAppointmentConfirm));
      await tester.pump();

      expect(find.text(en.cancelAppointmentNeedReason), findsOneWidget);
      expect(find.byType(TabibuBottomSheet), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'In theatre');
      await tester.pump();
      expect(find.text(en.cancelAppointmentNeedReason), findsNothing);
      await tester.tap(find.text(en.cancelAppointmentConfirm));
      await _settleSheet(tester);

      expect(choice, (reason: '', note: 'In theatre'));
    });

    testWidgets('a slot that started cannot be cancelled', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(
        Builder(
          builder: (context) => TabibuButton.primary(
            label: 'open',
            onTap: () => CancelSheet.show(
              context,
              appointment: _appointment(fromNow: const Duration(hours: -1)),
              isDoctor: false,
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settleSheet(tester);

      expect(find.text(en.cancelAppointmentTooLate), findsOneWidget);
      expect(find.text(en.cancelAppointmentConfirm), findsNothing);
      await tester.tap(find.text(en.commonBack));
      await _settleSheet(tester);
      expect(find.byType(TabibuBottomSheet), findsNothing);
    });

    testWidgets('renders in Swahili, dark, at 1.3x text', (tester) async {
      _useTallSurface(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpApp(
        Builder(
          builder: (context) => TabibuButton.primary(
            label: 'open',
            onTap: () => CancelSheet.show(
              context,
              appointment: _appointment(fromNow: const Duration(days: 2)),
              isDoctor: false,
            ),
          ),
        ),
        themeMode: ThemeMode.dark,
        locale: const Locale('sw'),
      );
      await tester.tap(find.text('open'));
      await _settleSheet(tester);

      expect(find.text(sw.cancelAppointmentTitle), findsOneWidget);
      expect(find.text(sw.cancelAppointmentReasonBetter), findsOneWidget);
      expect(find.text(sw.cancelAppointmentConfirm), findsOneWidget);
      expect(tester.takeException(), isNull);

      Navigator.of(tester.element(find.byType(TabibuBottomSheet))).pop();
      await _settleSheet(tester);
    });
  });
}
