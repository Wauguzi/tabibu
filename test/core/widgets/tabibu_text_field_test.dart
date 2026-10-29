import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/tabibu_text_field.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../helpers/helpers.dart';

void main() {
  group('TabibuTextField', () {
    testWidgets('renders label, hint and icons', (tester) async {
      await tester.pumpApp(
        TabibuTextField(
          label: 'Email',
          hint: 'you@example.com',
          leading: AssetIcon(Assets.icons.emailIcon, size: 22),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('you@example.com'), findsOneWidget);
    });

    testWidgets('marks required labels with an asterisk', (tester) async {
      await tester.pumpApp(
        const TabibuTextField(label: 'Name', required: true),
      );

      expect(find.textContaining('*'), findsOneWidget);
    });

    testWidgets('shows error and helper text', (tester) async {
      await tester.pumpApp(
        const Column(
          children: [
            TabibuTextField(label: 'A', errorText: 'Wrong'),
            TabibuTextField(label: 'B', helperText: 'Helpful'),
          ],
        ),
      );

      expect(find.text('Wrong'), findsOneWidget);
      expect(find.text('Helpful'), findsOneWidget);
    });

    testWidgets('reports input', (tester) async {
      var value = '';
      await tester.pumpApp(
        TabibuTextField(label: 'Name', onChanged: (v) => value = v),
      );

      await tester.enterText(find.byType(TextField), 'Amina');
      expect(value, 'Amina');
    });

    testWidgets('counts characters against the limit', (tester) async {
      await tester.pumpApp(
        const TabibuTextField(label: 'Bio', maxLines: 4, maxLength: 300),
      );

      await tester.enterText(find.byType(TextField), 'Hi');
      await tester.pump();
      expect(find.text('2 / 300'), findsOneWidget);
    });

    testWidgets('merges the label into the field node', (tester) async {
      await tester.pumpApp(
        const TabibuTextField(label: 'Email', hint: 'you@example.com'),
      );

      expect(
        tester.getSemantics(find.byType(TextField)),
        matchesSemantics(
          label: 'Email\nyou@example.com',
          isTextField: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
    });

    testWidgets('keeps the counter clear of the error at 2.0x', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        const SingleChildScrollView(
          child: TabibuTextField(
            label: 'Bio',
            maxLines: 4,
            maxLength: 300,
            errorText: 'Too long for the record',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('0 / 300'), findsOneWidget);
      expect(find.text('Too long for the record'), findsOneWidget);
      final counter = tester.getRect(find.text('0 / 300'));
      final error = tester.getRect(find.text('Too long for the record'));
      expect(counter.overlaps(error), isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('meets the 48dp floor', (tester) async {
      await tester.pumpApp(const TabibuTextField(label: 'Name'));

      expect(
        tester.getSize(find.byType(TextField)).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        const TabibuTextField(
          label: 'A long label that must wrap, not clip',
          helperText: 'Helper text that also wraps onto more lines',
        ),
      );

      expect(tester.takeException(), isNull);
    });

    group('focus colour', () {
      Widget field({String? errorText, bool readOnly = false}) =>
          TabibuTextField(
            label: 'Email',
            // As FieldIcon: a merged image node trips the merge assert.
            leading: ExcludeSemantics(
              child: AssetIcon(Assets.icons.emailIcon, size: 22),
            ),
            errorText: errorText,
            readOnly: readOnly,
          );

      Color tint(WidgetTester tester) =>
          tester.widget<FieldIconTint>(find.byType(FieldIconTint)).color;

      testWidgets('the icon and cursor take the focused border colour', (
        tester,
      ) async {
        await tester.pumpApp(field());
        final scheme = Theme.of(
          tester.element(find.byType(TextField)),
        ).colorScheme;
        expect(tint(tester), scheme.onSurface);

        await tester.tap(find.byType(TextField));
        await tester.pump();

        expect(tint(tester), scheme.primary);
        expect(
          tester.widget<TextField>(find.byType(TextField)).cursorColor,
          scheme.primary,
        );
      });

      testWidgets('with an error, they take the error colour', (tester) async {
        await tester.pumpApp(field(errorText: 'Bad email'));
        final scheme = Theme.of(
          tester.element(find.byType(TextField)),
        ).colorScheme;

        await tester.tap(find.byType(TextField));
        await tester.pump();

        expect(tint(tester), scheme.error);
        expect(
          tester.widget<TextField>(find.byType(TextField)).cursorColor,
          scheme.error,
        );
      });

      testWidgets('a read-only field keeps its icon at rest', (tester) async {
        await tester.pumpApp(field(readOnly: true));
        final scheme = Theme.of(
          tester.element(find.byType(TextField)),
        ).colorScheme;

        await tester.tap(find.byType(TextField));
        await tester.pump();

        expect(tint(tester), scheme.onSurface);
      });
    });
  });
}
