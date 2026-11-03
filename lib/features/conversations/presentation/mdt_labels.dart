import 'package:intl/intl.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/features/conversations/data/models/conversation_member_model.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';
import 'package:tabibu/l10n/l10n.dart';

/// How a member is addressed: title and name.
String mdtMemberName(ConversationMemberModel member) => [
  member.title,
  member.firstName,
  member.lastName,
].where((part) => part.isNotEmpty).join(' ');

/// The short form used in a preview and a header: title and last name.
String mdtMemberShortName(ConversationMemberModel member) =>
    [member.title, member.lastName].where((p) => p.isNotEmpty).join(' ');

/// Members who have joined, the owner first.
List<ConversationMemberModel> mdtAcceptedMembers(ConversationModel consult) {
  final accepted = [
    for (final member in consult.members.values)
      if (member.statusValue == .accepted) member,
  ];
  return accepted..sort((a, b) {
    final byRole = a.memberRoleValue.index.compareTo(b.memberRoleValue.index);
    if (byRole != 0) return byRole;
    return a.invitedAt.compareTo(b.invitedAt);
  });
}

/// The de-identified reference the server gives the consult, or the same
/// reference worked out from the id when the summary is withheld from an
/// invitee. It is never the order number or a patient's name.
String mdtRef(ConversationModel consult) {
  final ref = consult.caseSummary.caseRef;
  if (ref.isNotEmpty) return ref;
  final id = consult.uid.replaceAll('-', '');
  final head = id.length > 6 ? id.substring(0, 6) : id;
  return 'MDT-${head.toUpperCase()}';
}

/// What the consult says about the patient without naming them: the age
/// band and sex the summary carries.
String mdtPatientLine(ConversationModel consult, AppLocalizations l10n) {
  final summary = consult.caseSummary;
  final sex = summary.sexValue?.description(l10n) ?? '';
  return [summary.ageBand, sex].where((p) => p.isNotEmpty).join(' · ');
}

/// The row and header title: reference, then what is known of the patient.
String mdtConsultTitle(ConversationModel consult, AppLocalizations l10n) {
  final patient = mdtPatientLine(consult, l10n);
  final ref = mdtRef(consult);
  return patient.isEmpty ? ref : l10n.mdtCasePatient(ref, patient);
}

/// A specialty's label, or the stored text for a value this version does not
/// know.
String mdtSpecialtyLabel(String raw, AppLocalizations l10n) =>
    raw.isEmpty ? '' : Specialty.fromValue(raw)?.description(l10n) ?? raw;

/// The test the summary names first, for the pinned card and the invite.
String mdtFirstTest(ConversationModel consult) {
  final names = consult.caseSummary.testNames;
  if (names.isNotEmpty) return names.first;
  final types = consult.caseSummary.testTypeNames;
  return types.isEmpty ? '' : types.first;
}

/// What an invite says the consult is about: the subject the owner wrote,
/// else the specialty asked for. An invitee has no test name to show.
String mdtInviteAbout(ConversationModel consult, AppLocalizations l10n) =>
    consult.description.isNotEmpty
    ? consult.description
    : mdtSpecialtyLabel(consult.specialty, l10n);

/// The clock time of a stored instant in Nairobi, or empty without one.
String mdtClockLabel(String iso, String language) {
  final time = nairobiTimeOf(iso);
  return time == null ? '' : DateFormat('h:mm a', language).format(time);
}

/// The time on a list row: the clock today, the weekday within the week,
/// otherwise the date.
String mdtRowTime(String iso, String language, {DateTime? now}) {
  final time = nairobiTimeOf(iso);
  if (time == null) return '';
  final today = nairobiNow(now);
  final days = nairobiDaysBefore(time, today);
  if (days <= 0) return DateFormat('h:mm a', language).format(time);
  if (days < 7) return DateFormat('EEE', language).format(time);
  return DateFormat('d MMM', language).format(time);
}

/// A stored instant as a short Nairobi date.
String mdtDateLabel(String iso, String language) {
  final time = nairobiTimeOf(iso);
  return time == null ? '' : DateFormat('d MMM', language).format(time);
}
