import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';

sealed class DirectoryEvent extends Equatable {
  const DirectoryEvent();

  @override
  List<Object?> get props => [];
}

/// Cache first, then a silent sync.
final class DirectoryRequested extends DirectoryEvent {
  const DirectoryRequested();
}

/// Sync first: pull-to-refresh.
final class DirectoryRefreshed extends DirectoryEvent {
  const DirectoryRefreshed();
}

final class DirectoryQueryChanged extends DirectoryEvent {
  const DirectoryQueryChanged({required this.query, this.specialty});

  final String query;
  final Specialty? specialty;

  @override
  List<Object?> get props => [query, specialty];
}

/// Back to the initial state on sign-out.
final class DirectoryReset extends DirectoryEvent {
  const DirectoryReset();
}
