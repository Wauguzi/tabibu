// cspell:ignore chandarua kilichotibiwa Nambari Thibitisha huko kila usiku
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/reference_data_helper.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_event.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_state.dart';
import 'package:tabibu/features/alerts/data/models/alert_text_model.dart';
import 'package:tabibu/features/alerts/data/models/guidance_bullet_model.dart';
import 'package:tabibu/features/alerts/data/models/guidance_source_model.dart';
import 'package:tabibu/features/alerts/data/models/public_alert_model.dart';
import 'package:tabibu/features/alerts/data/models/public_health_guidance_model.dart';
import 'package:tabibu/features/alerts/presentation/health_notice_screen.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

class _MockReferenceData extends Mock implements ReferenceDataHelper {}

PublicAlertModel _alert({
  String uid = 'alert-1',
  String diseaseId = 'malaria',
  String countyName = 'Embakasi',
  String headlineEn = 'Malaria in Embakasi',
  String headlineSw = 'Malaria huko Embakasi',
  bool synthetic = false,
  String issuedAt = '2026-10-27T04:00:00Z',
}) => PublicAlertModel(
  uid: uid,
  diseaseId: diseaseId,
  countyName: countyName,
  patientText: {
    'en': AlertTextModel(headline: headlineEn),
    'sw': AlertTextModel(headline: headlineSw),
  },
  issuedAt: issuedAt,
  patientsReleased: true,
  synthetic: synthetic,
);

List<PublicHealthGuidanceModel> _rows() => const [
  PublicHealthGuidanceModel(
    diseaseId: 'malaria',
    bullets: [
      GuidanceBulletModel(
        bulletId: 'b1',
        textEn: 'Sleep under a treated net every night.',
        textSw: 'Lala chini ya chandarua kilichotibiwa kila usiku.',
        sourceId: 'S1',
      ),
      GuidanceBulletModel(
        bulletId: 'b2',
        textEn: 'Hotlines: 719, 0729 471414, 0732 353535.',
        textSw: 'Nambari za dharura: 719, 0729 471414, 0732 353535.',
        sourceId: 'S1',
      ),
      GuidanceBulletModel(
        bulletId: 'b3',
        audience: 'Clinician',
        textEn: 'Confirm every case with a rapid test.',
        textSw: 'Thibitisha kila kesi kwa kipimo cha haraka.',
        sourceId: 'S1',
      ),
    ],
    sources: [
      GuidanceSourceModel(
        sourceId: 'S1',
        title: 'MoH malaria guidance',
        publisher: 'Ministry of Health, Kenya',
        url: 'https://moh.example/malaria',
      ),
    ],
  ),
];

