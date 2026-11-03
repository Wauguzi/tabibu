import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/ordered_test_model.dart';
import 'package:tabibu/features/reports/presentation/widgets/sample_received_view.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  const caseModel = CaseModel(
    uid: 'c1',
    tests: [OrderedTestModel(name: 'Histopathology examination')],
  );

  Future<List<String>> pump(
    WidgetTester tester, {
    String suggested = 'LAB-WK-03112026-005',
    bool busy = false,
  }) async {
    tester.view.physicalSize = const Size(1170, 4000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final recorded = <String>[];
    await tester.pumpApp(
      SampleReceivedView(
        caseModel: caseModel,
        busy: busy,
        suggested: suggested,
        onRecord: recorded.add,
      ),
    );
    await tester.pump();
    return recorded;
  }

  Finder field() => find.descendant(
    of: find.byType(TabibuTextField),
    matching: find.byType(TextField),
  );

  testWidgets('starts from the made-up accession and sends it as is', (
    tester,
  ) async {
    final recorded = await pump(tester);

    expect(find.text('LAB-WK-03112026-005'), findsOneWidget);
    expect(find.text(en.workspaceSampleSuggested), findsOneWidget);
    expect(find.text('Histopathology examination'), findsOneWidget);

    await tester.tap(find.text(en.doctorCaseSampleReceived));
    await tester.pump();

    expect(recorded, ['LAB-WK-03112026-005']);
  });

  testWidgets("the lab's own number replaces it, trimmed", (tester) async {
    final recorded = await pump(tester);

    await tester.enterText(field(), '  NH/26/0108 ');
    await tester.tap(find.text(en.doctorCaseSampleReceived));
    await tester.pump();

    expect(recorded, ['NH/26/0108']);
  });

  testWidgets('a typographic dash or a space is put right as it is typed', (
    tester,
  ) async {
    final recorded = await pump(tester, suggested: '');

    // An en dash and a space, as a phone keyboard can leave them.
    await tester.enterText(field(), 'LAB\u2013WK 03112026\u2013005');
    await tester.pump();
    expect(
      tester.widget<TextField>(field()).controller?.text,
      'LAB-WK03112026-005',
    );

    await tester.tap(find.text(en.doctorCaseSampleReceived));
    await tester.pump();
    expect(find.text(en.workspaceSampleInvalid), findsNothing);
    expect(recorded, ['LAB-WK03112026-005']);
  });

  testWidgets('the exact suggested number typed by hand is accepted', (
    tester,
  ) async {
    final recorded = await pump(tester, suggested: '');

    await tester.enterText(field(), 'LAB-WK-03112026-005');
    await tester.tap(find.text(en.doctorCaseSampleReceived));
    await tester.pump();

    expect(find.text(en.workspaceSampleInvalid), findsNothing);
    expect(recorded, ['LAB-WK-03112026-005']);
  });

  testWidgets('a number the lab could not use is refused with a reason', (
    tester,
  ) async {
    final recorded = await pump(tester);

    await tester.enterText(field(), '');
    await tester.tap(find.text(en.doctorCaseSampleReceived));
    await tester.pump();

    expect(find.text(en.workspaceSampleInvalid), findsOneWidget);
    expect(recorded, isEmpty);

    // Typing again clears the complaint.
    await tester.enterText(field(), 'NH/26/0108');
    await tester.pump();
    expect(find.text(en.workspaceSampleInvalid), findsNothing);
  });

  testWidgets('with no suggestion the field starts empty and says nothing', (
    tester,
  ) async {
    await pump(tester, suggested: '');

    expect(find.text(en.workspaceSampleSuggested), findsNothing);
    expect(tester.widget<TextField>(field()).controller?.text, isEmpty);
  });

  testWidgets('while it sends the button waits', (tester) async {
    final recorded = await pump(tester, busy: true);

    await tester.tap(find.byType(TabibuButton), warnIfMissed: false);
    await tester.pump();

    expect(recorded, isEmpty);
  });
}
