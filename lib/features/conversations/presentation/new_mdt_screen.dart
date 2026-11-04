import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_bloc.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_event.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_state.dart';
import 'package:tabibu/features/conversations/presentation/mdt_routes.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_invite_picker.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The most people a consult holds, the owner included (the server's limit).
const mdtMaxMembers = 10;

/// The longest subject the server takes.
const mdtSubjectMaxLength = 1000;

/// D-MDT and PA-MDT · New consult. Pick one of my cases, say what the
/// consult is about (the server requires it), choose who to invite, and
/// send. Nothing is created until the invite is sent.
class NewMdtScreen extends StatefulWidget {
  const NewMdtScreen({required this.role, this.caseUid = '', super.key});

  final Role role;

  /// A case chosen before arriving, from a case's options.
  final String caseUid;

  @override
  State<NewMdtScreen> createState() => _NewMdtScreenState();
}

class _NewMdtScreenState extends State<NewMdtScreen> {
  late final String _uid;
  late final List<String> _ownSpecialties;
  late String _caseUid = widget.caseUid;
  final _about = TextEditingController();
  final Set<String> _invitees = {};
  var _showAboutError = false;

  /// This screen sent the request, so a success belongs to it.
  var _sent = false;

  @override
  void initState() {
    super.initState();
    final doctor = switch (context.read<AuthBloc>().state.session) {
      PractitionerSession(:final doctor) => doctor,
      _ => null,
    };
    _uid = doctor?.uid ?? '';
    _ownSpecialties = doctor?.specialties ?? const [];
    final cases = context.read<CasesBloc>();
    if (cases.state.cases.isEmpty) {
      cases.add(CasesRequested(uid: _uid, role: widget.role));
    }
    context.read<DirectoryBloc>().add(const DirectoryRequested());
  }

  @override
  void dispose() {
    _about.dispose();
    super.dispose();
  }

  /// My cases a consult can be about: the pathologist has accepted and the
  /// case is not over, as the server requires.
  List<CaseModel> _eligible(List<CaseModel> all) => [
    for (final c in all)
      if (c.pathologistUid.isNotEmpty && !c.isDone)
        if (widget.role == .pathologist
            ? c.pathologistUid == _uid
            : c.doctorUid == _uid)
          c,
  ];

  /// The specialty the consult is asked in: the first invitee's, else mine.
  String _specialty() {
    final directory = context.read<DirectoryBloc>().state.all;
    for (final uid in _invitees) {
      final found = directory.firstWhereOrNull((p) => p.uid == uid);
      final specialty = found == null ? null : mdtSpecialtyOf(found);
      if (specialty != null) return specialty.value;
    }
    for (final raw in _ownSpecialties) {
      if (Specialty.fromValue(raw) != null) return raw;
    }
    return (widget.role == .pathologist
            ? Specialty.histopathology
            : Specialty.generalPractice)
        .value;
  }

  void _send() {
    if (_caseUid.isEmpty || _invitees.isEmpty) return;
    final about = _about.text.trim();
    if (about.isEmpty) {
      setState(() => _showAboutError = true);
      return;
    }
    _sent = true;
    context.read<MdtBloc>().add(
      MdtOpenRequested(
        uid: _uid,
        caseUid: _caseUid,
        specialty: _specialty(),
        description: about,
        inviteeUids: _invitees.toList(),
      ),
    );
  }

  void _onState(BuildContext context, MdtState state) {
    switch (state) {
      case MdtWriteSuccess(:final openedConversationUid)
          when _sent && openedConversationUid.isNotEmpty:
        _sent = false;
        // Replaces the form, so back never returns to a sent invite (F-1).
        mdtConsultRoute(
          widget.role,
          openedConversationUid,
        ).pushReplacement(context);
      case MdtWriteFailure(:final error) when _sent:
        _sent = false;
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
    final cases = _eligible(context.watch<CasesBloc>().state.cases);
    final directory = context.watch<DirectoryBloc>().state;
    final writing = context.watch<MdtBloc>().state is MdtWriteInProgress;
    final candidates = mdtInvitable(directory.all, myUid: _uid);
    final background = widget.role == .pathologist
        ? RoleBackground.pathologist
        : RoleBackground.doctor;

    return BlocListener<MdtBloc, MdtState>(
      listenWhen: (_, current) =>
          current is MdtWriteSuccess || current is MdtWriteFailure,
      listener: _onState,
      child: Scaffold(
        body: background(
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
                    title: l10n.mdtNewTitle,
                    backLabel: l10n.commonBack,
                    onBack: context.pop,
                  ),
                ),
                Expanded(
                  child: ListView(
                    keyboardDismissBehavior: .onDrag,
                    padding: const EdgeInsets.all(AppSpacing.screenMargin),
                    children: [
                      Text(l10n.mdtPickCase, style: textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      if (cases.isEmpty)
                        EmptyState(
                          title: l10n.doctorCasesEmptyTitle,
                          body: l10n.doctorCasesEmptyBody,
                        )
                      else
                        for (final c in cases) ...[
                          _CaseOption(
                            caseModel: c,
                            selected: c.uid == _caseUid,
                            onTap: () => setState(() => _caseUid = c.uid),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      const SizedBox(height: AppSpacing.md),
                      TabibuTextField(
                        label: l10n.mdtAboutLabel,
                        hint: l10n.mdtAboutHint,
                        controller: _about,
                        required: true,
                        maxLength: mdtSubjectMaxLength,
                        textInputAction: .done,
                        // The server refuses markup in the subject.
                        inputFormatters: [
                          FilteringTextInputFormatter.deny('<'),
                        ],
                        errorText: _showAboutError && _about.text.trim().isEmpty
                            ? l10n.mdtAboutRequired
                            : null,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(l10n.mdtInviteStep, style: textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      if (directory.all.isEmpty &&
                          (directory is DirectoryInitial ||
                              directory is DirectoryLoadInProgress))
                        SizedBox(
                          height: 160,
                          child: LoadingView(
                            semanticLabel: l10n.findDoctorLoadingLabel,
                          ),
                        )
                      else
                        MdtInvitePicker(
                          candidates: candidates,
                          selected: _invitees,
                          // The owner takes one place.
                          limit: mdtMaxMembers - 1,
                          onToggle: (uid) => setState(() {
                            if (!_invitees.remove(uid)) _invitees.add(uid);
                          }),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      Text(l10n.mdtStaysOpen, style: textTheme.bodySmall),
                    ],
                  ),
                ),
                BottomActionBar(
                  primary: TabibuButton.primary(
                    label: l10n.mdtSendInvite,
                    isLoading: writing,
                    onTap: _caseUid.isEmpty || _invitees.isEmpty ? null : _send,
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

class _CaseOption extends StatelessWidget {
  const _CaseOption({
    required this.caseModel,
    required this.selected,
    required this.onTap,
  });

  final CaseModel caseModel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final test = caseModel.tests.firstOrNull?.name ?? '';
    // Signed or beyond is the doctor's third step.
    final supporting = caseModel.doctorStep >= 3
        ? l10n.mdtCaseSigned(test)
        : l10n.mdtCaseWithPathologist(test);
    return OptionCard(
      title: l10n.mdtCasePatient(caseModel.orderNumber, caseModel.patientName),
      supporting: supporting,
      icon: Assets.icons.documentIcon,
      selected: selected,
      onTap: onTap,
    );
  }
}
