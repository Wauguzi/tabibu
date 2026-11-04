import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/settle_refresh.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_bloc.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_event.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_state.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-SHARE · Share report. The patient picks one verified doctor or
/// pathologist and creates a Join share. Nothing here reads or shows a code:
/// the server sends it with the recipient's notification (T-18).
class ShareReportScreen extends StatefulWidget {
  const ShareReportScreen({required this.caseUid, super.key});

  final String caseUid;

  @override
  State<ShareReportScreen> createState() => _ShareReportScreenState();
}

class _ShareReportScreenState extends State<ShareReportScreen> {
  late final String _uid;
  late final TextEditingController _query = TextEditingController();
  String _selectedUid = '';

  @override
  void initState() {
    super.initState();
    _uid = switch (context.read<AuthBloc>().state.session) {
      PatientSession(:final patient) => patient.uid,
      _ => '',
    };
    context.read<DirectoryBloc>().add(const DirectoryRequested());
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final directory = context.read<DirectoryBloc>()
      ..add(const DirectoryRefreshed());
    await settleRefresh<DirectoryState>(
      directory.stream,
      (state) => state is DirectoryLoadInProgress,
    );
  }

  void _onQueryChanged(String value) {
    context.read<DirectoryBloc>().add(DirectoryQueryChanged(query: value));
  }

  // The Face ID / PIN gate arrives with the app lock; the label says nothing
  // about it until then.
  void _share() {
    if (_selectedUid.isEmpty) return;
    context.read<ShareBloc>().add(
      ShareCreateRequested(
        uid: _uid,
        role: .patient,
        caseUid: widget.caseUid,
        recipientUid: _selectedUid,
      ),
    );
  }

  void _onShareState(BuildContext context, ShareState state) {
    switch (state) {
      case ShareCreateSuccess():
        ShareDoneRoute(caseUid: widget.caseUid).pushReplacement(context);
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
    final textTheme = Theme.of(context).textTheme;
    final directory = context.watch<DirectoryBloc>().state;
    final writing = context.watch<ShareBloc>().state is ShareWriteInProgress;
    final recipients = shareRecipientsOf(
      directory.all,
      query: directory.query,
      excludeUid: _uid,
    );
    final loading =
        directory.all.isEmpty &&
        (directory is DirectoryInitial || directory is DirectoryLoadInProgress);
    final showEmpty =
        !loading &&
        recipients.isEmpty &&
        (directory is DirectoryLoadSuccess ||
            directory is DirectoryLoadFailure);

    return BlocListener<ShareBloc, ShareState>(
      listenWhen: (_, current) =>
          current is ShareCreateSuccess || current is ShareWriteFailure,
      listener: _onShareState,
      child: Scaffold(
        body: RoleBackground.patient(
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenMargin,
                    AppSpacing.md,
                    AppSpacing.screenMargin,
                    0,
                  ),
                  child: TopBar(
                    title: l10n.shareTitle,
                    backLabel: l10n.commonBack,
                    onBack: context.pop,
                  ),
                ),
                Expanded(
                  child: RefreshIndicator.adaptive(
                    color: Theme.of(context).colorScheme.primary,
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      keyboardDismissBehavior: .onDrag,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenMargin,
                        AppSpacing.md,
                        AppSpacing.screenMargin,
                        AppSpacing.md,
                      ),
                      children: [
                        TwoToneHeadline(first: l10n.shareWhoShouldSee),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.shareWhoShouldSeeBody,
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SearchField(
                          hint: l10n.shareSearchHint,
                          clearLabel: MaterialLocalizations.of(
                            context,
                          ).deleteButtonTooltip,
                          controller: _query,
                          onChanged: _onQueryChanged,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (loading)
                          SizedBox(
                            height: 240,
                            child: LoadingView(
                              semanticLabel: l10n.findDoctorLoadingLabel,
                            ),
                          )
                        else if (showEmpty)
                          EmptyState(
                            title: l10n.findDoctorNoResultsTitle(
                              directory.query,
                            ),
                            icon: Assets.icons.searchRoundedIcon,
                            body: l10n.findDoctorNoResultsBody,
                          )
                        else
                          for (final practitioner in recipients) ...[
                            _RecipientCard(
                              practitioner: practitioner,
                              selected: practitioner.uid == _selectedUid,
                              onTap: () => setState(
                                () => _selectedUid = practitioner.uid,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                      ],
                    ),
                  ),
                ),
                BottomActionBar(
                  primary: TabibuButton.primary(
                    label: l10n.resultDetailShare,
                    isLoading: writing,
                    onTap: _selectedUid.isEmpty ? null : _share,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipientCard extends StatelessWidget {
  const _RecipientCard({
    required this.practitioner,
    required this.selected,
    required this.onTap,
  });

  final PractitionerModel practitioner;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final raw = practitioner.specialties.isEmpty
        ? ''
        : practitioner.specialties.first;
    final specialty = raw.isEmpty
        ? ''
        : Specialty.fromValue(raw)?.description(l10n) ?? raw;
    final facility = practitioner.facilityName;
    final supporting = specialty.isNotEmpty && facility.isNotEmpty
        ? l10n.shareRecipientSubtitle(facility, specialty)
        : specialty.isNotEmpty
        ? specialty
        : facility;
    return OptionCard(
      title: practitioner.fullName,
      supporting: supporting.isEmpty ? null : supporting,
      icon: Assets.icons.personIcon,
      selected: selected,
      onTap: onTap,
    );
  }
}
