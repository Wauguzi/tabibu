import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/status_mark.dart';
import 'package:tabibu/core/widgets/verification_timeline.dart';
import 'package:tabibu/features/cases/presentation/widgets/case_timeline_card.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../../../helpers/helpers.dart';

List<VerificationStep> _steps() => [
  const VerificationStep(
    title: 'Sample collected',
    supporting: 'Mon 20 Oct',
    state: VerificationStepState.done,
    chipLabel: 'Done',
    stateLabel: 'Done',
  ),
  VerificationStep(
    title: 'Lab processing',
    supporting: 'Usually 2 working days',
    state: VerificationStepState.inProgress,
    chipLabel: 'In progress',
    stateLabel: 'In progress',
    icon: Assets.icons.inProgressIcon,
  ),
  VerificationStep(
    title: 'Report ready',
    supporting: 'You will be notified',
    state: VerificationStepState.upNext,
    chipLabel: 'Up next',
    stateLabel: 'Up next',
    icon: Assets.icons.verificationBadge,
  ),
];

void main() {
  group('CaseTimelineCard', () {
    testWidgets('shows title, trailing and every step state', (tester) async {
      await tester.pumpApp(
        CaseTimelineCard(
          title: 'Where the case is',
          trailing: 'Step 3 of 5',
          steps: _steps(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Where the case is'), findsOneWidget);
      expect(find.text('Step 3 of 5'), findsOneWidget);
      expect(find.byType(VerificationTimeline), findsOneWidget);
      expect(find.byType(StatusMark), findsNWidgets(3));
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('In progress'), findsOneWidget);
      expect(find.text('Up next'), findsOneWidget);
      expect(find.text('Sample collected'), findsOneWidget);
      expect(find.text('Lab processing'), findsOneWidget);
      expect(find.text('Report ready'), findsOneWidget);
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          CaseTimelineCard(
            title: 'Where the case is',
            trailing: 'Step 3 of 5',
            steps: _steps(),
          ),
          themeMode: mode,
        );
        await tester.pumpAndSettle();
        expect(find.byType(CaseTimelineCard), findsOneWidget);
      }
    });

    testWidgets('grows at 1.3x text without overflow at 390 dp', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        SizedBox(
          width: 390,
          child: CaseTimelineCard(
            title: 'Where the case is',
            trailing: 'Step 3 of 5',
            steps: _steps(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
