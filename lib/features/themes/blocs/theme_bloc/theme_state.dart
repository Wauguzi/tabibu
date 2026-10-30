import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';

/// Only the choice. `App` maps it to `ThemeMode`, so following the device
/// is the framework's job, and the bloc never touches Flutter (§5 rule 1).
final class ThemeState extends Equatable {
  const ThemeState({required this.preference});

  final ThemePreference preference;

  @override
  List<Object?> get props => [preference];
}
