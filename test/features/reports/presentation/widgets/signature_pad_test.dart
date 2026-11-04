import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/tabibu_button.dart';
import 'package:tabibu/features/reports/presentation/widgets/signature_pad.dart';

import '../../../../helpers/helpers.dart';

void main() {
  const pngMagic = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];

  Future<SignaturePadController> pumpPad(WidgetTester tester) async {
    final controller = SignaturePadController();
    await tester.pumpApp(
      SizedBox(
        width: 343,
        child: SignaturePad(
          controller: controller,
          hint: 'Sign here',
          clearLabel: 'Clear',
          semanticLabel: 'Signature',
        ),
      ),
    );
    return controller;
  }

  Future<void> drawStroke(WidgetTester tester) async {
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(GestureDetector)),
    );
    await gesture.moveBy(const Offset(60, 0));
    await gesture.moveBy(const Offset(40, 20));
    await gesture.up();
    await tester.pump();
  }

  group('SignaturePad', () {
    testWidgets('empty exports null and hides Clear', (tester) async {
      final controller = await pumpPad(tester);

      expect(controller.isEmpty, isTrue);
      expect(await controller.toPngBase64(), isNull);
      expect(find.text('Sign here'), findsOneWidget);
      expect(find.text('Clear'), findsNothing);
    });

    testWidgets('a drag makes it non-empty, Clear empties it', (tester) async {
      final controller = await pumpPad(tester);
      await drawStroke(tester);

      expect(controller.isEmpty, isFalse);
      expect(find.text('Clear'), findsOneWidget);
      expect(find.text('Sign here'), findsNothing);

      await tester.tap(find.byType(TabibuButton));
      await tester.pump();

      expect(controller.isEmpty, isTrue);
      expect(find.text('Clear'), findsNothing);
      expect(await controller.toPngBase64(), isNull);
    });

    testWidgets(
      'PNG is at least 300 px wide and starts with the PNG signature',
      (tester) async {
        final controller = await pumpPad(tester);
        await drawStroke(tester);
        // toImage must run on the live binding, not the test zone.
        final b64 = await tester.runAsync(controller.toPngBase64);
        expect(b64, isNotNull);
        final bytes = base64Decode(b64!);
        expect(bytes.sublist(0, 8), pngMagic);
        expect(
          ByteData.sublistView(Uint8List.fromList(bytes)).getUint32(16),
          greaterThanOrEqualTo(300),
        );
      },
    );

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          SignaturePad(
            controller: SignaturePadController(),
            hint: 'Sign here',
            clearLabel: 'Clear',
            semanticLabel: 'Signature',
          ),
          themeMode: mode,
        );
        expect(find.byType(SignaturePad), findsOneWidget);
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
          child: SignaturePad(
            controller: SignaturePadController(),
            hint: 'Sign here',
            clearLabel: 'Clear',
            semanticLabel: 'Signature',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
    group('signaturePixelRatio', () {
      test('3x on a phone-wide pad', () {
        expect(signaturePixelRatio(const Size(343, 160)), 3);
      });

      test('a tablet-wide pad stays within 2000 px', () {
        const size = Size(900, 200);
        expect(size.width * signaturePixelRatio(size), lessThanOrEqualTo(2000));
      });

      test('a narrow pad still reaches 300 px', () {
        const size = Size(80, 40);
        expect(
          size.width * signaturePixelRatio(size),
          greaterThanOrEqualTo(300),
        );
      });
    });
  });
}
