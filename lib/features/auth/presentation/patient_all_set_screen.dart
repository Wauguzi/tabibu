import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D5. The account is ready; its button leaves through [goToSession].
class PatientAllSetScreen extends StatelessWidget {
  const PatientAllSetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final session = context.watch<AuthBloc>().state.session;
    final name = session is PatientSession
        ? session.patient.firstName
        : context.watch<SignUpBloc>().state.draft.firstName;

    return RoleBackground.patient(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenMargin),
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),
                        Center(
                          child: ExcludeSemantics(
                            child: Assets.icons.patientSignedUp.svg(width: 200),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l10n.allSetTitle(name),
                          style: textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.allSetSubtitle,
                          style: textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        const SizedBox(height: AppSpacing.md),
                        TabibuButton.primary(
                          label: l10n.allSetButton,
                          onTap: () => goToSession(context, session),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
