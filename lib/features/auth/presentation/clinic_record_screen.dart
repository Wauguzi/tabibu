import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The T-15 notice: a clinic already holds this phone and birth date, so the
/// doctor links the account in person. The only way out is signing out.
class ClinicRecordScreen extends StatelessWidget {
  const ClinicRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is SignOutSuccess) {
          goToSession(context, state.session);
        }
      },
      builder: (context, state) {
        final busy = state is SignOutInProgress;
        final failure = state is SignOutFailure ? state.error : null;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenMargin),
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(),
                          Center(
                            child: IconTile(
                              icon: Assets.icons.facilityIcon,
                              tone: IconTone.sky,
                              size: IconTileSize.l,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            l10n.clinicTitle,
                            style: textTheme.displaySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            l10n.clinicBody,
                            style: textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          if (failure != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            NoticeCard(
                              variant: NoticeVariant.error,
                              icon: Assets.icons.cancelIcon,
                              body: failure.description(l10n),
                            ),
                          ],
                          const Spacer(),
                          const SizedBox(height: AppSpacing.md),
                          TabibuButton.primary(
                            label: l10n.clinicSignOut,
                            isLoading: busy,
                            onTap: busy
                                ? null
                                : () => context.read<AuthBloc>().add(
                                    const SignOutRequested(),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
