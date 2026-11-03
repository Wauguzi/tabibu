import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/appointments/presentation/widgets/cancel_sheet.dart';
import 'package:tabibu/features/appointments/presentation/widgets/case_notes_sheet.dart';
import 'package:tabibu/features/appointments/presentation/widgets/move_sheet.dart';
import 'package:tabibu/features/appointments/presentation/widgets/patient_card.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/presentation/widgets/case_stepper.dart';
import 'package:tabibu/features/cases/presentation/widgets/notes_card.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// A sheet's close animation. A result acted on sooner lands mid-slide.
const _sheetClosedAfter = Duration(milliseconds: 600);

/// The five doctor steps on [CaseModel.doctorStep]; 5 means all done.
const _stepCount = 5;

/// D-APPT. One screen in two states: with a case (variant A: stepper, notes)
/// and a first visit with none (variant B: why the patient booked).
class DoctorAppointmentScreen extends StatefulWidget {
  const DoctorAppointmentScreen({required this.appointmentUid, super.key});

  final String appointmentUid;

  @override
  State<DoctorAppointmentScreen> createState() =>
      _DoctorAppointmentScreenState();
}

class _DoctorAppointmentScreenState extends State<DoctorAppointmentScreen> {
  /// Set while this screen's own complete request is out; the write state does
  /// not say which appointment it is for, so the screen remembers.
  bool _ending = false;

  /// A move or cancel this screen sent and still waits on.
  bool _cancelling = false;

  /// This appointment was ended from here: the bar reads "Ended".
  bool _ended = false;

  /// The next moment the bar's buttons change, so a screen left open flips
  /// without a tap.
  Timer? _boundaryTimer;
  DateTime? _boundary;

