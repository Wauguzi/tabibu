import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/loading_view.dart';

import '../../helpers/helpers.dart';

void main() {
  group('LoadingView', () {
    testWidgets('renders a primary spinner with its label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(const LoadingView(semanticLabel: 'Loading doctors'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final context = tester.element(find.byType(LoadingView));
      final scheme = Theme.of(context).colorScheme;
      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      final color = spinner.valueColor! as AlwaysStoppedAnimation<Color>;
      expect(color.value, scheme.primary);
      expect(find.bySemanticsLabel('Loading doctors'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('renders in dark', (tester) async {
      await tester.pumpApp(
        const LoadingView(semanticLabel: 'Loading doctors'),
        themeMode: ThemeMode.dark,
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final context = tester.element(find.byType(LoadingView));
      final scheme = Theme.of(context).colorScheme;
      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      final color = spinner.valueColor! as AlwaysStoppedAnimation<Color>;
      expect(color.value, scheme.primary);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(
        const LoadingView(semanticLabel: 'Chagua daktari'),
        locale: const Locale('sw'),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('grows at 1.3x text without overflow at 390 dp', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(const LoadingView(semanticLabel: 'Loading doctors'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
