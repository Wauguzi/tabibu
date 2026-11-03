import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';
import 'package:tabibu/features/worklist/presentation/widgets/ai_mark.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_entry_row.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_facts.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_rank_badge.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../../../helpers/helpers.dart';

final _now = DateTime.utc(2026, 11, 2, 12);

String _ago(Duration d) => _now.subtract(d).toIso8601String();

WorklistEntryModel _entry({
  String order = 'ODR-JK-AW-02112026-001',
  String test = 'Lymph node',
  String preread = 'Ready',
  String band = 'High',
  double confidence = 0.94,
  String urgency = 'Routine',
  Duration? waited = const Duration(hours: 1, minutes: 20),
}) => WorklistEntryModel(
  caseUid: 'case-1',
  orderNumber: order,
  testName: test,
  prereadStatus: preread,
  confidenceBand: band,
  confidence: confidence,
  urgency: urgency,
  waitingSince: waited == null ? '' : _ago(waited),
);

Widget _row(
  WorklistEntryModel entry, {
  int rank = 2,
  DeskPatient? patient,
  VoidCallback? onTap,
}) => DeskEntryRow(
  entry: entry,
  rank: rank,
  now: _now,
  patient: patient,
  onTap: onTap,
);

AppStatusColors _status(WidgetTester tester) => Theme.of(
  tester.element(find.byType(DeskEntryRow)),
).extension<AppStatusColors>()!;

