import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/helpers/blocs_helper.dart';
import 'package:tabibu/features/alerts/blocs/alert_review_bloc/alert_review_event.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_event.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_event.dart';

import '../../helpers/helpers.dart';

void main() {
  group('BlocsHelper.resetFeatureBlocs', () {
    testWidgets('resets every feature bloc', (tester) async {
      final blocs = FeatureBlocs();
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: blocs.providers,
          child: Builder(
            builder: (context) {
              BlocsHelper.resetFeatureBlocs(context);
              return const SizedBox();
            },
          ),
        ),
      );

      verify(() => blocs.notifications.add(const NotificationsReset()));
      verify(() => blocs.directory.add(const DirectoryReset()));
      verify(() => blocs.appointments.add(const AppointmentsReset()));
      verify(() => blocs.publicAlerts.add(const PublicAlertsReset()));
      verify(() => blocs.cases.add(const CasesReset()));
      verify(() => blocs.desk.add(const DeskReset()));
      verify(() => blocs.alertReview.add(const AlertReviewReset()));
      verify(() => blocs.caseWorkspace.add(const CaseWorkspaceReset()));
    });
  });
}
