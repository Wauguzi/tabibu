import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P/D/PA-NOTIF-SET in one screen: the one `receiveNotifications` switch,
/// through the same event as the profile tab's row. The frame's per-category
/// rows stay out: the backend keeps no per-category settings (design-audit
/// row 325), and an unwritable switch would be inert (S-1). On the web the
/// switch is unwritable the same way — push has no token or topics there —
/// so a plain line stands in its place.
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({required this.role, super.key});

  final Role role;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final background = switch (role) {
      .patient => RoleBackground.patient,
      .doctor => RoleBackground.doctor,
      .pathologist => RoleBackground.pathologist,
    };
    final offBody = switch (role) {
      .patient => l10n.notificationSettingsOffPatient,
      .doctor => l10n.notificationSettingsOffDoctor,
      .pathologist => l10n.notificationSettingsOffPathologist,
    };
    final body = SafeArea(
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
                  backLabel: l10n.commonBack,
                  onBack: context.pop,
                  title: l10n.notificationSettingsTitle,
                ),
                const SizedBox(height: AppSpacing.md),
                if (kIsWeb)
                  Text(
                    l10n.notificationSettingsWebLine,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  BlocConsumer<AuthBloc, AuthState>(
                    listenWhen: (previous, state) =>
                        state is ProfileSettingChangeFailure,
                    listener: (context, state) {
                      final failure = state as ProfileSettingChangeFailure;
                      unawaited(
                        showTabibuNotification(
                          context,
                          message: failure.error.description(l10n),
                          isError: true,
                          dismissLabel: l10n.commonDismiss,
                        ),
                      );
                    },
                    builder: (context, state) {
                      final receive = switch (state.session) {
                        PatientSession(:final patient) =>
                          patient.receiveNotifications,
                        PractitionerSession(:final doctor) =>
                          doctor.receiveNotifications,
                        _ => null,
                      };
                      // The router bounces the signed-out off role paths; this
                      // is the frame between a sign-out and its redirect.
                      if (receive == null) return const SizedBox.shrink();
                      final saving = state is ProfileSettingChangeInProgress;
                      return _MasterRow(
                        title: l10n.notificationSettingsAll,
                        body: receive
                            ? l10n.notificationSettingsAllBody
                            : offBody,
                        value: receive,
                        onChanged: saving
                            ? null
                            : (value) => context.read<AuthBloc>().add(
                                ProfileSettingChanged(
                                  setting: .healthNotices,
                                  value: value,
                                ),
                              ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    return Scaffold(body: background(child: body));
  }
}

/// The master row: title, the on/off body, and the switch. The whole row
/// toggles; the switch mirrors the value.
class _MasterRow extends StatelessWidget {
  const _MasterRow({
    required this.title,
    required this.body,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String body;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    void toggle() => onChanged?.call(!value);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return MergeSemantics(
      child: Semantics(
        toggled: value,
        enabled: onChanged != null,
        onTap: onChanged == null ? null : toggle,
        child: Tappable(
          onTap: onChanged == null ? null : toggle,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadii.card),
              boxShadow: AppShadows.card(),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      mainAxisSize: .min,
                      children: [
                        Text(title, style: textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          body,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ExcludeSemantics(
                    child: Switch(
                      value: value,
                      onChanged: onChanged,
                      materialTapTargetSize: .shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
