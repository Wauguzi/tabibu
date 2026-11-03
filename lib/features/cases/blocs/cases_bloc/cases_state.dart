import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/cases/data/models/case_log_entry_model.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';

/// Cases and their signed reports for any role: a patient's results, a doctor's
/// cases, a pathologist's signed work. Every state carries the last good data,
/// so a refresh or a failure never blanks the screen.
sealed class CasesState extends Equatable {
  const CasesState({
    this.cases = const <CaseModel>[],
    this.reports = const <PathologyReportModel>[],
    this.logs = const <String, List<CaseLogEntryModel>>{},
    this.offline = false,
  });

  final List<CaseModel> cases;
  final List<PathologyReportModel> reports;
  final Map<String, List<CaseLogEntryModel>> logs;
  final bool offline;

  @override
  List<Object?> get props => [cases, reports, logs, offline];
}

final class CasesInitial extends CasesState {
  const CasesInitial();
}

final class CasesLoadInProgress extends CasesState {
  const CasesLoadInProgress({
    super.cases,
    super.reports,
    super.logs,
    super.offline,
  });
}

final class CasesLoadSuccess extends CasesState {
  const CasesLoadSuccess({
    super.cases,
    super.reports,
    super.logs,
    super.offline,
  });
}

final class CasesLoadFailure extends CasesState {
  const CasesLoadFailure({
    required this.error,
    super.cases,
    super.reports,
    super.logs,
    super.offline,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}

final class CaseWriteInProgress extends CasesState {
  const CaseWriteInProgress({
    super.cases,
    super.reports,
    super.logs,
    super.offline,
  });
}

final class CaseNotesSaveSuccess extends CasesState {
  const CaseNotesSaveSuccess({
    super.cases,
    super.reports,
    super.logs,
    super.offline,
  });
}

final class CaseWriteFailure extends CasesState {
  const CaseWriteFailure({
    required this.error,
    super.cases,
    super.reports,
    super.logs,
    super.offline,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}
