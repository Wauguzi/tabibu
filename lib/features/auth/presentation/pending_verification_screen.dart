import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/presentation/widgets/timeline_helpers.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// E5. The verification tracker, read from the pending session's doctor, plus
/// "Check again". A re-check that finds a [PractitionerSession] moves to the
/// verified screen; a rejected profile swaps the title and body.
class PendingVerificationScreen extends StatelessWidget {
  const PendingVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final session = context.watch<AuthBloc>().state.session;
    final doctor = session is PendingVerificationSession
        ? session.doctor
        : DoctorModel.empty();
    final isPathologist = doctor.isPathologist;
    final rejected =
        doctor.verificationStatusValue == VerificationStatus.rejected;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is SessionLoadSuccess &&
            state.session is PractitionerSession) {
          const VerifiedRoute().go(context);
        }
      },
      builder: (context, state) {
        final busy = state is SessionLoadInProgress;
        final failure = state is SessionLoadFailure ? state.error : null;

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
                            rejected
                                ? l10n.pendingRejectedTitle
                                : l10n.pendingTitle,
                            style: textTheme.displaySmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            rejected
                                ? l10n.pendingRejectedBody
                                : l10n.pendingSubtitle,
                            style: textTheme.bodyLarge,
                          ),
                          if (failure != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            NoticeCard(
                              variant: NoticeVariant.error,
                              icon: Assets.icons.cancelIcon,
                              body: failure.description(l10n),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.md),
                          VerificationTimeline(
                            title: l10n.pendingTimelineTitle,
                            progressLabel: l10n.stepProgress(2, 4),
                            steps: _steps(context, doctor),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          NoticeCard(
                            variant: NoticeVariant.info,
                            icon: Assets.icons.infoIcon,
                            body: l10n.pendingNotice,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TabibuButton.primary(
                    label: l10n.pendingCheckAgain,
                    isLoading: busy,
                    onTap: busy
                        ? null
                        : () => context.read<AuthBloc>().add(
                            const SessionRequested(forceRefresh: true),
                          ),
                  ),
                  // The reviewer wires these; the order matches the design,
                  // with check-again and sign-out around it.
                  const SizedBox(height: AppSpacing.sm),
                  TabibuButton.secondary(
                    label: l10n.pendingExplore,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TabibuButton.ghost(
                    label: l10n.pendingContactSupport,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TabibuButton.ghost(label: l10n.profileSignOut, onTap: () {}),
                ],
              ),
            ),
          ),
        );

        return isPathologist
            ? RoleBackground.pathologist(child: scaffold)
            : RoleBackground.doctor(child: scaffold);
      },
    );
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
        title: l10n.pendingStep2Title,
        supporting: l10n.pendingStep2Body(doctor.kmpdcNumber),
        state: VerificationStepState.inProgress,
        chipLabel: l10n.chipInProgress,
        stateLabel: l10n.chipInProgress,
        icon: Assets.icons.inProgressIcon,
      ),
      VerificationStep(
        title: isPathologist
            ? l10n.pendingStep3PathologistTitle
            : l10n.pendingStep3DoctorTitle,
        supporting: isPathologist
            ? l10n.pendingStep3PathologistBody(
                doctor.facilityName,
                doctor.subCounty,
              )
            : l10n.pendingStep3DoctorBody(doctor.facilityName),
        state: VerificationStepState.upNext,
        chipLabel: l10n.chipUpNext,
        stateLabel: l10n.chipUpNext,
        icon: isPathologist
            ? Assets.icons.testTubeIcon
            : Assets.icons.facilityIcon,
      ),
      VerificationStep(
        title: l10n.pendingStep4Title,
        supporting: isPathologist
            ? l10n.pendingStep4PathologistBody(
                areaSentence(doctor.specialties, l10n),
              )
            : l10n.pendingStep4DoctorBody,
        state: VerificationStepState.upNext,
        chipLabel: l10n.chipUpNext,
        stateLabel: l10n.chipUpNext,
        icon: Assets.icons.verificationBadge,
      ),
    ];
  }
}
