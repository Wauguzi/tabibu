import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/cases/presentation/widgets/case_history_row.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final sw = lookupAppLocalizations(const Locale('sw'));

  for (final role in Role.values) {
    testWidgets('${role.name}: the row has a title and its subtitle', (
      tester,
    ) async {
      await tester.pumpApp(CaseHistoryRow(caseUid: 'c1', role: role));

      expect(find.text(en.accessLogTitle), findsOneWidget);
      expect(find.text(en.accessLogBody), findsOneWidget);
    });
  }

  testWidgets('reads in Swahili too', (tester) async {
    await tester.pumpApp(
      const CaseHistoryRow(caseUid: 'c1', role: Role.doctor),
      locale: const Locale('sw'),
    );

    expect(find.text(sw.accessLogTitle), findsOneWidget);
    expect(find.text(sw.accessLogBody), findsOneWidget);
  });
}
