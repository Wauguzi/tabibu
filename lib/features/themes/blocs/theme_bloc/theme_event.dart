import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';

sealed class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

final class ThemeChangeRequested extends ThemeEvent {
  const ThemeChangeRequested({required this.preference});

  final ThemePreference preference;

  @override
  List<Object?> get props => [preference];
}
