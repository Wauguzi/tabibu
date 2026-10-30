import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/presentation/widgets/step_scaffold.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('StepScaffold', () {
    testWidgets('slivers mode shows the header and every sliver', (
      tester,
    ) async {
      await tester.pumpApp(
        StepScaffold(
          step: 3,
          total: 4,
          backLabel: 'Back',
          onBack: () {},
          title: 'Title',
          subtitle: 'Subtitle',
          error: AppError.invalidName,
          footer: const Text('Footer'),
          slivers: const [
            SliverToBoxAdapter(child: Text('First')),
            SliverToBoxAdapter(child: Text('Second')),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
      expect(find.byType(NoticeCard), findsOneWidget);
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('child and slivers together fail the assert', (tester) async {
      expect(
        () => StepScaffold(
          step: 1,
          total: 4,
          backLabel: 'Back',
          onBack: () {},
          title: 'Title',
          footer: const Text('Footer'),
          slivers: const [SliverToBoxAdapter(child: Text('Sliver'))],
          child: const Text('Child'),
        ),
        throwsAssertionError,
      );
    });
  });
}