void main() {
  setUpAll(() {
    registerFallbackValue(const PublicAlertReadRequested(alertUid: ''));
  });

  group('HealthNoticeScreen', () {
    late FeatureBlocs blocs;
    late _MockReferenceData referenceData;

    Future<void> pumpScreen(
      WidgetTester tester, {
      PublicAlertsState? state,
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
      String alertUid = 'alert-1',
    }) async {
      when(
        () => blocs.publicAlerts.state,
      ).thenReturn(state ?? PublicAlertsLoadSuccess(alerts: [_alert()]));
      await tester.pumpApp(
        MultiBlocProvider(
          providers: blocs.providers,
          child: HealthNoticeScreen(alertUid: alertUid),
        ),
        themeMode: themeMode,
        locale: locale,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    setUp(() {
      blocs = FeatureBlocs();
      referenceData = _MockReferenceData();
      when(
        () => referenceData.publicHealthGuidance(),
      ).thenAnswer((_) async => _rows());
      getIt.registerSingleton<ReferenceDataHelper>(referenceData);
      when(() => blocs.publicAlerts.add(any())).thenReturn(null);
    });

    tearDown(getIt.reset);

    testWidgets('marks the alert read once shown', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(tester);

      verify(
        () => blocs.publicAlerts.add(
          const PublicAlertReadRequested(alertUid: 'alert-1'),
        ),
      ).called(1);
    });

    testWidgets('uses the alertNotice tone, never attention or error', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(tester);

      final status = Theme.of(
        tester.element(find.byType(HealthNoticeScreen)),
      ).extension<AppStatusColors>()!;
      expect(
        find.byWidgetPredicate(
          (w) => w is Text && w.style?.color == status.alertNotice,
        ),
        findsWidgets,
      );
      expect(
        find.text(l10n.patientHomeNoticeLabel('Embakasi')),
        findsOneWidget,
      );
      expect(find.byType(StatusChip), findsNothing);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is NoticeCard &&
              (w.variant == .attention || w.variant == .error),
        ),
        findsNothing,
      );
    });

    testWidgets('ends with the attribution and the guidance button', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(tester);

      expect(
        find.text(l10n.healthNoticeAttribution('MoH malaria guidance')),
        findsOneWidget,
      );
      expect(find.text(l10n.healthNoticeReadGuidance), findsOneWidget);
      final button = tester.widget<TabibuButton>(
        find.widgetWithText(TabibuButton, l10n.healthNoticeReadGuidance),
      );
      expect(button.onTap, isNotNull);
      // Approval without names: the guidance publisher and the date.
      expect(find.text(l10n.healthNoticeApprovedBy), findsOneWidget);
      expect(find.text('Ministry of Health, Kenya'), findsOneWidget);
      expect(
        find.text(
          l10n.healthNoticeSentBy('Ministry of Health, Kenya', '27 Oct'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Kiswahili shows the translation line when unofficial', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('sw'));
      await pumpScreen(tester, locale: const Locale('sw'));

      expect(find.text('Malaria huko Embakasi'), findsOneWidget);
      expect(
        find.text('Lala chini ya chandarua kilichotibiwa kila usiku.'),
        findsOneWidget,
      );
      expect(find.text(l10n.mohTranslatedByTabibu), findsOneWidget);
    });

    testWidgets('shows the patient bullets only, verbatim', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(tester);

      expect(find.text(l10n.healthNoticeMohAdvises), findsOneWidget);
      expect(
        find.text('Sleep under a treated net every night.'),
        findsOneWidget,
      );
      expect(
        find.text('Hotlines: 719, 0729 471414, 0732 353535.'),
        findsOneWidget,
      );
      expect(find.text('Confirm every case with a rapid test.'), findsNothing);
      expect(find.text('Source: MoH malaria guidance'), findsOneWidget);
      // The PNG's made-up number never appears anywhere.
      expect(
        find.byWidgetPredicate(
          (w) => w is Text && (w.data?.contains('0800 721 316') ?? false),
        ),
        findsNothing,
      );
    });

    testWidgets('a demo alert starts Demo: and carries the banner', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        state: PublicAlertsLoadSuccess(alerts: [_alert(synthetic: true)]),
      );

      expect(find.text('Demo: Malaria in Embakasi'), findsOneWidget);
      expect(find.text(l10n.alertReviewDemoBanner), findsOneWidget);
    });

    testWidgets('the headline is the released text from the bloc', (
      tester,
    ) async {
      _useTallSurface(tester);
      await pumpScreen(
        tester,
        state: PublicAlertsLoadSuccess(
          alerts: [
            _alert(
              countyName: 'Westlands',
              headlineEn: 'Dengue in Westlands',
              headlineSw: 'Dengue huko Westlands',
            ),
          ],
        ),
      );

      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(find.text('Dengue in Westlands'), findsOneWidget);
      expect(
        find.text(l10n.patientHomeNoticeLabel('Westlands')),
        findsOneWidget,
      );
      expect(
        find.text(l10n.healthNoticePublished('27 Oct', 'Westlands')),
        findsOneWidget,
      );
    });

    testWidgets('no gendered pronouns in either language', (tester) async {
      _useTallSurface(tester);
      final pronouns = RegExp(
        r'\b(he|him|his|she|her|hers)\b',
        caseSensitive: false,
      );
      bool hasPronoun(Widget w) =>
          w is Text && (w.data?.contains(pronouns) ?? false);

      await pumpScreen(tester);
      expect(find.byWidgetPredicate(hasPronoun), findsNothing);

      await pumpScreen(tester, locale: const Locale('sw'));
      expect(find.byWidgetPredicate(hasPronoun), findsNothing);
    });

    testWidgets('find a doctor opens the directory', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      when(
        () => blocs.publicAlerts.state,
      ).thenReturn(PublicAlertsLoadSuccess(alerts: [_alert()]));
      final routes = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => MultiBlocProvider(
              providers: blocs.providers,
              child: const HealthNoticeScreen(alertUid: 'alert-1'),
            ),
          ),
          GoRoute(
            path: '/patient/doctors',
            builder: (_, _) => const Text('stub doctors'),
          ),
        ],
      );
      addTearDown(routes.dispose);
      await tester.pumpRouterApp(routes);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text(l10n.healthNoticeFindDoctor));
      await tester.pumpAndSettle();
      expect(find.text('stub doctors'), findsOneWidget);
    });

    testWidgets('loading shows the spinner', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(tester, state: const PublicAlertsLoadInProgress());

      expect(find.byType(LoadingView), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('a missing alert shows not found', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        state: PublicAlertsLoadSuccess(alerts: [_alert()]),
        alertUid: 'no-such-alert',
      );

      expect(find.text(l10n.errorDataNotFound), findsOneWidget);
      verifyNever(
        () => blocs.publicAlerts.add(
          const PublicAlertReadRequested(alertUid: 'no-such-alert'),
        ),
      );
    });

    testWidgets('renders in Swahili, dark, at 1.3x', (tester) async {
      _useTallSurface(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(
        () => tester.platformDispatcher.clearTextScaleFactorTestValue(),
      );
      final l10n = lookupAppLocalizations(const Locale('sw'));
      await pumpScreen(
        tester,
        themeMode: ThemeMode.dark,
        locale: const Locale('sw'),
      );

      expect(find.text('Malaria huko Embakasi'), findsOneWidget);
      expect(find.text(l10n.healthNoticeMohAdvises), findsOneWidget);
      expect(
        find.text(l10n.healthNoticeAttribution('MoH malaria guidance')),
        findsOneWidget,
      );
      expect(find.text(l10n.healthNoticeFindDoctor), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
