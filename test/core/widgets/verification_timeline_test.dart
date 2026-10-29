import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/status_mark.dart';
import 'package:tabibu/core/widgets/verification_timeline.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../helpers/helpers.dart';

const _steps = [
  VerificationStep(
    title: 'Details submitted',
    supporting: 'Today, 09:12',
    state: VerificationStepState.done,
    chipLabel: 'Done',
    stateLabel: 'Done',
  ),
  VerificationStep(
    title: 'Licence check',
    supporting: 'Usually under 1 working day',
    state: VerificationStepState.inProgress,
    chipLabel: 'In progress',
    stateLabel: 'In progress',
  ),
  VerificationStep(
    title: 'Verified',
    supporting: 'You can see patients',
    state: VerificationStepState.upNext,
    chipLabel: 'Up next',
    stateLabel: 'Up next',
  ),
];

void main() {
  group('VerificationTimeline', () {
    testWidgets('renders every step with its chip', (tester) async {
      await tester.pumpApp(
        VerificationTimeline(
          title: 'Your verification',
          progressLabel: 'Step 2 of 4',
          steps: [
            _steps[0],
            VerificationStep(
              icon: Assets.icons.inProgressIcon,
              title: _steps[1].title,
              supporting: _steps[1].supporting,
              state: _steps[1].state,
              chipLabel: _steps[1].chipLabel,
              stateLabel: _steps[1].stateLabel,
            ),
            VerificationStep(
              icon: Assets.icons.verificationBadge,
              title: _steps[2].title,
              supporting: _steps[2].supporting,
              state: _steps[2].state,
              chipLabel: _steps[2].chipLabel,
              stateLabel: _steps[2].stateLabel,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your verification'), findsOneWidget);
      expect(find.text('Step 2 of 4'), findsOneWidget);
      expect(find.byType(StatusMark), findsNWidgets(3));
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('In progress'), findsOneWidget);
      expect(find.text('Up next'), findsOneWidget);
    });

    testWidgets('announces each step state', (tester) async {
      await tester.pumpApp(
        VerificationTimeline(
          title: 'Your verification',
          progressLabel: 'Step 2 of 4',
          steps: [
            _steps[0],
            VerificationStep(
              icon: Assets.icons.inProgressIcon,
              title: _steps[1].title,
              supporting: _steps[1].supporting,
              state: _steps[1].state,
              chipLabel: _steps[1].chipLabel,
              stateLabel: _steps[1].stateLabel,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(StatusMark).first),
        matchesSemantics(label: 'Done', isImage: true),
      );
      expect(
        tester.getSemantics(find.byType(StatusMark).last),
        matchesSemantics(label: 'In progress', isImage: true),
      );
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        SingleChildScrollView(
          child: VerificationTimeline(
            title: 'Your verification',
            progressLabel: 'Step 2 of 4',
            steps: [
              _steps[0],
              VerificationStep(
                icon: Assets.icons.inProgressIcon,
                title: 'A long title that must wrap, not clip',
                supporting: 'Supporting text that also wraps onto more lines',
                state: VerificationStepState.inProgress,
                chipLabel: 'In progress',
                stateLabel: 'In progress',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('raises by tone in dark mode', (tester) async {
      await tester.pumpApp(
        VerificationTimeline(
          title: 'Your verification',
          progressLabel: 'Step 2 of 4',
          steps: [_steps[0]],
        ),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(VerificationTimeline));
      final scheme = Theme.of(context).colorScheme;
      final card = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(VerificationTimeline),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        (card.decoration! as BoxDecoration).color,
        scheme.surfaceContainerHigh,
      );
    });
  });
}
