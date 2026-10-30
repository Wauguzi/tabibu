import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/avatar.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../helpers/helpers.dart';

void main() {
  group('Avatar', () {
    testWidgets('falls back to initials', (tester) async {
      await tester.pumpApp(
        const Column(
          children: [
            Avatar(name: 'Amina Wambui'),
            Avatar(name: 'Madonna'),
          ],
        ),
      );

      expect(find.text('AW'), findsOneWidget);
      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('shows the photo when provided', (tester) async {
      await tester.pumpApp(
        Avatar(
          name: 'Amina Wambui',
          image: Assets.images.portraits.portrait1.provider(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a photo that fails to load shows the initials', (
      tester,
    ) async {
      await tester.pumpApp(
        Avatar(
          name: 'Amina Wambui',
          image: MemoryImage(Uint8List.fromList([1, 2, 3])),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();

      expect(find.text('AW'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(Image),
          matching: find.byType(RawImage),
        ),
        findsNothing,
      );
    });

    testWidgets('rounds the tile variant into a rectangle', (tester) async {
      await tester.pumpApp(
        const Column(
          children: [
            Avatar(name: 'Amina Wambui'),
            Avatar.tile(name: 'Amina Wambui'),
          ],
        ),
      );

      expect(find.byType(ClipOval), findsOneWidget);
      final clipped = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipped.borderRadius, BorderRadius.circular(14));
      expect(find.text('AW'), findsNWidgets(2));
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(const Avatar(name: 'Amina Wambui'));

      expect(tester.takeException(), isNull);
    });
  });
}
