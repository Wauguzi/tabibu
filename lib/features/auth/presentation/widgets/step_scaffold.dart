import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The sign-up step frame: back plus progress, title, an optional failure,
/// the fields, and a pinned footer. Steps 1–4 of the patient's or
/// practitioner's flow.
class StepScaffold extends StatelessWidget {
  const StepScaffold({
    required this.step,
    required this.total,
    required this.backLabel,
    required this.onBack,
    required this.title,
    required this.footer,
    required this.child,
    this.subtitle,
    this.error,
    this.role,
    super.key,
  });

  final int step;
  final int total;
  final String backLabel;
  final VoidCallback? onBack;
  final String title;
  final String? subtitle;

  /// The failure to show, as the error notice under the subtitle.
  final AppError? error;
  final Role? role;
  final Widget footer;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final error = this.error;
    final subtitle = this.subtitle;

    final scaffold = Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            children: [
              StepHeader(
                step: step,
                total: total,
                progressLabel: l10n.stepProgress(step, total),
                backLabel: backLabel,
                onBack: onBack,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: textTheme.headlineMedium),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(subtitle, style: textTheme.bodyLarge),
                      ],
                      if (error != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        NoticeCard(
                          variant: NoticeVariant.error,
                          icon: Assets.icons.cancelIcon,
                          body: error.description(l10n),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      child,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              footer,
            ],
          ),
        ),
      ),
    );

    return switch (role) {
      Role.patient => RoleBackground.patient(child: scaffold),
      Role.doctor => RoleBackground.doctor(child: scaffold),
      Role.pathologist => RoleBackground.pathologist(child: scaffold),
      null => scaffold,
    };
  }
}
