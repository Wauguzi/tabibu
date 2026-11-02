import 'package:equatable/equatable.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_state.dart';

sealed class DeskEvent extends Equatable {
  const DeskEvent();

  @override
  List<Object?> get props => [];
}

/// Cache first, then a silent sync.
final class DeskRequested extends DeskEvent {
  const DeskRequested({required this.pathologistUid});

  final String pathologistUid;

  @override
  List<Object?> get props => [pathologistUid];
}

/// Sync first: pull-to-refresh.
final class DeskRefreshed extends DeskEvent {
  const DeskRefreshed({required this.pathologistUid});

  final String pathologistUid;

  @override
  List<Object?> get props => [pathologistUid];
}

final class DeskFilterChanged extends DeskEvent {
  const DeskFilterChanged({required this.filter});

  final DeskFilter filter;

  @override
  List<Object?> get props => [filter];
}

final class DeskQueryChanged extends DeskEvent {
  const DeskQueryChanged({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Back to the initial state on sign-out.
final class DeskReset extends DeskEvent {
  const DeskReset();
}
