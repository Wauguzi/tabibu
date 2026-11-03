import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_bloc.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_event.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_state.dart';
import 'package:tabibu/features/cases/presentation/widgets/share_code_boxes.dart';
import 'package:tabibu/features/cases/presentation/widgets/share_dates.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D-SHARE-CODE · Shared report, enter code (doctor and pathologist).
///
/// The field always starts empty. A route carries only the share id, never a
/// code, and nothing reads `metadata.shareCode` here: the person types what
/// the notification shows (T-18). Opening loads the recipient's shares so a
/// redeem knows which case to open (F-2).
class EnterShareCodeScreen extends StatefulWidget {
  const EnterShareCodeScreen({
    required this.role,
    required this.shareUid,
    super.key,
  });

  /// Doctor or pathologist; it picks the wash and where success goes.
  final Role role;
  final String shareUid;

  @override
  State<EnterShareCodeScreen> createState() => _EnterShareCodeScreenState();
}

class _EnterShareCodeScreenState extends State<EnterShareCodeScreen> {
  late final String _uid;
  final TextEditingController _code = TextEditingController();
  AppError? _error;
  bool _tooShort = false;

  @override
  void initState() {
    super.initState();
    _uid = switch (context.read<AuthBloc>().state.session) {
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    context.read<ShareBloc>().add(
      ShareRequested(
        uid: _uid,
        role: widget.role,
        caseUid: '',
        asCreator: false,
      ),
    );
    context.read<DirectoryBloc>().add(const DirectoryRequested());
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _onChanged(String _) {
    if (_error == null && !_tooShort) return;
    setState(() {
      _error = null;
      _tooShort = false;
    });
  }

  void _open() {
    if (_code.text.length != shareCodeLength) {
      setState(() => _tooShort = true);
      return;
    }
    context.read<ShareBloc>().add(
      ShareRedeemRequested(
        uid: _uid,
        shareUid: widget.shareUid,
        code: _code.text,
      ),
    );
  }

  void _onShareState(BuildContext context, ShareState state) {
    switch (state) {
      case ShareRedeemSuccess(:final redeemedCaseUid)
          when redeemedCaseUid.isNotEmpty:
        _openCase(context, redeemedCaseUid);
      case ShareWriteFailure(:final error) || ShareLoadFailure(:final error):
        setState(() => _error = error);
      default:
        break;
    }
  }

  void _openCase(BuildContext context, String caseUid) {
    if (widget.role == .pathologist) {
      CaseWorkspaceRoute(caseUid: caseUid).pushReplacement(context);
    } else {
      DoctorCaseRoute(caseUid: caseUid).pushReplacement(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final state = context.watch<ShareBloc>().state;
    final cases = context.watch<CasesBloc>().state.cases;
    final directory = context.watch<DirectoryBloc>().state.all;
    final language = Localizations.localeOf(context).languageCode;
    final writing = state is ShareWriteInProgress;

    final share = state.shares.firstWhereOrNull(
      (s) => s.uid == widget.shareUid,
    );
    final sharer = share == null
        ? ''
        : directory
                  .firstWhereOrNull((p) => p.uid == share.createdByUid)
                  ?.fullName ??
              switch (ActorRole.fromValue(share.createdByRole)) {
                .doctor => l10n.roleDoctor,
                .pathologist => l10n.rolePathologist,
                .patient => l10n.rolePatient,
                .system => '',
              };
    final caseNumber =
        cases.firstWhereOrNull((c) => c.uid == share?.caseUid)?.orderNumber ??
        '';
    final endsOn = share == null
        ? ''
        : shareDateLabel(share.expiresAt, language);

    final message = _tooShort
        ? l10n.shareCodeInvalid
        : _error?.description(l10n);

    final body = SafeArea(
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Expanded(
            child: ListView(
              keyboardDismissBehavior: .onDrag,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenMargin,
                AppSpacing.md,
                AppSpacing.screenMargin,
                AppSpacing.md,
              ),
              children: [
                TopBar(
                  title: l10n.shareEnterCodeTitle,
                  backLabel: l10n.commonBack,
                  onBack: context.pop,
                ),
                const SizedBox(height: AppSpacing.lg),
                TwoToneHeadline(first: l10n.shareEnterCodeTitle),
                if (sharer.isNotEmpty && caseNumber.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.shareEnterCodeBody(caseNumber, sharer),
                    style: textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxlg),
                ShareCodeField(
                  controller: _code,
                  label: l10n.shareEnterCodeTitle,
                  hasError: message != null,
                  onChanged: _onChanged,
                ),
                if (message != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      message,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.error,
                      ),
                      textAlign: .center,
                    ),
                  ),
                ],
                if (endsOn.isNotEmpty && sharer.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.shareEnterCodeNote(
                      endsOn,
                      sharer.split(RegExp(r'\s+')).first,
                    ),
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: .center,
                  ),
                ],
              ],
            ),
          ),
          BottomActionBar(
            primary: TabibuButton.primary(
              label: l10n.shareOpenReport,
              isLoading: writing,
              onTap: _open,
            ),
          ),
        ],
      ),
    );

    return BlocListener<ShareBloc, ShareState>(
      listenWhen: (_, current) =>
          current is ShareRedeemSuccess ||
          current is ShareWriteFailure ||
          current is ShareLoadFailure,
      listener: _onShareState,
      child: Scaffold(
        body: switch (widget.role) {
          .pathologist => RoleBackground.pathologist(child: body),
          _ => RoleBackground.doctor(child: body),
        },
      ),
    );
  }
}
