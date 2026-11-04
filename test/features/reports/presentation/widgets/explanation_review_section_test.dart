import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_event.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_state.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/report_text_model.dart';
import 'package:tabibu/features/reports/presentation/widgets/explanation_draft_card.dart';
import 'package:tabibu/features/reports/presentation/widgets/explanation_review_section.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  setUpAll(() {
    registerFallbackValue(const ExplanationDecisionRequested(language: ''));
    registerFallbackValue(
      const ReportReaderOpened(uid: '', role: Role.doctor, caseUid: ''),
    );
  });

  group('ExplanationReviewSection', () {
    late FeatureBlocs blocs;

    Future<void> settleSheet(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    Finder draftMore() => find.descendant(
      of: find.byType(ExplanationDraftCard),
      matching: find.byType(MoreButton),
    );

    Future<void> pumpSection(WidgetTester tester) async {
      when(() => blocs.reportReader.state).thenReturn(
        const ReportReaderLoadSuccess(
          role: Role.doctor,
          caseUid: 'case-1',
          report: PathologyReportModel(
            uid: 'rep-1',
            caseUid: 'case-1',
            releasedToPatient: true,
          ),
          explanations: {
            'en': ReportTextModel(
              machineText: {
                'What was found': 'A small lump was found.',
                'What it means': 'It is not cancer.',
              },
            ),
          },
        ),
      );
      await tester.pumpApp(
        MultiBlocProvider(
          providers: blocs.providers,
          child: const SingleChildScrollView(
            child: ExplanationReviewSection(
              caseUid: 'case-1',
              patientName: 'Amina Wambui',
            ),
          ),
        ),
      );
      await tester.pump();
    }

    setUp(() {
      blocs = FeatureBlocs();
      when(() => blocs.reportReader.add(any())).thenReturn(null);
    });

    testWidgets('the reject confirmation names what happens', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpSection(tester);

      await tester.tap(draftMore());
      await settleSheet(tester);
      await tester.tap(find.text(l10n.alertReviewReject));
      await settleSheet(tester);

      expect(find.text(l10n.explanationRejectBody), findsOneWidget);
      expect(find.text(l10n.commonCancel), findsOneWidget);

      await tester.tap(find.text(l10n.alertReviewReject));
      await settleSheet(tester);
      verify(
        () => blocs.reportReader.add(
          const ExplanationDecisionRequested(language: 'en', reject: true),
        ),
      ).called(1);
    });

    Future<void> pumpEmptyPhase(
      WidgetTester tester,
      ExplanationDraftPhase phase,
    ) async {
      when(() => blocs.reportReader.state).thenReturn(
        ReportReaderLoadSuccess(
          uid: 'doc-1',
          role: Role.doctor,
          caseUid: 'case-1',
          report: const PathologyReportModel(
            uid: 'rep-1',
            caseUid: 'case-1',
            releasedToPatient: true,
          ),
          explanationPhase: phase,
        ),
      );
      await tester.pumpApp(
        MultiBlocProvider(
          providers: blocs.providers,
          child: const SingleChildScrollView(
            child: ExplanationReviewSection(
              caseUid: 'case-1',
              patientName: 'Amina Wambui',
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('pending shows the waiting copy and Retry', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpEmptyPhase(tester, .pending);

      expect(find.text(l10n.explanationWaitingForDraft), findsOneWidget);
      expect(find.text(l10n.commonRetry), findsOneWidget);
      expect(find.text(l10n.explanationFailedBody), findsNothing);
      expect(find.text(l10n.explanationRejectedBody), findsNothing);
    });

    testWidgets('failed shows the failure line and no action to fake', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpEmptyPhase(tester, .failed);

      expect(find.text(l10n.explanationFailedBody), findsOneWidget);
      expect(find.text(l10n.commonRetry), findsNothing);
      expect(find.text(l10n.explanationWaitingForDraft), findsNothing);
    });

    testWidgets('rejected says it was set aside and offers nothing to fake', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpEmptyPhase(tester, .rejected);

      expect(find.text(l10n.explanationRejectedBody), findsOneWidget);
      expect(find.text(l10n.commonRetry), findsNothing);
      expect(find.text(l10n.explanationWaitingForDraft), findsNothing);
    });
  });
}
