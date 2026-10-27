import 'package:material_ui/material_ui.dart';

/// Theme-dependent roles with no Material [ColorScheme] slot.
///
/// `primary`, `secondary` and `error` live on the color scheme. Everything
/// here is read via `Theme.of(context).extension<AppStatusColors>()`.
@immutable
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({
    required this.success,
    required this.warning,
    required this.aiDraft,
    required this.aiDraftContainer,
    required this.signed,
    required this.signedContainer,
    required this.urgencyUrgent,
    required this.urgencyPriority,
    required this.urgencyRoutine,
    required this.confidenceLow,
    required this.alertNotice,
    required this.overlayMaskParasitized,
    required this.overlayMaskUninfected,
  });

  final Color success;
  final Color warning;
  final Color aiDraft;
  final Color aiDraftContainer;
  final Color signed;
  final Color signedContainer;
  final Color urgencyUrgent;
  final Color urgencyPriority;
  final Color urgencyRoutine;
  final Color confidenceLow;
  final Color alertNotice;
  final Color overlayMaskParasitized;
  final Color overlayMaskUninfected;

  @override
  AppStatusColors copyWith({
    Color? success,
    Color? warning,
    Color? aiDraft,
    Color? aiDraftContainer,
    Color? signed,
    Color? signedContainer,
    Color? urgencyUrgent,
    Color? urgencyPriority,
    Color? urgencyRoutine,
    Color? confidenceLow,
    Color? alertNotice,
    Color? overlayMaskParasitized,
    Color? overlayMaskUninfected,
  }) {
    return AppStatusColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      aiDraft: aiDraft ?? this.aiDraft,
      aiDraftContainer: aiDraftContainer ?? this.aiDraftContainer,
      signed: signed ?? this.signed,
      signedContainer: signedContainer ?? this.signedContainer,
      urgencyUrgent: urgencyUrgent ?? this.urgencyUrgent,
      urgencyPriority: urgencyPriority ?? this.urgencyPriority,
      urgencyRoutine: urgencyRoutine ?? this.urgencyRoutine,
      confidenceLow: confidenceLow ?? this.confidenceLow,
      alertNotice: alertNotice ?? this.alertNotice,
      overlayMaskParasitized:
          overlayMaskParasitized ?? this.overlayMaskParasitized,
      overlayMaskUninfected:
          overlayMaskUninfected ?? this.overlayMaskUninfected,
    );
  }

  @override
  AppStatusColors lerp(ThemeExtension<AppStatusColors>? other, double t) {
    if (other is! AppStatusColors) return this;
    return AppStatusColors(
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      aiDraft: Color.lerp(aiDraft, other.aiDraft, t) ?? aiDraft,
      aiDraftContainer:
          Color.lerp(aiDraftContainer, other.aiDraftContainer, t) ??
          aiDraftContainer,
      signed: Color.lerp(signed, other.signed, t) ?? signed,
      signedContainer:
          Color.lerp(signedContainer, other.signedContainer, t) ??
          signedContainer,
      urgencyUrgent:
          Color.lerp(urgencyUrgent, other.urgencyUrgent, t) ?? urgencyUrgent,
      urgencyPriority:
          Color.lerp(urgencyPriority, other.urgencyPriority, t) ??
          urgencyPriority,
      urgencyRoutine:
          Color.lerp(urgencyRoutine, other.urgencyRoutine, t) ?? urgencyRoutine,
      confidenceLow:
          Color.lerp(confidenceLow, other.confidenceLow, t) ?? confidenceLow,
      alertNotice: Color.lerp(alertNotice, other.alertNotice, t) ?? alertNotice,
      overlayMaskParasitized:
          Color.lerp(overlayMaskParasitized, other.overlayMaskParasitized, t) ??
          overlayMaskParasitized,
      overlayMaskUninfected:
          Color.lerp(overlayMaskUninfected, other.overlayMaskUninfected, t) ??
          overlayMaskUninfected,
    );
  }
}
