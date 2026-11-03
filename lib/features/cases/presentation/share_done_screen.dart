import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_bloc.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_event.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_state.dart';
import 'package:tabibu/features/cases/data/models/share_code_model.dart';
import 'package:tabibu/features/cases/presentation/widgets/share_code_boxes.dart';
import 'package:tabibu/features/cases/presentation/widgets/share_confirms.dart';
import 'package:tabibu/features/cases/presentation/widgets/share_dates.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-SHARE · Report shared. Replaces the share screen (F-1). The four digits
/// appear only while the bloc still holds a revealed code; the server
/// usually returns none, so the screen then says only who it went to and
/// when access ends (T-18). Leaving drops any code from memory.
class ShareDoneScreen extends StatefulWidget {
  const ShareDoneScreen({required this.caseUid, super.key});

  final String caseUid;

  @override
  State<ShareDoneScreen> createState() => _ShareDoneScreenState();
}

class _ShareDoneScreenState extends State<ShareDoneScreen> {
  late final ShareBloc _share;
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _share = context.read<ShareBloc>();
    _uid = switch (context.read<AuthBloc>().state.session) {
      PatientSession(:final patient) => patient.uid,
      _ => '',
    };
  }

  @override
  void dispose() {
    if (!_share.isClosed) _share.add(const ShareCodeDismissed());
    super.dispose();
  }

  /// The share this screen is about: the one holding the revealed code, else
  /// the newest pending one for the case.
  ShareCodeModel? _shareIn(ShareState state) {
    final revealed = state.shares.firstWhereOrNull(
      (s) => s.uid == state.revealedShareUid && s.uid.isNotEmpty,
    );
    if (revealed != null) return revealed;
    final pending = state.shares
        .where((s) => s.statusValue == .pending && s.caseUid == widget.caseUid)
        .sortedBy((s) => s.createdAt);
    return pending.lastOrNull;
  }

  Future<void> _stop(ShareCodeModel share, String name) async {
    if (!await confirmStopSharing(context, name: name)) return;
    if (!mounted) return;
    _share.add(ShareRevokeRequested(uid: _uid, shareUid: share.uid));
  }

  void _onShareState(BuildContext context, ShareState state) {
    switch (state) {
      case ShareRevokeSuccess():
        context.pop();
      case ShareWriteFailure(:final error):
        unawaited(
          showTabibuNotification(
            context,
            message: error.description(context.l10n),
            isError: true,
            dismissLabel: context.l10n.commonDismiss,
          ),
        );
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<ShareBloc>().state;
    final share = _shareIn(state);
    final recipient = share == null
        ? null
        : context.watch<DirectoryBloc>().state.all.firstWhereOrNull(
            (p) => p.uid == share.recipientUid,
          );
    final name = recipient?.fullName.isNotEmpty == true
        ? recipient!.fullName
        : l10n.roleDoctor;
    final writing = state is ShareWriteInProgress;

    return BlocListener<ShareBloc, ShareState>(
      listenWhen: (_, current) =>
          current is ShareRevokeSuccess || current is ShareWriteFailure,
      listener: _onShareState,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              Expanded(
                child: share == null
                    ? const SizedBox.shrink()
                    : _Body(
                        name: name,
                        share: share,
                        code: state.revealedShareUid == share.uid
                            ? state.revealedCode
                            : '',
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenMargin,
                  AppSpacing.sm,
                  AppSpacing.screenMargin,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    TabibuButton.primary(
                      label: l10n.chipDone,
                      onTap: context.pop,
                    ),
                    if (share != null)
                      TabibuButton.ghost(
                        label: l10n.shareStopSharing,
                        isLoading: writing,
                        onTap: () => unawaited(_stop(share, name)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.name, required this.share, required this.code});

  final String name;
  final ShareCodeModel share;

  /// Empty almost always: the server does not return it (T-18).
  final String code;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final language = Localizations.localeOf(context).languageCode;
    final days = shareDaysLeft(share.expiresAt, DateTime.now());
    final endsOn = shareDateLabel(share.expiresAt, language);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        AppSpacing.xxlg,
        AppSpacing.screenMargin,
        AppSpacing.md,
      ),
      children: [
        Center(
          child: IconTile(icon: Assets.icons.shieldIcon, tone: .mint, size: .l),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.shareSharedWith(name),
          style: textTheme.displaySmall,
          textAlign: .center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.shareSharedBody,
          style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
          textAlign: .center,
        ),
        if (code.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xlg),
          ShareCodeDigits(code: code),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.shareCodeWorksOnce(name),
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: .center,
          ),
        ],
        const SizedBox(height: AppSpacing.xlg),
        if (days != null && endsOn.isNotEmpty)
          _InfoLine(
            icon: Assets.icons.clockIcon,
            text: l10n.shareAccessEnds(endsOn, days),
          ),
        _InfoLine(
          icon: Assets.icons.notificationBellIcon,
          text: l10n.shareOpenedReceipt,
        ),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final SvgGenImage icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          ExcludeSemantics(
            child: AssetIcon(icon, size: 22, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
