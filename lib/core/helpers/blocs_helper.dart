import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/alerts/blocs/alert_review_bloc/alert_review_bloc.dart';
import 'package:tabibu/features/alerts/blocs/alert_review_bloc/alert_review_event.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_bloc.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_bloc.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_event.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_bloc.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_bloc.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_event.dart';
import 'package:tabibu/features/onboarding/blocs/onboarding_bloc/onboarding_bloc.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_bloc.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_bloc.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_event.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_bloc.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_event.dart';
import 'package:tabibu/features/themes/blocs/theme_bloc/theme_bloc.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_bloc.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_event.dart';

/// The app-wide blocs, provided by `bootstrap` above `App` and the router,
/// so they outlive every screen (architecture §5 rule 8). A feature bloc
/// joins this list rather than being provided by a screen.
abstract final class BlocsHelper {
  static List<BlocProvider> initializeBlocs() => [
    BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
    BlocProvider<SignUpBloc>(create: (_) => SignUpBloc()),
    BlocProvider<OnboardingBloc>(create: (_) => OnboardingBloc()),
    BlocProvider<FacilitiesBloc>(create: (_) => FacilitiesBloc()),
    BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()),
    BlocProvider<NotificationsBloc>(create: (_) => NotificationsBloc()),
    BlocProvider<DirectoryBloc>(create: (_) => DirectoryBloc()),
    BlocProvider<AppointmentsBloc>(create: (_) => AppointmentsBloc()),
    BlocProvider<PublicAlertsBloc>(create: (_) => PublicAlertsBloc()),
    BlocProvider<CasesBloc>(create: (_) => CasesBloc()),
    BlocProvider<ShareBloc>(create: (_) => ShareBloc()),
    BlocProvider<DeskBloc>(create: (_) => DeskBloc()),
    BlocProvider<AlertReviewBloc>(create: (_) => AlertReviewBloc()),
    BlocProvider<CaseWorkspaceBloc>(create: (_) => CaseWorkspaceBloc()),
    BlocProvider<ReportReaderBloc>(create: (_) => ReportReaderBloc()),
    BlocProvider<OrderBloc>(create: (_) => OrderBloc()),
  ];

  /// Sign-out wipes the encrypted boxes, so every feature bloc holding user
  /// data drops it too: the next account must never see the last one's.
  static void resetFeatureBlocs(BuildContext context) {
    context.read<NotificationsBloc>().add(const NotificationsReset());
    context.read<DirectoryBloc>().add(const DirectoryReset());
    context.read<AppointmentsBloc>().add(const AppointmentsReset());
    context.read<PublicAlertsBloc>().add(const PublicAlertsReset());
    context.read<CasesBloc>().add(const CasesReset());
    context.read<ShareBloc>().add(const ShareReset());
    context.read<DeskBloc>().add(const DeskReset());
    context.read<AlertReviewBloc>().add(const AlertReviewReset());
    context.read<CaseWorkspaceBloc>().add(const CaseWorkspaceReset());
    context.read<ReportReaderBloc>().add(const ReportReaderReset());
    context.read<OrderBloc>().add(const OrderReset());
  }
}
