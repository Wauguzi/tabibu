import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';

/// One row on who-can-see: care-team or a shared viewer.
final class ShareViewer extends Equatable {
  const ShareViewer({
    required this.uid,
    required this.displayName,
    required this.role,
    required this.removable,
  });

  final String uid;
  final String displayName;
  final ActorRole role;

  /// False for the treating doctor and the pathologist (rule 3).
  final bool removable;

  @override
  List<Object?> get props => [uid, displayName, role, removable];
}
