import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';

/// The public directory of practitioners, filtered for the patient's search.
/// Every state carries the last good data, so a refresh or a failure never
/// blanks the screen.
sealed class DirectoryState extends Equatable {
  const DirectoryState({
    this.all = const <PractitionerModel>[],
    this.visible = const <PractitionerModel>[],
    this.query = '',
    this.specialty,
    this.offline = false,
  });

  final List<PractitionerModel> all;
  final List<PractitionerModel> visible;
  final String query;
  final Specialty? specialty;
  final bool offline;

  @override
  List<Object?> get props => [all, visible, query, specialty, offline];
}

final class DirectoryInitial extends DirectoryState {
  const DirectoryInitial();
}

final class DirectoryLoadInProgress extends DirectoryState {
  const DirectoryLoadInProgress({
    super.all,
    super.visible,
    super.query,
    super.specialty,
    super.offline,
  });
}

final class DirectoryLoadSuccess extends DirectoryState {
  const DirectoryLoadSuccess({
    super.all,
    super.visible,
    super.query,
    super.specialty,
    super.offline,
  });
}

final class DirectoryLoadFailure extends DirectoryState {
  const DirectoryLoadFailure({
    required this.error,
    super.all,
    super.visible,
    super.query,
    super.specialty,
    super.offline,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}
