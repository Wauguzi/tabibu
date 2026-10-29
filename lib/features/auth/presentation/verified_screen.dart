import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/presentation/widgets/timeline_helpers.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// E6 and F5, shown once after verification. Its button leaves through
/// [goToSession].
class VerifiedScreen extends StatelessWidget {
  const VerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final session = context.watch<AuthBloc>().state.session;
    final doctor = session is PractitionerSession
        ? session.doctor
        : DoctorModel.empty();
    final isPathologist = doctor.isPathologist;
    final name = [
      doctor.title,
      doctor.lastName,
    ].where((part) => part.isNotEmpty).join(' ');

    final scaffold = Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: ExcludeSemantics(
                          child: Assets.icons.practitionerVerifiedIcon.svg(
                            width: 140,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.verifiedTitle(name),
                        style: textTheme.displaySmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        isPathologist
                            ? l10n.verifiedPathologistBody
                            : l10n.verifiedDoctorBody(doctor.facilityName),
                        style: textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      VerificationTimeline(
                        title: l10n.pendingTimelineTitle,
                        progressLabel: l10n.verifiedAllDone,
                        steps: _steps(context, doctor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TabibuButton.primary(
                label: isPathologist
                    ? l10n.verifiedPathologistButton
                    : l10n.verifiedDoctorButton,
                onTap: () => goToSession(context, session),
              ),
            ],
          ),
        ),
      ),
    );

    return isPathologist
        ? RoleBackground.pathologist(child: scaffold)
        : RoleBackground.doctor(child: scaffold);
  }

  List<VerificationStep> _steps(BuildContext context, DoctorModel doctor) {
    final l10n = context.l10n;
    final isPathologist = doctor.isPathologist;
    final submitted = submittedStamp(doctor.createdAt, l10n);
    final what = isPathologist
        ? l10n.pendingStep1PathologistBody
        : l10n.pendingStep1DoctorBody;
    return [
      VerificationStep(
        title: l10n.pendingStep1Title,
        supporting: submitted == null ? what : '$submitted · $what',
        state: VerificationStepState.done,
        chipLabel: l10n.chipDone,
        stateLabel: l10n.chipDone,
      ),
      VerificationStep(
        title: l10n.verifiedStep2DoneTitle,
        supporting: l10n.verifiedStep2DoneBody(doctor.kmpdcNumber),
        state: VerificationStepState.done,
        chipLabel: l10n.chipDone,
        stateLabel: l10n.chipDone,
      ),
      VerificationStep(
        title: isPathologist
            ? l10n.pendingStep3PathologistTitle
            : l10n.pendingStep3DoctorTitle,
        supporting: doctor.facilityName,
        state: VerificationStepState.done,
        chipLabel: l10n.chipDone,
        stateLabel: l10n.chipDone,
      ),
      VerificationStep(
        title: l10n.pendingStep4Title,
        supporting: isPathologist
            ? l10n.verifiedStep4PathologistBody(
                areaSentence(doctor.specialties, l10n, capitalizeFirst: true),
              )
            : l10n.pendingStep4DoctorBody,
        state: VerificationStepState.done,
        chipLabel: l10n.chipDone,
        stateLabel: l10n.chipDone,
      ),
    ];
  }
}
