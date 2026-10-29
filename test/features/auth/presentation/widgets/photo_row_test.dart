import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/theme_builder.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/file_picker_service.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';
import 'package:tabibu/features/auth/presentation/widgets/photo_row.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../../../helpers/helpers.dart';

class MockFilePickerService extends Mock implements FilePickerService {}

void main() {
  group('PhotoRow', () {
    Widget row({
      String name = '',
      UploadFile? picture,
      ValueChanged<bool>? onReading,
    }) => PhotoRow(
      name: name,
      title: 'Photo title',
      body: 'Photo body',
      picture: picture,
      onPicked: (_) {},
      onReading: onReading ?? (_) {},
    );

    Finder personIcon() => find.byWidgetPredicate(
      (w) => w is AssetIcon && w.asset.path == Assets.icons.personIcon.path,
    );

    Finder avatarCircle(Color color) => find.byWidgetPredicate(
      (w) =>
          w is Container &&
          (w.decoration as BoxDecoration?)?.shape == BoxShape.circle &&
          (w.decoration as BoxDecoration?)?.color == color,
    );

    UploadFile photo() => UploadFile(
      // A 1x1 PNG; MemoryImage rejects anything undecodable.
      bytes: base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk'
        // cspell:disable-next-line
        '+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
      ),
      contentType: 'image/jpeg',
      name: 'photo.jpg',
    );

    testWidgets('shows Add and the person icon with no photo and no name', (
      tester,
    ) async {
      await tester.pumpApp(row(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();

      expect(find.text('Add'), findsOneWidget);
      expect(personIcon(), findsOneWidget);
      expect(find.text('?'), findsNothing);
      expect(
        avatarCircle(
          buildTheme(Brightness.light).colorScheme.surfaceContainerHigh,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows the person icon in dark mode', (tester) async {
      await tester.pumpApp(row(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();

      expect(personIcon(), findsOneWidget);
      expect(find.text('?'), findsNothing);
      expect(
        avatarCircle(
          buildTheme(Brightness.dark).colorScheme.surfaceContainerHigh,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows Change once a photo is set', (tester) async {
      await tester.pumpApp(row(picture: photo()));
      await tester.pumpAndSettle();

      expect(find.text('Change'), findsOneWidget);
      expect(personIcon(), findsNothing);
    });

    testWidgets('a pending pick reports reading with avatar progress', (
      tester,
    ) async {
      final filePicker = MockFilePickerService();
      getIt.registerSingleton<FilePickerService>(filePicker);
      addTearDown(getIt.reset);
      final pending = Completer<UploadFile?>();
      when(
        () => filePicker.pickPhoto(fromCamera: any(named: 'fromCamera')),
      ).thenAnswer((_) => pending.future);

      final readings = <bool>[];
      await tester.pumpApp(row(name: 'Amina', onReading: readings.add));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from library'));
      // The spinner never settles while the read pends.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(readings, [true]);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      pending.complete(null);
      await tester.pumpAndSettle();

      expect(readings, [true, false]);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
