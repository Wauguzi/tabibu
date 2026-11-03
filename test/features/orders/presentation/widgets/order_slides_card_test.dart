import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/file_picker_service.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_item.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_upload_bloc.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_upload_event.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_upload_state.dart';
import 'package:tabibu/features/orders/presentation/widgets/order_slides_card.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

final AppLocalizations _en = lookupAppLocalizations(const Locale('en'));
final AppLocalizations _sw = lookupAppLocalizations(const Locale('sw'));

class MockFilePickerService extends Mock implements FilePickerService {}

SlideItem _slide({
  String localId = 's1',
  String fileName = 'slide-a.jpg',
  int bytes = 2048,
  String contentType = 'image/jpeg',
  double? micronsPerPixel,
  SlideUploadStatus status = .picked,
  AppError? error,
}) => SlideItem(
  localId: localId,
  fileName: fileName,
  bytes: Uint8List(bytes),
  contentType: contentType,
  micronsPerPixel: micronsPerPixel,
  status: status,
  error: error,
);

void main() {
  setUpAll(() => registerFallbackValue(const SlideUploadReset()));

  group('OrderSlidesCard', () {
    late FeatureBlocs blocs;
    late MockFilePickerService filePicker;

    setUp(() {
      blocs = FeatureBlocs();
      filePicker = MockFilePickerService();
      getIt.registerSingleton<FilePickerService>(filePicker);
    });

    tearDown(getIt.reset);

    Future<void> pumpCard(
      WidgetTester tester, {
      SlideUploadState upload = const SlideUploadInitial(),
      Locale? locale,
      ThemeMode themeMode = ThemeMode.light,
      double textScale = 1,
    }) async {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      when(() => blocs.slideUpload.state).thenReturn(upload);
      await tester.pumpApp(
        MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: BlocProvider<SlideUploadBloc>.value(
            value: blocs.slideUpload,
            child: const OrderSlidesCard(caseUid: 'case-1', doctorUid: 'doc-1'),
          ),
        ),
        locale: locale,
        themeMode: themeMode,
      );
      await tester.pump();
    }

    testWidgets('empty: title, body, Add and a closed Upload', (tester) async {
      await pumpCard(tester);

      expect(find.text(_en.orderSlidesTitle), findsOneWidget);
      expect(find.text(_en.orderSlidesBody), findsOneWidget);
      expect(find.text(_en.orderSlidesAdd), findsOneWidget);
      final upload = tester.widget<TabibuButton>(
        find.widgetWithText(TabibuButton, _en.orderSlidesUpload),
      );
      expect(upload.onTap, isNull);
    });

    testWidgets('Add slides sends the picked files to the bloc', (
      tester,
    ) async {
      final files = [
        UploadFile(
          bytes: Uint8List(10),
          contentType: 'image/jpeg',
          name: 'a.jpg',
        ),
        UploadFile(
          bytes: Uint8List(12),
          contentType: 'image/png',
          name: 'b.png',
        ),
      ];
      when(() => filePicker.pickSlides()).thenAnswer((_) async => files);
      await pumpCard(tester);

      await tester.tap(find.text(_en.orderSlidesAdd));
      await tester.pump();

      final captured = verify(
        () => blocs.slideUpload.add(captureAny<SlideUploadEvent>()),
      ).captured;
      final picked = captured.single as SlidesPicked;
      expect(picked.picks.map((p) => p.fileName), ['a.jpg', 'b.png']);
      expect(picked.picks.map((p) => p.contentType), [
        'image/jpeg',
        'image/png',
      ]);
      expect(picked.picks[0].bytes, same(files[0].bytes));
    });

    testWidgets('a cancelled pick sends nothing', (tester) async {
      when(() => filePicker.pickSlides()).thenAnswer((_) async => []);
      await pumpCard(tester);

      await tester.tap(find.text(_en.orderSlidesAdd));
      await tester.pump();

      verifyNever(() => blocs.slideUpload.add(any()));
    });

    testWidgets('a refused pick says so inline', (tester) async {
      when(() => filePicker.pickSlides()).thenThrow(AppError.fileTooLarge);
      await pumpCard(tester);

      await tester.tap(find.text(_en.orderSlidesAdd));
      await tester.pump();

      expect(find.text(_en.errorFileTooLarge), findsOneWidget);
      verifyNever(() => blocs.slideUpload.add(any()));
    });

    testWidgets('a row shows the file, its size and a pixel field', (
      tester,
    ) async {
      await pumpCard(
        tester,
        upload: SlideUploadEditing(caseUid: 'case-1', slides: [_slide()]),
      );

      expect(find.text('slide-a.jpg'), findsOneWidget);
      expect(find.text(_en.orderSlidesMetaJpeg('2.0 KB')), findsOneWidget);
      expect(find.text(_en.orderSlidesPixelSizeLabel), findsOneWidget);
    });

    testWidgets('a valid pixel size is sent; garbage is a field error', (
      tester,
    ) async {
      await pumpCard(
        tester,
        upload: SlideUploadEditing(caseUid: 'case-1', slides: [_slide()]),
      );
      final field = find.byType(TabibuTextField);

      await tester.enterText(field, '0.25');
      await tester.pump();
      verify(
        () => blocs.slideUpload.add(
          const SlidePixelSizeSet(localId: 's1', micronsPerPixel: 0.25),
        ),
      ).called(1);

      await tester.enterText(field, 'abc');
      await tester.pump();
      expect(find.text(_en.orderSlidesPixelSizeInvalid), findsOneWidget);

      await tester.enterText(field, '101');
      await tester.pump();
      expect(find.text(_en.orderSlidesPixelSizeInvalid), findsOneWidget);
      verifyNever(
        () => blocs.slideUpload.add(
          const SlidePixelSizeSet(localId: 's1', micronsPerPixel: 101),
        ),
      );
    });

    testWidgets('an upload patch never wipes a half-typed size', (
      tester,
    ) async {
      final editing = SlideUploadEditing(caseUid: 'case-1', slides: [_slide()]);
      when(() => blocs.slideUpload.state).thenReturn(editing);
      whenListen(
        blocs.slideUpload,
        Stream.fromIterable([
          SlideUploadInProgress(caseUid: 'case-1', slides: [_slide()]),
        ]),
        initialState: editing,
      );
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpApp(
        BlocProvider<SlideUploadBloc>.value(
          value: blocs.slideUpload,
          child: const OrderSlidesCard(caseUid: 'case-1', doctorUid: 'doc-1'),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TabibuTextField), '0.');
      await tester.pump();

      expect(find.text('0.'), findsOneWidget);
    });

    testWidgets('remove sends SlideRemoved; settled rows have none', (
      tester,
    ) async {
      await pumpCard(
        tester,
        upload: SlideUploadEditing(
          caseUid: 'case-1',
          slides: [
            _slide(fileName: 'picked.jpg'),
            _slide(
              localId: 's2',
              fileName: 'failed.jpg',
              status: .failed,
              error: .slideNotUploaded,
            ),
            _slide(
              localId: 's3',
              fileName: 'busy.jpg',
              status: .uploading,
              micronsPerPixel: 0.25,
            ),
            _slide(
              localId: 's4',
              fileName: 'done.jpg',
              status: .uploaded,
              micronsPerPixel: 0.25,
            ),
          ],
        ),
      );

      expect(
        find.bySemanticsLabel(_en.orderSlidesRemove('picked.jpg')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(_en.orderSlidesRemove('failed.jpg')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(_en.orderSlidesRemove('busy.jpg')),
        findsNothing,
      );
      expect(
        find.bySemanticsLabel(_en.orderSlidesRemove('done.jpg')),
        findsNothing,
      );

      await tester.tap(
        find.bySemanticsLabel(_en.orderSlidesRemove('picked.jpg')),
      );
      await tester.pump();
      verify(
        () => blocs.slideUpload.add(const SlideRemoved(localId: 's1')),
      ).called(1);
    });

    testWidgets('Upload sends the request; closed without pending rows', (
      tester,
    ) async {
      await pumpCard(
        tester,
        upload: SlideUploadEditing(
          caseUid: 'case-1',
          slides: [_slide(micronsPerPixel: 0.25)],
        ),
      );

      await tester.tap(find.text(_en.orderSlidesUpload));
      await tester.pump();
      verify(
        () => blocs.slideUpload.add(
          const SlideUploadRequested(uid: 'doc-1', caseUid: 'case-1'),
        ),
      ).called(1);
    });

    testWidgets('Upload stays closed when every row is uploaded', (
      tester,
    ) async {
      await pumpCard(
        tester,
        upload: SlideUploadSuccess(
          caseUid: 'case-1',
          slides: [_slide(status: .uploaded, micronsPerPixel: 0.25)],
        ),
      );

      final upload = tester.widget<TabibuButton>(
        find.widgetWithText(TabibuButton, _en.orderSlidesUpload),
      );
      expect(upload.onTap, isNull);
    });

    testWidgets('a partial success keeps Retry on the failed rows', (
      tester,
    ) async {
      await pumpCard(
        tester,
        upload: SlideUploadSuccess(
          caseUid: 'case-1',
          slides: [
            _slide(
              fileName: 'done.jpg',
              status: .uploaded,
              micronsPerPixel: 0.25,
            ),
            _slide(
              localId: 's2',
              fileName: 'failed.jpg',
              status: .failed,
              error: .slideNotUploaded,
              micronsPerPixel: 0.25,
            ),
          ],
        ),
      );

      expect(find.text(_en.errorSlideNotUploaded), findsOneWidget);
      expect(find.text(_en.orderSlidesUploaded), findsOneWidget);
      expect(
        find.widgetWithText(TabibuButton, _en.commonRetry),
        findsOneWidget,
      );

      await tester.tap(find.text(_en.commonRetry));
      await tester.pump();
      verify(
        () => blocs.slideUpload.add(
          const SlideUploadRequested(uid: 'doc-1', caseUid: 'case-1'),
        ),
      ).called(1);
    });

    testWidgets('an uploading row spins and locks its size', (tester) async {
      await pumpCard(
        tester,
        upload: SlideUploadInProgress(
          caseUid: 'case-1',
          slides: [_slide(status: .uploading, micronsPerPixel: 0.25)],
        ),
      );

      expect(find.text(_en.orderSlidesUploading), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      final field = tester.widget<TabibuTextField>(
        find.byType(TabibuTextField),
      );
      expect(field.readOnly, isTrue);
      // The loading button shows a spinner instead of its label.
      final buttons = tester
          .widgetList<TabibuButton>(find.byType(TabibuButton))
          .toList();
      expect(buttons.where((b) => b.isLoading), hasLength(1));
    });

    testWidgets('a failure of the whole request says so inline', (
      tester,
    ) async {
      await pumpCard(
        tester,
        upload: SlideUploadFailure(
          error: .tooManySlides,
          caseUid: 'case-1',
          slides: [_slide()],
        ),
      );

      expect(find.text(_en.errorTooManySlides), findsOneWidget);
      expect(find.text('slide-a.jpg'), findsOneWidget);
    });

    testWidgets("another case's rows are dropped, never shown", (tester) async {
      await pumpCard(
        tester,
        upload: SlideUploadEditing(
          caseUid: 'case-9',
          slides: [_slide(fileName: 'other.jpg')],
        ),
      );

      verify(() => blocs.slideUpload.add(const SlideUploadReset())).called(1);
      expect(find.text('other.jpg'), findsNothing);
      final add = tester.widget<TabibuButton>(
        find.widgetWithText(TabibuButton, _en.orderSlidesAdd),
      );
      expect(add.onTap, isNull);
    });

    testWidgets("another case's running upload is left alone", (tester) async {
      await pumpCard(
        tester,
        upload: SlideUploadInProgress(
          caseUid: 'case-9',
          slides: [_slide(fileName: 'other.jpg', status: .uploading)],
        ),
      );

      verifyNever(() => blocs.slideUpload.add(any()));
      expect(find.text('other.jpg'), findsNothing);
    });

    testWidgets('renders in Swahili, dark, at 1.3x', (tester) async {
      await pumpCard(
        tester,
        locale: const Locale('sw'),
        themeMode: ThemeMode.dark,
        textScale: 1.3,
        upload: SlideUploadEditing(
          caseUid: 'case-1',
          slides: [
            _slide(micronsPerPixel: 0.25),
            _slide(
              localId: 's2',
              fileName: 'slide-b.png',
              contentType: 'image/png',
              status: .failed,
              error: .slideNotReserved,
            ),
          ],
        ),
      );

      expect(find.text(_sw.orderSlidesTitle), findsOneWidget);
      expect(find.text(_sw.orderSlidesBody), findsOneWidget);
      expect(find.text(_sw.orderSlidesAdd), findsOneWidget);
      expect(find.text(_sw.orderSlidesUpload), findsOneWidget);
      expect(find.text(_sw.errorSlideNotReserved), findsOneWidget);
      expect(
        find.widgetWithText(TabibuButton, _sw.commonRetry),
        findsOneWidget,
      );
    });

    testWidgets('with semantics on, mixed rows report without crashing', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await pumpCard(
          tester,
          upload: SlideUploadEditing(
            caseUid: 'case-1',
            slides: [
              _slide(micronsPerPixel: 0.25),
              _slide(
                localId: 's2',
                fileName: 'done.jpg',
                status: .uploaded,
                micronsPerPixel: 0.5,
              ),
            ],
          ),
        );

        expect(
          find.bySemanticsLabel(_en.orderSlidesRemove('slide-a.jpg')),
          findsOneWidget,
        );
      } finally {
        semantics.dispose();
      }
    });
  });
}
