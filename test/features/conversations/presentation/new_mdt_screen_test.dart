import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_event.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_state.dart';
import 'package:tabibu/features/conversations/presentation/new_mdt_screen.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_invite_picker.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

PractitionerSession _session() {
  final base = RoleSessions.doctor();
  return PractitionerSession(
    doctor: base.doctor.copyWith(
      uid: 'me',
      specialties: const ['General Practice'],
    ),
    roles: base.roles,
  );
}

PractitionerModel _doc(String uid, String first, String last) =>
    PractitionerModel.empty().copyWith(
      uid: uid,
      title: 'Dr.',
      firstName: first,
      lastName: last,
      specialties: const ['Haematology'],
      isAvailable: true,
    );

void main() {
  late FeatureBlocs blocs;
  late MockAuthBloc authBloc;
  final l10n = lookupAppLocalizations(const Locale('en'));

  final colleague = _doc('dr-2', 'Mary', 'Njeri');
  final meInDirectory = _doc('me', 'Self', 'Self');

  setUpAll(() {
    registerFallbackValue(const MdtReset());
    registerFallbackValue(const DirectoryRequested());
    registerFallbackValue(const CasesRequested(uid: '', role: Role.doctor));
  });

  setUp(() {
    blocs = FeatureBlocs();
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(SignInSuccess(session: _session()));
    when(() => blocs.mdt.add(any())).thenReturn(null);
    when(() => blocs.mdt.state).thenReturn(const MdtInitial());
    when(() => blocs.cases.state).thenReturn(
      const CasesLoadSuccess(
        cases: [
          CaseModel(
            uid: 'c1',
            orderNumber: 'TB-0224',
            doctorUid: 'me',
            pathologistUid: 'path-1',
            pathologistName: 'Dr Path',
            patientName: 'Amina',
          ),
        ],
      ),
    );
    when(() => blocs.directory.state).thenReturn(
      DirectoryLoadSuccess(
        all: [colleague, meInDirectory],
        visible: [colleague, meInDirectory],
      ),
    );
  });

  Future<void> pumpNew(WidgetTester tester, {String caseUid = 'c1'}) async {
    tester.view.physicalSize = const Size(1170, 5000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/mdt/new',
      routes: [
        GoRoute(
          path: '/mdt/new',
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              ...blocs.providers,
            ],
            child: NewMdtScreen(role: .doctor, caseUid: caseUid),
          ),
        ),
      ],
    );
    await tester.pumpRouterApp(router);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('NewMdtScreen', () {
    testWidgets('rule 3: the invite list is the directory minus me', (
      tester,
    ) async {
      await pumpNew(tester);

      expect(find.byType(MdtInvitePicker), findsOneWidget);
      expect(find.textContaining('Mary Njeri'), findsOneWidget);
      expect(find.textContaining('Self Self'), findsNothing);
    });

    testWidgets('Muse 46: a blank subject is refused and open is never sent', (
      tester,
    ) async {
      await pumpNew(tester);

      // Pick the colleague.
      await tester.tap(find.textContaining('Mary Njeri'));
      await tester.pump();

      // Primary without a subject.
      await tester.ensureVisible(find.byType(TabibuButton).last);
      await tester.tap(find.byType(TabibuButton).last);
      await tester.pump();

      expect(find.text(l10n.mdtAboutRequired), findsOneWidget);
      verifyNever(() => blocs.mdt.add(any(that: isA<MdtOpenRequested>())));
    });

    testWidgets('Muse 46: a subject is required and is sent as description', (
      tester,
    ) async {
      await pumpNew(tester);

      await tester.enterText(find.byType(TextField).first, 'Second opinion');
      await tester.tap(find.textContaining('Mary Njeri'));
      await tester.pump();

      await tester.ensureVisible(find.byType(TabibuButton).last);
      await tester.tap(find.byType(TabibuButton).last);
      await tester.pump();

      final open = verify(
        () => blocs.mdt.add(captureAny()),
      ).captured.whereType<MdtOpenRequested>().single;
      expect(open.caseUid, 'c1');
      expect(open.description, 'Second opinion');
      expect(open.inviteeUids, ['dr-2']);
    });
  });
}
