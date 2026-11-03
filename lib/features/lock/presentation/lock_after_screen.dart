import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' hide LockState;
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_bloc.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_event.dart';
import 'package:tabibu/features/profile/presentation/widgets/settings_group.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// How long the app may sit unused before it asks for the PIN again.
class LockAfterScreen extends StatelessWidget {
  const LockAfterScreen({super.key});

  String _label(AppLocalizations l10n, int seconds) => switch (seconds) {
    0 => l10n.appLockDelayNow,
    60 => l10n.appLockDelayOne,
    300 => l10n.appLockDelayFive,
    900 => l10n.appLockDelayFifteen,
    _ => l10n.appLockAway('$seconds'),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<LockBloc>().state;
    final current = state.lockAfterSeconds;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenMargin,
                AppSpacing.md,
                AppSpacing.screenMargin,
                AppSpacing.md,
              ),
              sliver: SliverList.list(
                children: [
                  TopBar(
                    title: l10n.appLockAfter,
                    backLabel: l10n.commonBack,
                    onBack: context.pop,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.appLockAfterBody,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SettingsGroup(
                    title: l10n.appLockAskPinWhen,
                    children: [
                      for (final seconds in LockBloc.lockAfterOptions)
                        SettingsRow(
                          icon: Assets.icons.clockIcon,
                          title: _label(l10n, seconds),
                          supporting: seconds == current
                              ? l10n.appLockOnOpen
                              : null,
                          onTap: () {
                            context.read<LockBloc>().add(
                              LockAfterChanged(seconds: seconds),
                            );
                            context.pop();
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
