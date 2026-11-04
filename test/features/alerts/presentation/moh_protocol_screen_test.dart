// cspell:ignore Tafuta matibabu inayoshukiwa homa chini fomu
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/reference_data_helper.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/data/models/guidance_bullet_model.dart';
import 'package:tabibu/features/alerts/data/models/guidance_source_model.dart';
import 'package:tabibu/features/alerts/data/models/public_health_guidance_model.dart';
import 'package:tabibu/features/alerts/presentation/moh_protocol_screen.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

class _MockReferenceData extends Mock implements ReferenceDataHelper {}

const _vhf = PublicHealthGuidanceModel(
  diseaseId: 'ebola_virus_disease',
  bullets: [
    GuidanceBulletModel(
      bulletId: 'p1',
      textEn: 'Seek care promptly.',
      textSw: 'Tafuta matibabu haraka.',
      sourceId: 'S15',
    ),
    GuidanceBulletModel(
      bulletId: 'c1',
      audience: 'Clinician',
      textEn: 'Suspected VHF: fever under 3 weeks.',
      textSw: 'VHF inayoshukiwa: homa ya chini ya wiki 3.',
      sourceId: 'S1',
    ),
    GuidanceBulletModel(
      bulletId: 'c2',
      audience: 'Clinician',
      textEn: 'Report immediately on form MOH 502.',
      textSw: 'Ripoti mara moja kwa fomu MOH 502.',
      sourceId: 'S1',
    ),
  ],
  sources: [
    GuidanceSourceModel(
      sourceId: 'S1',
      title: 'IDSR Clinicians Handbook',
      url: 'https://example.org/idsr.pdf',
    ),
    GuidanceSourceModel(
      sourceId: 'S15',
      title: 'Public advisory',
      url: 'https://example.org/advisory',
    ),
  ],
);

void main() {
  group('MohProtocolScreen (F-13)', () {
    late _MockReferenceData referenceData;

    setUp(() {
      referenceData = _MockReferenceData();
      when(
        () => referenceData.publicHealthGuidance(),
      ).thenAnswer((_) async => [_vhf]);
      getIt.registerSingleton<ReferenceDataHelper>(referenceData);
    });

    tearDown(getIt.reset);

    Future<void> pump(
      WidgetTester tester,
      String id, {
      Locale locale = const Locale('en'),
    }) async {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpApp(MohProtocolScreen(protocolId: id), locale: locale);
      await tester.pumpAndSettle();
    }

    testWidgets('shows the clinician steps verbatim, with their source', (
      tester,
    ) async {
      final en = lookupAppLocalizations(const Locale('en'));
      await pump(tester, 'VhfProtocol');

      expect(find.text(en.mohVhfTitle), findsOneWidget);
      expect(find.text('Suspected VHF: fever under 3 weeks.'), findsOneWidget);
      expect(find.text('Report immediately on form MOH 502.'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      // Patient guidance and its source aren't the clinician's protocol.
      expect(find.text('Seek care promptly.'), findsNothing);
      expect(
        find.text(en.mohSource('IDSR Clinicians Handbook')),
        findsOneWidget,
      );
      expect(find.text(en.mohSource('Public advisory')), findsNothing);
      expect(find.text(en.mohCaption), findsOneWidget);
    });

    testWidgets("in Kiswahili, says the translation is Tabibu's", (
      tester,
    ) async {
      final sw = lookupAppLocalizations(const Locale('sw'));
      await pump(tester, 'VhfProtocol', locale: const Locale('sw'));

      expect(
        find.text('VHF inayoshukiwa: homa ya chini ya wiki 3.'),
        findsOneWidget,
      );
      expect(find.text(sw.mohTranslatedByTabibu), findsOneWidget);
    });

    testWidgets('an unknown advice shows no protocol and reads nothing', (
      tester,
    ) async {
      final en = lookupAppLocalizations(const Locale('en'));
      await pump(tester, 'malaria');

      expect(find.text(en.mohUnknown), findsOneWidget);
      expect(find.byType(NoticeCard), findsNothing);
      verifyNever(() => referenceData.publicHealthGuidance());
    });

    testWidgets('lays out in Swahili at 1.3x', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.view.physicalSize = const Size(1170, 6000);
      await pump(tester, 'VhfProtocol', locale: const Locale('sw'));

      expect(tester.takeException(), isNull);
    });
  });
}
