import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' hide LockState;
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_bloc.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_event.dart';
import 'package:tabibu/features/cases/data/models/share_code_model.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_bloc.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_event.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_state.dart';
import 'package:tabibu/features/lock/presentation/widgets/pin_pad.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/features/profile/presentation/widgets/settings_group.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-/D-/PA-PRIVACY data privacy. Mostly static pages from the frames; the
/// live rows are the patient's shared reports (ShareBloc, like the shares
/// list) and the clinicians' report lock (the app lock, like its settings).
/// Who can see is an info row — its body answers it and there is no global
/// viewers screen — and the frames' download row stays out (group D).
class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({required this.role, super.key});

  final Role role;

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.role != .patient) return;
    final uid = switch (context.read<AuthBloc>().state.session) {
      PatientSession(:final patient) => patient.uid,
      _ => '',
    };
    context.read<ShareBloc>().add(
      ShareRequested(uid: uid, role: .patient, caseUid: ''),
    );
    context.read<DirectoryBloc>().add(const DirectoryRequested());
  }

  /// The app lock, framed as the report lock: disabling asks the PIN first,
  /// enabling opens the create-PIN flow (as the lock settings do).
  Future<void> _toggleLock(LockState state) async {
    if (state.enabled) {
      final pin = await TabibuBottomSheet.show<String>(
        context,
        title: context.l10n.appLockEnterPin,
        builder: (sheet) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: PinEntry(onComplete: (pin) => Navigator.of(sheet).pop(pin)),
        ),
      );
      if (pin == null || !mounted) return;
      context.read<LockBloc>().add(LockDisableRequested(pin: pin));
      return;
    }
    await switch (widget.role) {
      .pathologist => const PathologistCreatePinRoute().push<void>(context),
      _ => const DoctorCreatePinRoute().push<void>(context),
    };
  }

  void _openPolicy() => switch (widget.role) {
    .patient => const PatientPrivacyPolicyRoute().push<void>(context),
    .pathologist => const PathologistPrivacyPolicyRoute().push<void>(context),
    _ => const DoctorPrivacyPolicyRoute().push<void>(context),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                  title: l10n.privacyTitle,
                ),
                const SizedBox(height: AppSpacing.md),
                if (widget.role == .patient) ...[
                  Text(l10n.privacyPatientBody, style: _body(context)),
                  const SizedBox(height: AppSpacing.md),
                  _PatientRows(onPolicy: _openPolicy),
                ] else ...[
                  if (widget.role == .pathologist) ...[
                    Text(l10n.privacyPaBody, style: _body(context)),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  _ClinicianRows(
                    role: widget.role,
                    onPolicy: _openPolicy,
                    onLock: _toggleLock,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Text(
                  widget.role == .doctor
                      ? l10n.privacyFooterDoctor
                      : l10n.privacyFooterPatient,
                  style: _body(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      body: switch (widget.role) {
        .patient => RoleBackground.patient(child: body),
        .pathologist => RoleBackground.pathologist(child: body),
        _ => RoleBackground.doctor(child: body),
      },
    );
  }

  TextStyle? _body(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium;
}

/// Location, who can see, shared reports, the policy. The shares row reads
/// the shares list: newest first, open while Pending.
class _PatientRows extends StatelessWidget {
  const _PatientRows({required this.onPolicy});

  final VoidCallback onPolicy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shares = context.watch<ShareBloc>().state.shares;
    final directory = context.watch<DirectoryBloc>().state.all;
    final active = shares
        .sortedBy((s) => s.createdAt)
        .reversed
        .where((s) => s.statusValue == ShareStatus.pending)
        .toList();
    final latest = active.firstOrNull;
    final supporting = latest == null
        ? l10n.privacyNoShares
        : l10n.privacyActiveShares(
            active.length,
            _nameOf(l10n, directory, latest),
          );
    return SettingsCard(
      children: [
        SettingsRow(
          icon: Assets.icons.locationIcon,
          title: l10n.privacyLocation,
          supporting: l10n.privacyLocationBody,
          chevron: false,
        ),
        SettingsRow(
          icon: Assets.icons.personIcon,
          title: l10n.privacyWhoCanSee,
          supporting: l10n.privacyWhoCanSeeBody,
          chevron: false,
        ),
        SettingsRow(
          icon: Assets.icons.shareIcon,
          title: l10n.privacySharedReports,
          supporting: supporting,
          onTap: () => const SharedReportsRoute().push<void>(context),
        ),
        SettingsRow(
          icon: Assets.icons.documentIcon,
          title: l10n.privacyPolicyRow,
          supporting: l10n.privacyPolicyRowBody,
          onTap: onPolicy,
        ),
      ],
    );
  }

  String _nameOf(
    AppLocalizations l10n,
    List<PractitionerModel> directory,
    ShareCodeModel share,
  ) {
    final found = directory.firstWhereOrNull(
      (p) => p.uid == share.recipientUid,
    );
    return found == null || found.fullName.isEmpty
        ? l10n.roleDoctor
        : found.fullName;
  }
}

/// The report lock and the policy.
class _ClinicianRows extends StatelessWidget {
  const _ClinicianRows({
    required this.role,
    required this.onPolicy,
    required this.onLock,
  });

  final Role role;
  final VoidCallback onPolicy;
  final Future<void> Function(LockState state) onLock;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lock = context.watch<LockBloc>().state;
    final pathologist = role == .pathologist;
    return SettingsCard(
      children: [
        SettingsSwitchRow(
          icon: Assets.icons.fingerprintIcon,
          title: pathologist ? l10n.privacyPinFaceCase : l10n.privacyAskPinFace,
          supporting: pathologist
              ? l10n.privacyPinFaceCaseBody
              : l10n.privacyAskPinFaceBody,
          value: lock.enabled,
          onChanged: lock.locked ? null : (_) => unawaited(onLock(lock)),
        ),
        SettingsRow(
          icon: Assets.icons.documentIcon,
          title: l10n.privacyPolicyRow,
          supporting: l10n.privacyPolicyRowBodyClinician,
          onTap: onPolicy,
        ),
      ],
    );
  }
}
