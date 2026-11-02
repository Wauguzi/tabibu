import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/features/alerts/blocs/alert_review_bloc/alert_review_bloc.dart';
import 'package:tabibu/features/alerts/blocs/alert_review_bloc/alert_review_event.dart';
import 'package:tabibu/features/alerts/blocs/alert_review_bloc/alert_review_state.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_bloc.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_event.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_state.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_bloc.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_event.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_state.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_bloc.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_event.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_state.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_bloc.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_event.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_state.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_bloc.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_event.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_state.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_bloc.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_event.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_state.dart';

class MockNotificationsBloc
    extends MockBloc<NotificationsEvent, NotificationsState>
    implements NotificationsBloc {}

class MockDirectoryBloc extends MockBloc<DirectoryEvent, DirectoryState>
    implements DirectoryBloc {}

class MockAppointmentsBloc
    extends MockBloc<AppointmentsEvent, AppointmentsState>
    implements AppointmentsBloc {}

class MockPublicAlertsBloc
    extends MockBloc<PublicAlertsEvent, PublicAlertsState>
    implements PublicAlertsBloc {}

class MockCasesBloc extends MockBloc<CasesEvent, CasesState>
    implements CasesBloc {}

class MockAlertReviewBloc extends MockBloc<AlertReviewEvent, AlertReviewState>
    implements AlertReviewBloc {}

class MockCaseWorkspaceBloc
    extends MockBloc<CaseWorkspaceEvent, CaseWorkspaceState>
    implements CaseWorkspaceBloc {}

class MockReportReaderBloc
    extends MockBloc<ReportReaderEvent, ReportReaderState>
    implements ReportReaderBloc {}

class MockOrderBloc extends MockBloc<OrderEvent, OrderState>
    implements OrderBloc {}

class MockDeskBloc extends MockBloc<DeskEvent, DeskState> implements DeskBloc {}

/// The app-wide feature blocs as mocks, each starting in its initial state.
/// A screen test sets the states it needs (`whenListen` or `when(() =>
/// blocs.desk.state)`) and passes the set to `pumpRoleApp` or wraps a screen
/// in [providers].
class FeatureBlocs {
  FeatureBlocs() {
    when(() => notifications.state).thenReturn(const NotificationsInitial());
    when(() => directory.state).thenReturn(const DirectoryInitial());
    when(() => appointments.state).thenReturn(const AppointmentsInitial());
    when(() => publicAlerts.state).thenReturn(const PublicAlertsInitial());
    when(() => cases.state).thenReturn(const CasesInitial());
    when(() => desk.state).thenReturn(const DeskInitial());
    when(() => alertReview.state).thenReturn(const AlertReviewInitial());
    when(() => caseWorkspace.state).thenReturn(const CaseWorkspaceInitial());
    when(() => reportReader.state).thenReturn(const ReportReaderInitial());
    when(() => order.state).thenReturn(const OrderInitial());
  }

  final notifications = MockNotificationsBloc();
  final directory = MockDirectoryBloc();
  final appointments = MockAppointmentsBloc();
  final publicAlerts = MockPublicAlertsBloc();
  final cases = MockCasesBloc();
  final desk = MockDeskBloc();
  final alertReview = MockAlertReviewBloc();
  final caseWorkspace = MockCaseWorkspaceBloc();
  final reportReader = MockReportReaderBloc();
  final order = MockOrderBloc();

  List<BlocProvider> get providers => [
    BlocProvider<NotificationsBloc>.value(value: notifications),
    BlocProvider<DirectoryBloc>.value(value: directory),
    BlocProvider<AppointmentsBloc>.value(value: appointments),
    BlocProvider<PublicAlertsBloc>.value(value: publicAlerts),
    BlocProvider<CasesBloc>.value(value: cases),
    BlocProvider<DeskBloc>.value(value: desk),
    BlocProvider<AlertReviewBloc>.value(value: alertReview),
    BlocProvider<CaseWorkspaceBloc>.value(value: caseWorkspace),
    BlocProvider<ReportReaderBloc>.value(value: reportReader),
    BlocProvider<OrderBloc>.value(value: order),
  ];
}
