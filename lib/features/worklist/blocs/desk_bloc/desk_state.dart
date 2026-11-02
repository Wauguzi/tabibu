import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';

/// The desk's filter chips.
enum DeskFilter { all, lowConfidence, waitingOver4h, notifiable }

/// The pathologist's ranked desk, with its filter and search. Every state
/// carries the last good data, so a refresh or a failure never blanks the
/// screen.
sealed class DeskState extends Equatable {
  const DeskState({
    this.entries = const <WorklistEntryModel>[],
    this.visible = const <WorklistEntryModel>[],
    this.filter = .all,
    this.query = '',
    this.offline = false,
  });

  final List<WorklistEntryModel> entries;
  final List<WorklistEntryModel> visible;
  final DeskFilter filter;
  final String query;
  final bool offline;

  @override
  List<Object?> get props => [entries, visible, filter, query, offline];
}

final class DeskInitial extends DeskState {
  const DeskInitial();
}

final class DeskLoadInProgress extends DeskState {
  const DeskLoadInProgress({
    super.entries,
    super.visible,
    super.filter,
    super.query,
    super.offline,
  });
}

final class DeskLoadSuccess extends DeskState {
  const DeskLoadSuccess({
    super.entries,
    super.visible,
    super.filter,
    super.query,
    super.offline,
  });
}

final class DeskLoadFailure extends DeskState {
  const DeskLoadFailure({
    required this.error,
    super.entries,
    super.visible,
    super.filter,
    super.query,
    super.offline,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}
