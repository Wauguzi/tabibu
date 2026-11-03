import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The entry into a case's history, shared by the doctor's case screen,
/// the pathologist's workspace and the patient's result screen.
class CaseHistoryRow extends StatelessWidget {
  const CaseHistoryRow({required this.caseUid, required this.role, super.key});

  final String caseUid;
  final Role role;

  @override
  Widget build(BuildContext context) => ListRowCard(
    leading: IconTile(icon: Assets.icons.clockIcon, tone: .neutral),
    title: context.l10n.accessLogTitle,
    onTap: () => switch (role) {
      .patient => PatientCaseHistoryRoute(caseUid: caseUid).push<void>(context),
      .pathologist => PathologistCaseHistoryRoute(
        caseUid: caseUid,
      ).push<void>(context),
      _ => DoctorCaseHistoryRoute(caseUid: caseUid).push<void>(context),
    },
  );
}