/// Every colour a widget in [of] paints with or tints with.
List<Color?> _colours(WidgetTester tester, Finder of) => [
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

Set<Color> _signedColours(AppStatusColors status) => {
  status.signed,
  status.signedContainer,
  status.signedDot,
  AppColors.mintLight,
  AppColors.mintDark,
  AppColors.signedContainerLight,
  AppColors.signedContainerDark,
};

void main() {
  group('DeskEntryRow', () {
    testWidgets('shows rank, title, patient and the time waiting', (
      tester,
    ) async {
      await tester.pumpApp(
        _row(_entry(), patient: const DeskPatient(name: 'Amina W.', age: 46)),
      );
      expect(find.byType(DeskRankBadge), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('ODR-JK-AW-02112026-001'), findsOneWidget);
      expect(find.text('Lymph node · Amina W., 46'), findsOneWidget);
      expect(find.text('1h 20m'), findsOneWidget);
    });

    testWidgets('edge case 4: no time for an empty waitingSince', (
      tester,
    ) async {
      await tester.pumpApp(_row(_entry(waited: null)));
      expect(find.textContaining(RegExp(r'^\d+h \d+m$|^\d+m$')), findsNothing);
    });

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets(
        'H-18 rule 1: a band wears the AI mark, colour and icon (${mode.name})',
        (tester) async {
          await tester.pumpApp(_row(_entry()), themeMode: mode);
          final status = _status(tester);
          final mark = find.byType(AiMark);

          expect(
            find.descendant(of: mark, matching: find.text('High 94%')),
            findsOneWidget,
          );
          final icon = tester.widget<AssetIcon>(
            find.descendant(of: mark, matching: find.byType(AssetIcon)),
          );
          expect(icon.asset, Assets.icons.sparkleIcon);
          expect(icon.color, status.aiDraft);
          expect(_colours(tester, mark), contains(status.aiDraftContainer));
        },
      );
    }

    testWidgets(
      'H-18 rule 1: a ready pre-read without a band says AI draft ready',
      (tester) async {
        await tester.pumpApp(_row(_entry(confidence: 1.7)));
        expect(
          find.descendant(
            of: find.byType(AiMark),
            matching: find.text('AI draft ready'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'H-18 rule 1: the low band wears the AI mark, not a signed tone',
      (tester) async {
        await tester.pumpApp(_row(_entry(band: 'Low', confidence: 0.52)));
        expect(
          find.descendant(
            of: find.byType(AiMark),
            matching: find.text('Low confidence · 52%'),
          ),
          findsOneWidget,
        );
      },
    );

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets(
        'H-18 rule 2: nothing AI-derived on a row ever wears the signed colour '
        '(${mode.name})',
        (tester) async {
          for (final band in ['High', 'Moderate', 'Low']) {
            await tester.pumpApp(
              _row(_entry(band: band, confidence: 0.6)),
              themeMode: mode,
            );
            final signed = _signedColours(_status(tester));
            expect(
              _colours(tester, find.byType(AiMark)).where(signed.contains),
              isEmpty,
              reason: band,
            );
          }
        },
      );
    }

    testWidgets('H-18 rule 2: urgency and a long wait use attention', (
      tester,
    ) async {
      await tester.pumpApp(_row(_entry(urgency: 'Priority')));
      final status = _status(tester);
      final chip = find.widgetWithText(StatusChip, 'Priority');
      expect(tester.widget<StatusChip>(chip).tone, StatusTone.attention);
      expect(_colours(tester, chip), contains(status.attentionContainer));
      expect(_colours(tester, chip), isNot(contains(status.signedContainer)));

      await tester.pumpApp(
        _row(_entry(waited: const Duration(hours: 5, minutes: 10))),
      );
      final wait = find.widgetWithText(StatusChip, 'Waiting over 5h');
      expect(tester.widget<StatusChip>(wait).tone, StatusTone.attention);

      await tester.pumpApp(_row(_entry(urgency: 'Urgent')));
      expect(find.widgetWithText(StatusChip, 'Urgent'), findsOneWidget);
    });

    testWidgets(
      'H-18 rule 3: a pre-read that is not ready says nothing about the AI',
      (tester) async {
        for (final status in ['', 'Queued', 'Running']) {
          await tester.pumpApp(_row(_entry(preread: status)));
          expect(find.byType(AiMark), findsNothing, reason: status);
          expect(find.byType(StatusChip), findsNothing, reason: status);
          expect(find.textContaining('%'), findsNothing, reason: status);
          expect(find.text('AI draft ready'), findsNothing, reason: status);
          expect(find.text('No AI draft'), findsNothing, reason: status);
          expect(
            find.byWidgetPredicate(
              (w) => w is AssetIcon && w.asset == Assets.icons.sparkleIcon,
            ),
            findsNothing,
            reason: status,
          );
        }
      },
    );

    testWidgets('H-18 rule 3: a failed pre-read says No AI draft in neutral', (
      tester,
    ) async {
      await tester.pumpApp(_row(_entry(preread: 'Failed')));
      final status = _status(tester);
      final chip = find.widgetWithText(StatusChip, 'No AI draft');
      expect(tester.widget<StatusChip>(chip).tone, StatusTone.neutral);
      expect(_colours(tester, chip), contains(status.neutralContainer));
      expect(find.byType(AiMark), findsNothing);
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('H-18 rule 5: band and percent together, or neither', (
      tester,
    ) async {
      await tester.pumpApp(_row(_entry()));
      expect(find.text('High 94%'), findsOneWidget);

      await tester.pumpApp(_row(_entry(band: 'Moderate', confidence: 0.78)));
      expect(find.text('Moderate 78%'), findsOneWidget);

      for (final confidence in [1.7, -0.1]) {
        await tester.pumpApp(_row(_entry(confidence: confidence)));
        expect(find.textContaining('%'), findsNothing, reason: '$confidence');
        expect(
          find.textContaining('High'),
          findsNothing,
          reason: '$confidence',
        );
        expect(find.text('AI draft ready'), findsOneWidget);
      }
    });

    testWidgets('H-18 rule 6: the row reads the AI marking aloud', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(_row(_entry(urgency: 'Priority'), onTap: () {}));
      // One merged reading of the row: title, urgency, then the AI marking
      // with its band, from the same keys the chip shows.
      expect(
        find.bySemanticsLabel(
          RegExp(
            r'ODR-JK-AW-02112026-001[\s\S]*Lymph node[\s\S]*Priority'
            r'[\s\S]*AI draft ready · High 94%',
          ),
        ),
        findsOneWidget,
      );

      await tester.pumpApp(_row(_entry(confidence: 1.7), onTap: () {}));
      expect(
        find.bySemanticsLabel(RegExp(r'Lymph node[\s\S]*AI draft ready')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('edge case 1: the rank digits are readable in dark mode', (
      tester,
    ) async {
      await tester.pumpApp(_row(_entry(), rank: 4), themeMode: ThemeMode.dark);
      expect(
        tester.widget<Text>(find.text('4')).style?.color,
        AppColors.inkLight,
      );
    });

    for (final scale in [1.0, 1.3]) {
      testWidgets(
        'edge case 10: the case number is one line, whole, at 390 dp and '
        '${scale}x',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          const order = 'ODR-JK-AW-02112026-001';
          await tester.pumpApp(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _row(
                _entry(
                  test: 'Fine needle aspirate of a lymph node, left axilla',
                  urgency: 'Priority',
                ),
                rank: 128,
                patient: const DeskPatient(name: 'Njeri M.', age: 52),
              ),
            ),
          );
          expect(tester.takeException(), isNull);

          final paragraph = tester.renderObject<RenderParagraph>(
            find.text(order),
          );
          expect(paragraph.didExceedMaxLines, isFalse);
          final boxes = paragraph.getBoxesForSelection(
            const TextSelection(baseOffset: 0, extentOffset: order.length),
          );
          expect(boxes.map((b) => b.top).toSet(), hasLength(1));
          // The whole number is there, not an ellipsis.
          expect(find.text(order), findsOneWidget);
          expect(
            tester.getSize(find.byType(DeskEntryRow)).width,
            lessThanOrEqualTo(350),
          );
          // The test name takes one line with an ellipsis.
          final detail = tester.renderObject<RenderParagraph>(
            find.textContaining('Fine needle'),
          );
          expect(detail.size.height, lessThanOrEqualTo(24.0 * scale));
        },
      );
    }

    testWidgets(
      'edge case 10: rows in a list keep their height for a long name',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpApp(
          Column(
            children: [
              _row(
                _entry(),
                patient: const DeskPatient(name: 'Amina W.', age: 46),
              ),
              _row(
                _entry(),
                patient: const DeskPatient(
                  name: 'Achieng-Odhiambo-Otieno-Njeri-Kamau W.',
                  age: 46,
                ),
              ),
            ],
          ),
        );
        final rows = tester.widgetList(find.byType(DeskEntryRow)).length;
        expect(rows, 2);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