  @override
  void initState() {
    super.initState();
    final uid = switch (context.read<AuthBloc>().state.session) {
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    final appointments = context.read<AppointmentsBloc>();
    final known = appointments.state.appointments.any(
      (a) => a.uid == widget.appointmentUid,
    );
    if (!known) {
      appointments.add(AppointmentsRequested(uid: uid, role: .doctor));
    }
    final cases = context.read<CasesBloc>();
    if (cases.state.cases.isEmpty) {
      cases.add(CasesRequested(uid: uid, role: .doctor));
    }
  }

  @override
  void dispose() {
    _boundaryTimer?.cancel();
    super.dispose();
  }

  /// Re-arms the timer for the soonest of start and end still ahead.
  void _scheduleBoundary(AppointmentModel appointment) {
    final now = DateTime.now();
    final next =
        [
              DateTime.tryParse(appointment.scheduledStart),
              DateTime.tryParse(appointment.scheduledEnd),
            ].nonNulls
            .where((time) => time.isAfter(now))
            .sorted((a, b) => a.compareTo(b));
    final boundary = next.firstOrNull;
    if (boundary == null) {
      _boundaryTimer?.cancel();
      _boundary = null;
      return;
    }
    if (_boundary != null && _boundary!.isAtSameMomentAs(boundary)) return;
    _boundaryTimer?.cancel();
    _boundary = boundary;
    _boundaryTimer = Timer(boundary.difference(now), () {
      _boundary = null;
      if (mounted) setState(() {});
    });
  }

  void _onAppointmentsState(BuildContext context, AppointmentsState state) {
    switch (state) {
      case AppointmentWriteInProgress():
        return;
      case AppointmentWriteFailure(:final error) when _ending:
        unawaited(
          showTabibuNotification(
            context,
            message: error.description(context.l10n),
            isError: true,
            dismissLabel: context.l10n.commonDismiss,
          ),
        );
      case AppointmentWriteFailure(:final error) when _cancelling:
        _cancelling = false;
        unawaited(
          showTabibuNotification(
            context,
            message: error.description(context.l10n),
            isError: true,
            dismissLabel: context.l10n.commonDismiss,
          ),
        );
      case AppointmentCompleteSuccess(:final appointment)
          when _ending && appointment.uid == widget.appointmentUid:
        setState(() => _ended = true);
      case AppointmentCancelSuccess():
        _cancelling = false;
      default:
        return;
    }
    _ending = false;
  }

  void _complete(String outcome) {
    _ending = true;
    context.read<AppointmentsBloc>().add(
      AppointmentCompleteRequested(
        appointmentUid: widget.appointmentUid,
        outcome: outcome,
      ),
    );
  }

  Future<void> _showOptions(AppointmentModel appointment) async {
    final l10n = context.l10n;
    final start = DateTime.tryParse(appointment.scheduledStart);
    final upcoming = start != null && start.isAfter(DateTime.now());
    final end = DateTime.tryParse(appointment.scheduledEnd);
    final slotOver = end != null && !end.isAfter(DateTime.now());
    final choice = await showOptionsSheet<String>(
      context,
      title: appointment.patientName,
      actions: [
        if (upcoming)
          OptionsAction(
            value: 'Move',
            icon: Assets.icons.calendarIcon,
            label: l10n.rescheduleEntryMove,
            supporting: l10n.rescheduleEntryMoveBody,
          ),
        // Chat buttons F-11 hid; S-3 / bundle 51 put them back.
        OptionsAction(
          value: 'Chat',
          icon: Assets.icons.chatIcon,
          label: l10n.chatMessagePatient,
          supporting: l10n.chatMessagePatientBody,
        ),
        if (upcoming)
          OptionsAction(
            value: 'Cancel',
            icon: Assets.icons.cancelCircleIcon,
            label: l10n.cancelAppointmentConfirm,
            supporting: l10n.cancelAppointmentEntryBodyDoctor,
          ),
        if (slotOver)
          OptionsAction(
            value: 'NoShow',
            icon: Assets.icons.cancelCircleIcon,
            // cspell:ignore Didnt
            label: l10n.doctorAppointmentDidntCome,
          ),
      ],
    );
    if (choice == null) return;
    // The write's notice must not open over the sliding sheet.
    await Future<void>.delayed(_sheetClosedAfter);
    if (!mounted) return;
    switch (choice) {
      case 'Move':
        await _move(appointment);
      case 'Chat':
        await DoctorAppointmentChatRoute(
          appointmentUid: appointment.uid,
        ).push<void>(context);
      case 'Cancel':
        await _cancel(appointment);
      default:
        _complete(choice);
    }
  }

  Future<void> _move(AppointmentModel appointment) async {
    final choice = await MoveSheet.show(context, appointment: appointment);
    if (choice == null || !mounted) return;
    final session = context.read<AuthBloc>().state.session;
    final doctorUid = switch (session) {
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    _cancelling = true;
    context.read<AppointmentsBloc>().add(
      AppointmentCancelRequested(
        appointmentUid: appointment.uid,
        cancelledByUid: doctorUid,
        reason: context.l10n.rescheduleMoveTo(_proposed(choice.start)),
        note: [
          choice.reason,
          choice.note,
        ].where((part) => part.isNotEmpty).join('\n'),
      ),
    );
  }

  Future<void> _cancel(AppointmentModel appointment) async {
    final choice = await CancelSheet.show(
      context,
      appointment: appointment,
      isDoctor: true,
    );
    if (choice == null || !mounted) return;
    final session = context.read<AuthBloc>().state.session;
    final doctorUid = switch (session) {
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    _cancelling = true;
    context.read<AppointmentsBloc>().add(
      AppointmentCancelRequested(
        appointmentUid: appointment.uid,
        cancelledByUid: doctorUid,
        reason: choice.reason,
        note: choice.note,
      ),
    );
  }

  /// The proposed time as the move reads on the cancelled detail.
  String _proposed(DateTime start) {
    final language = Localizations.localeOf(context).languageCode;
    final nairobi = nairobiTimeOf(start.toUtc().toIso8601String()) ?? start;
    return '${DateFormat('EEE d MMM', language).format(nairobi)} · '
        '${DateFormat('h:mm a', language).format(nairobi)}';
  }

  Future<void> _editNotes(CaseModel appointmentCase) async {
    final saved = await CaseNotesSheet.show(
      context,
      caseUid: appointmentCase.uid,
      initialNotes: appointmentCase.clinicalNotes,
    );
    if (saved != true) return;
    await Future<void>.delayed(_sheetClosedAfter);
    if (!mounted) return;
    unawaited(
      showTabibuNotification(
        context,
        message: context.l10n.doctorAppointmentNotesSaved,
        isError: false,
        dismissLabel: context.l10n.commonDismiss,
      ),
    );
  }

  /// The case this visit is about: the discussed one, else the newest of the
  /// appointment's cases that this doctor has.
  CaseModel? _caseOf(AppointmentModel appointment, List<CaseModel> cases) {
    if (appointment.discussedCaseUid.isNotEmpty) {
      return cases.firstWhereOrNull(
        (c) => c.uid == appointment.discussedCaseUid,
      );
    }
    final mine = cases.where((c) => appointment.caseUids.contains(c.uid));
    return mine
        .sorted((a, b) => _created(b).compareTo(_created(a)))
        .firstOrNull;
  }

  DateTime _created(CaseModel c) =>
      DateTime.tryParse(c.createdAt) ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  @override
  Widget build(BuildContext context) {
    final appointmentsState = context.watch<AppointmentsBloc>().state;
    final casesState = context.watch<CasesBloc>().state;
    final appointment = appointmentsState.appointments.firstWhereOrNull(
      (a) => a.uid == widget.appointmentUid,
    );
    final l10n = context.l10n;

    final Widget content;
    if (appointment == null) {
      final loading =
          appointmentsState is AppointmentsInitial ||
          appointmentsState is AppointmentsLoadInProgress;
      content = _Shell(
        topBar: TopBar(backLabel: l10n.commonBack, onBack: context.pop),
        body: loading
            ? SizedBox(
                height: 280,
                child: LoadingView(
                  semanticLabel: l10n.appointmentDetailLoadingLabel,
                ),
              )
            : EmptyState(
                title: l10n.appointmentDetailNotFoundTitle,
                icon: Assets.icons.searchRoundedIcon,
                body: l10n.appointmentDetailNotFoundBody,
              ),
      );
    } else {
      final linkedCase = _caseOf(appointment, casesState.cases);
      final hasCaseRefs =
          appointment.discussedCaseUid.isNotEmpty ||
          appointment.caseUids.isNotEmpty;
      final casesLoading =
          casesState is CasesInitial || casesState is CasesLoadInProgress;
      // A case the appointment points at may still be on its way: no variant
      // B flash for a returning patient.
      if (linkedCase == null && hasCaseRefs && casesLoading) {
        content = _Shell(
          topBar: TopBar(backLabel: l10n.commonBack, onBack: context.pop),
          body: SizedBox(
            height: 280,
            child: LoadingView(
              semanticLabel: l10n.appointmentDetailLoadingLabel,
            ),
          ),
        );
      } else {
        _scheduleBoundary(appointment);
        content = _detail(
          appointment: appointment,
          linkedCase: linkedCase,
          appointmentsState: appointmentsState,
          allAppointments: appointmentsState.appointments,
        );
      }
    }

    return BlocListener<AppointmentsBloc, AppointmentsState>(
      listener: _onAppointmentsState,
      child: Scaffold(body: RoleBackground.doctor(child: content)),
    );
  }

  Widget _detail({
    required AppointmentModel appointment,
    required CaseModel? linkedCase,
    required AppointmentsState appointmentsState,
    required List<AppointmentModel> allAppointments,
  }) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final start = DateTime.tryParse(appointment.scheduledStart);
    final end = DateTime.tryParse(appointment.scheduledEnd);
    final started = start != null && !start.isAfter(now);
    final status = appointment.statusValue;
    // Only an accepted visit still has something to do: every other state
    // (completed, no-show, declined, cancelled, requested, expired) is
    // read-only.
    final live = status == .accepted;
    final busy = _ending && appointmentsState is AppointmentWriteInProgress;
    final showActions = live && !_ended;
    // Ordered at this visit but never sent, or refused and needing
    // another pathologist: the button picks up where the order stopped.
    final unsent =
        linkedCase != null &&
        (linkedCase.currentStageValue == .orderCreated ||
            linkedCase.currentStageValue == .pathologistRejected) &&
        linkedCase.appointmentUid == appointment.uid;
    final nairobiStart = nairobiTimeOf(appointment.scheduledStart);
    final firstName = appointment.patientName.trim().split(' ').first;

    final title = linkedCase == null
        ? l10n.doctorAppointmentNewTitle
        : appointment.typeValue.description(l10n);

    final body = <Widget>[
      PatientCard(
        name: appointment.patientName,
        details: _details(appointment, linkedCase, language),
      ),
      const SizedBox(height: AppSpacing.md),
      if (linkedCase != null) ...[
        _StepperCard(linkedCase: linkedCase),
        const SizedBox(height: AppSpacing.md),
        _InfoTiles(
          appointment: appointment,
          linkedCase: linkedCase,
          language: language,
        ),
        const SizedBox(height: AppSpacing.md),
        // An empty card is a target too; the pencil carries the semantics.
        GestureDetector(
          behavior: .opaque,
          onTap: linkedCase.clinicalNotes.trim().isEmpty
              ? () => unawaited(_editNotes(linkedCase))
              : null,
          child: NotesCard(
            title: l10n.doctorAppointmentNotes,
            text: linkedCase.clinicalNotes,
            placeholder: l10n.doctorAppointmentNotesHint,
            editLabel: l10n.doctorAppointmentEditNotes,
            onEdit: () => unawaited(_editNotes(linkedCase)),
          ),
        ),
      ] else
        KeyValueCard(
          title: l10n.doctorAppointmentWhyBooked(firstName),
          rows: [
            (
              l10n.doctorAppointmentRowAppointment,
              _typeAndLength(appointment, start, end),
            ),
            if (appointment.symptomLanguage.isNotEmpty)
              (
                l10n.doctorAppointmentRowLanguage,
                AppLanguage.fromValue(
                  appointment.symptomLanguage,
                ).description(l10n),
              ),
            (
              l10n.doctorAppointmentRowFirstTime,
              _isFirstVisit(appointment, allAppointments)
                  ? l10n.doctorAppointmentFirstYes
                  : l10n.doctorAppointmentFirstNo,
            ),
          ],
        ),
      if (showActions && !started) ...[
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.doctorAppointmentEndDisabled,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ];

    return _Shell(
      topBar: TopBar(
        backLabel: l10n.commonBack,
        onBack: context.pop,
        title: title,
        subtitle: nairobiStart == null
            ? null
            : DateFormat('EEE d MMM · h:mm a', language).format(nairobiStart),
        trailing: Row(
          mainAxisSize: .min,
          children: [
            IconButton(
              icon: AssetIcon(Assets.icons.calendarIcon, size: 20),
              tooltip: l10n.calendarTitle,
              onPressed: () => const DoctorCalendarRoute().push<void>(context),
            ),
            // Options stay available for the whole live visit so Message
            // the patient (bundle 51) is reachable mid-appointment too.
            if (showActions)
              MoreButton(
                semanticLabel: l10n.notificationsMoreLabel,
                onTap: busy ? null : () => unawaited(_showOptions(appointment)),
              ),
          ],
        ),
      ),
      body: Column(crossAxisAlignment: .stretch, children: body),
      bottom: _ended
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Semantics(
                  liveRegion: true,
                  child: Center(
                    child: StatusChip(
                      label: l10n.doctorAppointmentEnded,
                      tone: .closed,
                    ),
                  ),
                ),
              ),
            )
          : showActions
          ? BottomActionBar(
              secondary: TabibuButton.secondary(
                label: l10n.doctorAppointmentEnd,
                isLoading: busy,
                onTap: started && !busy ? () => _complete('Completed') : null,
              ),
              primary: TabibuButton.primary(
                label: unsent
                    ? l10n.doctorCaseAttachPathologist
                    : l10n.doctorAppointmentOrderTest,
                onTap: busy
                    ? null
                    : () => unawaited(
                        OrderRoute(
                          appointmentUid: appointment.uid,
                          caseUid: unsent ? linkedCase.uid : '',
                        ).push<void>(context),
                      ),
              ),
            )
          : null,
    );
  }

  /// The card's second line: the case's age and sex, else who booked and when.
  String _details(
    AppointmentModel appointment,
    CaseModel? linkedCase,
    String language,
  ) {
    final l10n = context.l10n;
    if (linkedCase != null) {
      final sex = linkedCase.patientSexValue?.description(l10n);
      final parts = [
        if (linkedCase.patientAgeYears > 0) '${linkedCase.patientAgeYears}',
        ?sex,
      ];
      if (parts.isNotEmpty) return parts.join(' · ');
    }
    return _bookedByLine(context.l10n, appointment, language);
  }

  String _typeAndLength(
    AppointmentModel appointment,
    DateTime? start,
    DateTime? end,
  ) {
    final l10n = context.l10n;
    final type = appointment.typeValue.description(l10n);
    if (start == null || end == null) return type;
    final minutes = end.difference(start).inMinutes;
    if (minutes <= 0) return type;
    return l10n.doctorAppointmentTypeDuration(type, minutes);
  }

  /// No case and no other finished visit with this patient.
  bool _isFirstVisit(AppointmentModel appointment, List<AppointmentModel> all) {
    if (appointment.caseUids.isNotEmpty) return false;
    return !all.any(
      (other) =>
          other.uid != appointment.uid &&
          other.patientUid.isNotEmpty &&
          other.patientUid == appointment.patientUid &&
          other.statusValue == .completed,
    );
  }
}

/// "Booked by {name}, {date}". The data carries no area to add.
String _bookedByLine(
  AppLocalizations l10n,
  AppointmentModel appointment,
  String language,
) {
  final byDoctor =
      appointment.createdByUid.isNotEmpty &&
      appointment.createdByUid == appointment.doctorUid;
  final booker = (byDoctor ? appointment.doctorName : appointment.patientName)
      .trim()
      .split(' ')
      .first;
  final booked =
      nairobiTimeOf(appointment.createdAt) ??
      nairobiTimeOf(appointment.scheduledStart);
  return l10n.doctorAppointmentBookedBy(
    booker,
    booked == null ? '' : DateFormat('EEE d MMM', language).format(booked),
  );
}

/// The scrolling page, with an optional pinned bottom area.
class _Shell extends StatelessWidget {
  const _Shell({required this.topBar, required this.body, this.bottom});

