import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';

/// What the signed-in person may do, read from their ID token's custom
/// claims (architecture §11). Screens ask this, never compare a role string.
///
/// Claims are set only by Cloud Functions (CRQ-0016), so this is a view of
/// what the server already enforces. An unknown or missing claim grants
/// nothing; it never throws.
class RoleHelper extends Equatable {
  const RoleHelper({
    required this.role,
    required this.isAdmin,
    required this.isAlertApprover,
  });

  factory RoleHelper.fromClaims(Map<String, dynamic>? claims) {
    final raw = claims?['role'];
    return RoleHelper(
      role: raw is String ? Role.fromClaim(raw) : null,
      isAdmin: claims?['admin'] == true,
      isAlertApprover: claims?['alertApprover'] == true,
    );
  }

  static const none = RoleHelper(
    role: null,
    isAdmin: false,
    isAlertApprover: false,
  );

  /// Null for a signed-in account without a role: a sign-up not finished,
  /// or a practitioner awaiting verification.
  final Role? role;
  final bool isAdmin;
  final bool isAlertApprover;

  bool get hasRole => role != null;
  bool get isPatient => role == .patient;
  bool get isDoctor => role == .doctor;
  bool get isPathologist => role == .pathologist;
  bool get isPractitioner => isDoctor || isPathologist;

  bool get canAddPatients => isDoctor;

  /// Approval is a permission on a doctor, never on its own.
  bool get canApproveAlerts => isDoctor && isAlertApprover;

  bool get canVerifyPractitioners => isAdmin;

  @override
  List<Object?> get props => [role, isAdmin, isAlertApprover];
}
