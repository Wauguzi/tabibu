import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_bloc.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_event.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_state.dart';
import 'package:tabibu/features/conversations/presentation/new_mdt_screen.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_invite_picker.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D-MDT and PA-MDT · Invite a colleague to a consult already open. The owner
/// only: the server refuses anyone else, and the members sheet offers it to
/// the owner alone.
class MdtInviteScreen extends StatefulWidget {
  const MdtInviteScreen({
    required this.role,
    required this.conversationUid,
    super.key,
  });

  final Role role;
  final String conversationUid;

  @override
  State<MdtInviteScreen> createState() => _MdtInviteScreenState();
}

class _MdtInviteScreenState extends State<MdtInviteScreen> {
  late final String _uid;
  final Set<String> _invitees = {};
  var _sent = false;

  @override
  void initState() {
    super.initState();
    _uid = switch (context.read<AuthBloc>().state.session) {
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    context.read<DirectoryBloc>().add(const DirectoryRequested());
    final bloc = context.read<MdtBloc>();
    if (bloc.state.active.uid != widget.conversationUid) {
      bloc.add(MdtOpened(uid: _uid, conversationUid: widget.conversationUid));
    }
  }

  void _send() {
    if (_invitees.isEmpty) return;
    _sent = true;
    context.read<MdtBloc>().add(
      MdtInviteRequested(
        uid: _uid,
        conversationUid: widget.conversationUid,
        inviteeUids: _invitees.toList(),
      ),
    );
  }

  void _onState(BuildContext context, MdtState state) {
    if (!_sent) return;
    switch (state) {
      case MdtWriteSuccess():
        _sent = false;
        context.pop();
      case MdtWriteFailure(:final error):
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
    final mdt = context.watch<MdtBloc>().state;
    final directory = context.watch<DirectoryBloc>().state;
    final consult = mdt.active.uid == widget.conversationUid
        ? mdt.active
        : null;
    // Anyone already invited or in is not offered again.
    final taken = <String>{
      if (consult != null)
        for (final m in consult.members.values)
          if (m.statusValue == .invited || m.statusValue == .accepted) m.uid,
    };
    final room = mdtMaxMembers - taken.length;
    final candidates = mdtInvitable(
      directory.all,
      myUid: _uid,
      excluded: taken,
    );
    final writing = mdt is MdtWriteInProgress;
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
                    title: l10n.mdtInviteColleague,
                    backLabel: l10n.commonBack,
                    onBack: context.pop,
                  ),
                ),
                Expanded(
                  child: ListView(
                    keyboardDismissBehavior: .onDrag,
                    padding: const EdgeInsets.all(AppSpacing.screenMargin),
                    children: [
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
                          limit: room < 0 ? 0 : room,
                          onToggle: (uid) => setState(() {
                            if (!_invitees.remove(uid)) _invitees.add(uid);
                          }),
                        ),
                    ],
                  ),
                ),
                BottomActionBar(
                  primary: TabibuButton.primary(
                    label: l10n.mdtSendInvite,
                    isLoading: writing,
                    onTap: _invitees.isEmpty || consult == null ? null : _send,
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