  final Widget topBar;
  final Widget body;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final bottom = this.bottom;
    return SafeArea(
      bottom: bottom == null,
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Expanded(
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
                      topBar,
                      const SizedBox(height: AppSpacing.md),
                      body,
                    ],
                  ),
                ),
              ],
            ),
          ),
          ?bottom,
        ],
      ),
    );
  }
}

/// The case's five doctor steps and the next one, in a card titled with the
/// order number.
class _StepperCard extends StatelessWidget {
  const _StepperCard({required this.linkedCase});

  final CaseModel linkedCase;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    // The model maps the stages; the screen only reads its step.
    final current = linkedCase.doctorStep;
    final labels = [
      l10n.appointmentsTypeConsultation,
      l10n.doctorCasesOrdered,
      l10n.rolePathologist,
      l10n.doctorCasesSigned,
      l10n.doctorCasesDiscuss,
    ];
    final done = current >= _stepCount;
    final next = !done && current + 1 < _stepCount ? labels[current + 1] : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Padding(
        padding: AppStyles.cardPadding,
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    linkedCase.orderNumber,
                    style: textTheme.titleMedium,
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                ),
                if (done)
                  StatusChip(label: l10n.chipDone, tone: .signed)
                else if (next != null)
                  Flexible(
                    child: StatusChip(
                      label: '${l10n.doctorCaseNext} · $next',
                      tone: .info,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            CaseStepper(
              labels: labels,
              current: current,
              scrollable: true,
              semanticLabel: done
                  ? l10n.chipDone
                  : '${labels[current]} · ${l10n.doctorCaseNow}',
            ),
          ],
        ),
      ),
    );
  }
}

/// Booked-by and preferred-language tiles side by side.
class _InfoTiles extends StatelessWidget {
  const _InfoTiles({
    required this.appointment,
    required this.linkedCase,
    required this.language,
  });

  final AppointmentModel appointment;
  final CaseModel linkedCase;
  final String language;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final preferred = appointment.symptomLanguage.isNotEmpty
        ? appointment.symptomLanguage
        : linkedCase.notesLanguage;

    final bookedTile = ShortcutTile(
      icon: Assets.icons.calendarIcon,
      tone: .mint,
      title: appointment.typeValue.description(l10n),
      body: _bookedByLine(l10n, appointment, language),
    );
    if (preferred.isEmpty) return bookedTile;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: .stretch,
        children: [
          Expanded(child: bookedTile),
          const SizedBox(width: AppSpacing.bentoGap),
          Expanded(
            child: ShortcutTile(
              icon: Assets.icons.languageIcon,
              tone: .sky,
              title: AppLanguage.fromValue(preferred).description(l10n),
              body: l10n.doctorAppointmentPreferredLanguage,
            ),
          ),
        ],
      ),
    );
  }
}
