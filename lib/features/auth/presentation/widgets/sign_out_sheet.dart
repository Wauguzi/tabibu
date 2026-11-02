import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Asks before signing out, then signs out through [AuthBloc]; the guard
/// moves the person to sign-in once the session clears. [isPatient] picks
/// what the sheet says stays safe.
Future<void> confirmSignOut(
  BuildContext context, {
  required bool isPatient,
}) async {
  final l10n = context.l10n;
  ModalRoute<bool>? sheetRoute;
  final confirmed = await TabibuBottomSheet.show<bool>(
    context,
    leading: IconTile(icon: Assets.icons.signOutIcon, tone: .danger, size: .l),
    title: l10n.signOutTitle,
    subtitle: isPatient
        ? l10n.signOutPatientBody
        : l10n.signOutPractitionerBody,
    cancelLabel: l10n.commonCancel,
    builder: (sheet) {
      sheetRoute = ModalRoute.of(sheet) as ModalRoute<bool>?;
      return TabibuButton.primary(
        label: l10n.profileSignOut,
        onTap: () => Navigator.of(sheet).pop(true),
      );
    },
  );
  if (confirmed != true || !context.mounted) return;
  // The pop resolves before the sheet has slid away; signing out at once
  // swaps the stack under a half-closed sheet, and sign-in flickers.
  await _closed(sheetRoute?.animation);
  if (!context.mounted) return;
  context.read<AuthBloc>().add(const SignOutRequested());
}

Future<void> _closed(Animation<double>? animation) {
  if (animation == null || animation.isDismissed) return Future.value();
  final done = Completer<void>();
  void listener(AnimationStatus status) {
    if (status != .dismissed) return;
    animation.removeStatusListener(listener);
    done.complete();
  }

  animation.addStatusListener(listener);
  return done.future;
}
