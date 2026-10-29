import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/home/presentation/widgets/home_header.dart';
import 'package:tabibu/features/home/presentation/widgets/shell_tab_page.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The first tab of every role: the header for now; the body comes with its
/// screens.
class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({required this.role, super.key});

  final Role role;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = context.watch<AuthBloc>().state.session;
    final date = DateFormat(
      'EEE d MMM',
      Localizations.localeOf(context).languageCode,
    ).format(DateTime.now());

    final header = switch (session) {
      PatientSession(:final patient) => HomeHeader(
        name: patient.fullName,
        greeting: l10n.homeGreeting(patient.firstName),
        subtitle: l10n.homeSubtitlePatient(
          patient.subCounty.isEmpty ? patient.county : patient.subCounty,
          date,
        ),
        photoUrl: patient.profilePictureUrl,
        notificationsLabel: l10n.profileNotifications,
      ),
      PractitionerSession(:final doctor) => HomeHeader(
        name: '${doctor.firstName} ${doctor.lastName}',
        greeting: l10n.homeGreeting('${doctor.title} ${doctor.lastName}'),
        subtitle: l10n.homeSubtitlePractitioner(date, doctor.facilityName),
        photoUrl: doctor.profilePictureUrl,
        notificationsLabel: l10n.profileNotifications,
      ),
      // Signing out: the guard is about to leave this route.
      _ => null,
    };

    return ShellTabPage(role: role, children: [?header]);
  }
}
