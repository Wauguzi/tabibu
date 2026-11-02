import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/appointments/presentation/widgets/booking_request_card.dart';
import 'package:tabibu/features/appointments/presentation/widgets/decline_booking_sheet.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// How long the accepted strip stays. The server has no undo, so it carries
/// none.
const _acceptedStripDuration = Duration(seconds: 4);

/// D-BOOKINGS. The doctor's pending booking requests, soonest first, each to
/// accept or decline.
class BookingRequestsScreen extends StatefulWidget {
  const BookingRequestsScreen({super.key});

  @override
  State<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen> {
  /// The request this screen last sent a decision for. The write state does
  /// not say which appointment it is for, so the screen remembers.
  String? _pendingUid;

  /// The request just accepted, while its strip shows.
  AppointmentModel? _accepted;
  Timer? _acceptedTimer;

  @override
  void initState() {
    super.initState();
    final uid = switch (context.read<AuthBloc>().state.session) {
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    context.read<AppointmentsBloc>().add(
      AppointmentsRequested(uid: uid, role: .doctor),
    );
  }

  @override
  void dispose() {
    _acceptedTimer?.cancel();
    super.dispose();
  }

  void _decide(AppointmentDecisionRequested event) {
    _pendingUid = event.appointmentUid;
    context.read<AppointmentsBloc>().add(event);
  }

  Future<void> _decline(AppointmentModel request) async {
    final choice = await DeclineBookingSheet.show(
      context,
      name: request.patientName,
    );
    if (choice == null || !mounted) return;
    _decide(
      AppointmentDecisionRequested(
        appointmentUid: request.uid,
        accept: false,
        reason: choice.reason,
        note: choice.note,
      ),
    );
  }

  void _onState(BuildContext context, AppointmentsState state) {
    switch (state) {
      case AppointmentWriteInProgress():
        return;
      case AppointmentWriteFailure(:final error):
        unawaited(
          showTabibuNotification(
            context,
            message: error.description(context.l10n),
            isError: true,
            dismissLabel: context.l10n.commonDismiss,
          ),
        );
      case AppointmentDecisionSuccess(:final appointment)
          when appointment.statusValue == .accepted:
        _acceptedTimer?.cancel();
        setState(() => _accepted = appointment);
        _acceptedTimer = Timer(_acceptedStripDuration, () {
          if (mounted) setState(() => _accepted = null);
        });
      default:
        break;
    }
    _pendingUid = null;
  }

  /// The requests still waiting, soonest start first; one with no readable
  /// start goes last.
  List<AppointmentModel> _requests(List<AppointmentModel> rows) {
    final requests =
        [
          for (final row in rows)
            if (row.isRequested) (row, nairobiTimeOf(row.scheduledStart)),
        ]..sort((a, b) {
          final (_, left) = a;
          final (_, right) = b;
          if (left == null) return right == null ? 0 : 1;
          if (right == null) return -1;
          return left.compareTo(right);
        });
    return [for (final (row, _) in requests) row];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final state = context.watch<AppointmentsBloc>().state;
    final requests = _requests(state.appointments);
    final loading =
        (state is AppointmentsInitial || state is AppointmentsLoadInProgress) &&
        state.appointments.isEmpty;
    final accepted = _accepted;

    return BlocListener<AppointmentsBloc, AppointmentsState>(
      listener: _onState,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenMargin,
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.md),
                TopBar(
                  backLabel: l10n.commonBack,
                  onBack: context.pop,
                  title: l10n.bookingRequestsTitle,
                  // A count line comes from data and never shows over none.
                  subtitle: requests.isEmpty
                      ? null
                      : l10n.bookingRequestsNewToday(requests.length),
                ),
                Expanded(
                  child: loading
                      ? LoadingView(
                          semanticLabel: l10n.bookingRequestsLoadingLabel,
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          children: [
                            if (accepted != null) ...[
                              _AcceptedStrip(
                                appointment: accepted,
                                language: language,
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                            if (requests.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.sectionGap,
                                ),
                                child: EmptyState(
                                  icon: Assets.icons.calendarIcon,
                                  tone: .lavender,
                                  title: l10n.bookingRequestsEmptyTitle,
                                  body: l10n.bookingRequestsEmptyBody,
                                ),
                              )
                            else ...[
                              for (final request in requests) ...[
                                _RequestCard(
                                  request: request,
                                  language: language,
                                  busy:
                                      state is AppointmentWriteInProgress &&
                                      _pendingUid == request.uid,
                                  onAccept: () => _decide(
                                    AppointmentDecisionRequested(
                                      appointmentUid: request.uid,
                                      accept: true,
                                    ),
                                  ),
                                  onDecline: () => unawaited(_decline(request)),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                              Text(
                                l10n.bookingRequestsFootnote,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ],
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

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.language,
    required this.busy,
    required this.onAccept,
    required this.onDecline,
  });

  final AppointmentModel request;
  final String language;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final start = nairobiTimeOf(request.scheduledStart);
    final symptoms = request.symptomText.trim();
    return BookingRequestCard(
      name: request.patientName,
      // The card joins these two with a dot. There is no translated label for
      // the appointment type yet, so the clock takes its place rather than an
      // English word.
      when: start == null
          ? ''
          : DateFormat('EEE d MMM', language).format(start),
      type: start == null ? '' : DateFormat('h:mm a', language).format(start),
      supporting: symptoms.isEmpty ? null : symptoms,
      acceptLabel: l10n.bookingRequestsAccept,
      declineLabel: l10n.bookingRequestsDecline,
      busy: busy,
      onAccept: onAccept,
      onDecline: onDecline,
    );
  }
}

class _AcceptedStrip extends StatelessWidget {
  const _AcceptedStrip({required this.appointment, required this.language});

  final AppointmentModel appointment;
  final String language;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final start = nairobiTimeOf(appointment.scheduledStart);
    final firstName = appointment.patientName.split(' ').first;
    return Semantics(
      liveRegion: true,
      child: NoticeCard(
        variant: .info,
        icon: Assets.icons.tickIcon,
        title: l10n.bookingRequestsAcceptedTitle(
          start == null ? '' : DateFormat('EEE d MMM', language).format(start),
        ),
        body: l10n.bookingRequestsAcceptedBody(
          firstName,
          start == null ? '' : DateFormat('h:mm a', language).format(start),
        ),
      ),
    );
  }
}
