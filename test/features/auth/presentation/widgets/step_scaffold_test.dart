import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/presentation/widgets/step_scaffold.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('StepScaffold', () {
    testWidgets('99: a drag on the body drops the keyboard', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpApp(
        StepScaffold(
          step: 1,
          total: 4,
          backLabel: 'Back',
          onBack: () {},
          title: 'Title',
          footer: const Text('Footer'),
          child: Column(
            children: [
              TextField(focusNode: node),
              for (var i = 0; i < 40; i++) Text('Field row $i'),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(node.hasPrimaryFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -120),
      );
      await tester.pump();
      expect(node.hasPrimaryFocus, isFalse);
      expect(tester.testTextInput.isVisible, isFalse);
    });

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
