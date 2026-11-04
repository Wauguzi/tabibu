import 'package:tabibu/l10n/l10n.dart';

/// The patient's result strings, each chosen by which of its parts is
/// present, so a missing date, doctor or lab never leaves "on ." or a bare
/// separator behind.
extension ResultCopy on AppLocalizations {
  String resultsWaitingBodyFor(String doctor, String date) {
    if (doctor.isEmpty) {
      return date.isEmpty
          ? resultsWaitingBodyBare
          : resultsWaitingBodyNoDoctor(date);
    }
    return date.isEmpty
        ? resultsWaitingBodyNoDate(doctor)
        : resultsWaitingBody(doctor, date);
  }

  String resultsSlideBodyFor(String doctor, String date) {
    if (doctor.isEmpty) {
      return date.isEmpty
          ? resultsSlideBodyBare
          : resultsSlideBodyNoDoctor(date);
    }
    return date.isEmpty
        ? resultsSlideBodyNoDate(doctor)
        : resultsSlideBody(doctor, date);
  }

  String resultsWaitingSubtitleFor(String doctor) => doctor.isEmpty
      ? resultsWaitingSubtitleNoDoctor
      : resultsWaitingSubtitle(doctor);

  String resultsStepSampleDetailFor(String date, String facility) {
    if (facility.isEmpty) return date;
    return date.isEmpty
        ? resultsStepSampleDetailNoDate(facility)
        : resultsStepSampleDetail(date, facility);
  }

  String resultsStepReviewedDetailFor(String date, String doctor, String lab) {
    if (date.isNotEmpty && doctor.isNotEmpty && lab.isNotEmpty) {
      return resultsStepReviewedDetail(date, doctor, lab);
    }
    if (date.isEmpty && doctor.isNotEmpty && lab.isNotEmpty) {
      return resultsStepReviewedDetailNoDate(doctor, lab);
    }
    if (date.isNotEmpty && doctor.isNotEmpty) {
      return resultsStepReviewedDetailNoLab(date, doctor);
    }
    if (date.isNotEmpty && lab.isNotEmpty) {
      return resultsStepReviewedDetailNoDoctor(date, lab);
    }
    // One part left, or none: nothing to separate.
    return [
      date,
      doctor,
      lab,
    ].firstWhere((p) => p.isNotEmpty, orElse: () => '');
  }

  String resultsStepTalkFor(String doctor) =>
      doctor.isEmpty ? resultsStepTalkNoDoctor : resultsStepTalk(doctor);

  String resultsStepTalkDetailFor(String date, String time) {
    if (date.isEmpty) return resultsStepTalkDetailNoDate;
    return time.isEmpty
        ? resultsStepTalkDetailNoTime(date)
        : resultsStepTalkDetail(date, time);
  }

  String resultsRowSharedByFor(String doctor, String date) {
    if (doctor.isEmpty) {
      return date.isEmpty
          ? resultsRowSharedByBare
          : resultsRowSharedByNoDoctor(date);
    }
    return date.isEmpty
        ? resultsRowSharedByNoDate(doctor)
        : resultsRowSharedBy(doctor, date);
  }

  String resultsRowOrderedByFor(String doctor, String item) {
    if (item.isEmpty) return resultsWaitingSubtitleFor(doctor);
    return doctor.isEmpty
        ? resultsRowOrderedByNoDoctor(item)
        : resultsRowOrderedBy(doctor, item);
  }
}
