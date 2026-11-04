import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/tabibu_text_field.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../helpers/helpers.dart';

void main() {
  group('TabibuTextField', () {
    testWidgets('a bordered field draws its border before focus', (
      tester,
    ) async {
      await tester.pumpApp(
        const Column(
          children: [
            TabibuTextField(label: 'Plain'),
            TabibuTextField(label: 'Boxed', bordered: true),
          ],
        ),
      );

      BorderSide side(String label) {
        final field = tester.widget<TextField>(
          find.descendant(
            of: find.byWidgetPredicate(
              (w) => w is TabibuTextField && w.label == label,
            ),
            matching: find.byType(TextField),
          ),
        );
        return (field.decoration!.enabledBorder! as OutlineInputBorder)
            .borderSide;
      }

      expect(side('Plain'), BorderSide.none);
      expect(side('Boxed').style, BorderStyle.solid);
      expect(side('Boxed').width, greaterThan(0));
    });

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

      testWidgets('a bare leading icon hides from screen readers', (
        tester,
      ) async {
        await tester.pumpApp(
          TabibuTextField(
            label: 'Email',
            leading: AssetIcon(Assets.icons.emailIcon, size: 22),
          ),
        );
        await tester.pumpAndSettle();

        // Decorative: the label carries the meaning, and a merged image
        // node trips the merge assert when the screen is pushed.
        expect(
          find.ancestor(
            of: find.byType(AssetIcon),
            matching: find.byType(ExcludeSemantics),
          ),
          findsOneWidget,
        );
      });
    });

    group('paste sanitisation', () {
      Future<void> pumpPasteField(
        WidgetTester tester, {
        required int maxLength,
        required List<int> cuts,
        double textScale = 1,
        Locale? locale,
      }) async {
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final controller = TextEditingController();
        addTearDown(controller.dispose);
        await tester.pumpApp(
          TabibuTextField(
            label: 'Diagnosis',
            controller: controller,
            maxLines: 4,
            maxLength: maxLength,
            sanitizePaste: true,
            onPasteCut: cuts.add,
          ),
          locale: locale,
        );
      }

      testWidgets('pasting 3,000 into a 2,000 field keeps 2,000 and notices '
          '(1.0x en)', (tester) async {
        final cuts = <int>[];
        await pumpPasteField(tester, maxLength: 2000, cuts: cuts);
        await tester.enterText(find.byType(TextField), 'x' * 3000);
        await tester.pump();
        await tester.pump();
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.controller!.text.length, lessThanOrEqualTo(2000));
        expect(cuts, [2000]);
      });

      testWidgets('pasting 3,000 notices at 2.0x and in Swahili', (
        tester,
      ) async {
        final cuts = <int>[];
        await pumpPasteField(
          tester,
          maxLength: 2000,
          cuts: cuts,
          textScale: 2,
          locale: const Locale('sw'),
        );
        await tester.enterText(find.byType(TextField), 'y' * 3000);
        await tester.pump();
        await tester.pump();
        expect(cuts, [2000]);
        final l10n = lookupAppLocalizations(const Locale('sw'));
        // Callers show this string; the field itself only reports the cut.
        expect(l10n.pasteCutAtLimit(2000), contains('2000'));
      });

      testWidgets('pasting 1,500 into a 2,000 field shows no cut', (
        tester,
      ) async {
        final cuts = <int>[];
        await pumpPasteField(tester, maxLength: 2000, cuts: cuts);
        await tester.enterText(find.byType(TextField), 'z' * 1500);
        await tester.pump();
        await tester.pump();
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'z' * 1500,
        );
        expect(cuts, isEmpty);
      });

      testWidgets('pasting a zero-width character leaves none in the field', (
        tester,
      ) async {
        final cuts = <int>[];
        await pumpPasteField(tester, maxLength: 2000, cuts: cuts);
        await tester.enterText(find.byType(TextField), 'hello \u200B world');
        await tester.pump();
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'hello  world',
        );
      });

      testWidgets('order notes paste cuts at 2,000 the same way', (
        tester,
      ) async {
        final cuts = <int>[];
        await pumpPasteField(tester, maxLength: 2000, cuts: cuts);
        await tester.enterText(find.byType(TextField), 'n' * 2500);
        await tester.pump();
        await tester.pump();
        expect(cuts, [2000]);
      });

      testWidgets('PIN and accession fields are not sanitised', (tester) async {
        final controller = TextEditingController();
        addTearDown(controller.dispose);
        await tester.pumpApp(
          TabibuTextField(
            label: 'Accession',
            controller: controller,
            maxLength: 30,
          ),
        );
        await tester.enterText(find.byType(TextField), 'AB\u200B12');
        await tester.pump();
        expect(controller.text, 'AB\u200B12');
      });
    });

    group('tap outside dismisses', () {
      Future<void> pumpField(
        WidgetTester tester, {
        bool dismiss = true,
        bool readOnly = false,
        Locale? locale,
      }) => tester.pumpApp(
        Column(
          children: [
            TabibuTextField(
              label: 'Name',
              dismissKeyboardOnTapOutside: dismiss,
              readOnly: readOnly,
            ),
            const Expanded(child: ColoredBox(color: Color(0x00000000))),
          ],
        ),
        locale: locale,
      );

      FocusNode fieldNode(WidgetTester tester, [int index = 0]) =>
          tester.widget<TextField>(find.byType(TextField).at(index)).focusNode!;

      testWidgets('a tap outside drops focus and hides the keyboard', (
        tester,
      ) async {
        await pumpField(tester);
        await tester.tap(find.byType(TextField));
        await tester.pump();
        expect(fieldNode(tester).hasPrimaryFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);

        await tester.tapAt(const Offset(400, 590));
        await tester.pump();
        expect(fieldNode(tester).hasPrimaryFocus, isFalse);
        expect(tester.testTextInput.isVisible, isFalse);
      });

      testWidgets('a tap outside drops focus in Swahili too', (tester) async {
        await pumpField(tester, locale: const Locale('sw'));
        await tester.tap(find.byType(TextField));
        await tester.pump();
        expect(fieldNode(tester).hasPrimaryFocus, isTrue);

        await tester.tapAt(const Offset(400, 590));
        await tester.pump();
        expect(fieldNode(tester).hasPrimaryFocus, isFalse);
        expect(tester.testTextInput.isVisible, isFalse);
      });

      testWidgets('a tap on a button fires it and drops focus', (tester) async {
        var fired = false;
        await tester.pumpApp(
          Column(
            children: [
              const TabibuTextField(label: 'Name'),
              TextButton(
                onPressed: () => fired = true,
                child: const Text('Save'),
              ),
            ],
          ),
        );
        await tester.tap(find.byType(TextField));
        await tester.pump();
        expect(fieldNode(tester).hasPrimaryFocus, isTrue);

        await tester.tap(find.text('Save'));
        await tester.pump();
        expect(fired, isTrue);
        expect(fieldNode(tester).hasPrimaryFocus, isFalse);
        expect(tester.testTextInput.isVisible, isFalse);
      });

      testWidgets('a tap on another field moves focus, input stays open', (
        tester,
      ) async {
        await tester.pumpApp(
          const Column(
            children: [
              TabibuTextField(label: 'First'),
              TabibuTextField(label: 'Second'),
            ],
          ),
        );
        final fields = find.byType(TextField);
        await tester.tap(fields.first);
        await tester.pump();
        expect(fieldNode(tester).hasPrimaryFocus, isTrue);

        await tester.tap(fields.last);
        await tester.pump();
        expect(fieldNode(tester).hasPrimaryFocus, isFalse);
        expect(fieldNode(tester, 1).hasPrimaryFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);
      });

      testWidgets('the opt-out keeps focus on a tap outside', (tester) async {
        await pumpField(tester, dismiss: false);
        await tester.tap(find.byType(TextField));
        await tester.pump();
        expect(fieldNode(tester).hasPrimaryFocus, isTrue);

        await tester.tapAt(const Offset(400, 590));
        await tester.pump();
        expect(fieldNode(tester).hasPrimaryFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);
      });

      testWidgets('a read-only field drops focus cleanly', (tester) async {
        await pumpField(tester, readOnly: true);
        await tester.tap(find.byType(TextField));
        await tester.pump();
        // Focused for selection, but no keyboard for a read-only field.
        expect(fieldNode(tester).hasPrimaryFocus, isTrue);
        expect(tester.testTextInput.isVisible, isFalse);

        await tester.tapAt(const Offset(400, 590));
        await tester.pump();
        expect(fieldNode(tester).hasPrimaryFocus, isFalse);
      });

      Future<void> toolbarKeepsFocus(WidgetTester tester) async {
        final controller = TextEditingController(text: 'Amina');
        addTearDown(controller.dispose);
        await tester.pumpApp(
          Column(
            children: [
              TabibuTextField(label: 'Name', controller: controller),
              const Expanded(child: ColoredBox(color: Color(0x00000000))),
            ],
          ),
        );
        await tester.tap(find.byType(TextField));
        await tester.pump();
        controller.selection = const TextSelection(
          baseOffset: 0,
          extentOffset: 5,
        );
        tester
            .state<EditableTextState>(find.byType(EditableText))
            .showToolbar();
        await tester.pumpAndSettle();
        expect(find.text('Copy'), findsOneWidget);

        await tester.tap(find.text('Copy'));
        await tester.pump();
        expect(fieldNode(tester).hasPrimaryFocus, isTrue);
      }

      testWidgets('a tap on the selection toolbar keeps focus', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        try {
          await toolbarKeepsFocus(tester);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    });
  });
}
