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
    required this.aiDraftDot,
    required this.aiDraftContainer,
    required this.signed,
    required this.signedDot,
    required this.signedContainer,
    required this.infoContainer,
    required this.infoDot,
    required this.infoText,
    required this.attentionContainer,
    required this.attentionDot,
    required this.attentionText,
    required this.lowConfidenceContainer,
    required this.lowConfidenceDot,
    required this.lowConfidenceText,
    required this.closedContainer,
    required this.closedDot,
    required this.closedText,
    required this.neutralContainer,
    required this.neutralDot,
    required this.neutralText,
    required this.brandContainer,
    required this.brandDot,
    required this.brandText,
    required this.errorContainer,
    required this.draftSurface,
    required this.draftBorder,
    required this.editedSurface,
    required this.editedBorder,
    required this.glassTint,
    required this.glassBorder,
    required this.ink,
    required this.primaryText,
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
  final Color aiDraftDot;
  final Color aiDraftContainer;
  final Color signed;
  final Color signedDot;
  final Color signedContainer;
  final Color infoContainer;
  final Color infoDot;
  final Color infoText;
  final Color attentionContainer;
  final Color attentionDot;
  final Color attentionText;
  final Color lowConfidenceContainer;
  final Color lowConfidenceDot;
  final Color lowConfidenceText;
  final Color closedContainer;
  final Color closedDot;
  final Color closedText;
  final Color neutralContainer;
  final Color neutralDot;
  final Color neutralText;
  final Color brandContainer;
  final Color brandDot;
  final Color brandText;
  final Color errorContainer;
  final Color draftSurface;
  final Color draftBorder;
  final Color editedSurface;
  final Color editedBorder;
  final Color glassTint;
  final Color glassBorder;
  final Color ink;
  final Color primaryText;
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
    Color? aiDraftDot,
    Color? aiDraftContainer,
    Color? signed,
    Color? signedDot,
    Color? signedContainer,
    Color? infoContainer,
    Color? infoDot,
    Color? infoText,
    Color? attentionContainer,
    Color? attentionDot,
    Color? attentionText,
    Color? lowConfidenceContainer,
    Color? lowConfidenceDot,
    Color? lowConfidenceText,
    Color? closedContainer,
    Color? closedDot,
    Color? closedText,
    Color? neutralContainer,
    Color? neutralDot,
    Color? neutralText,
    Color? brandContainer,
    Color? brandDot,
    Color? brandText,
    Color? errorContainer,
    Color? draftSurface,
    Color? draftBorder,
    Color? editedSurface,
    Color? editedBorder,
    Color? glassTint,
    Color? glassBorder,
    Color? ink,
    Color? primaryText,
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
      aiDraftDot: aiDraftDot ?? this.aiDraftDot,
      aiDraftContainer: aiDraftContainer ?? this.aiDraftContainer,
      signed: signed ?? this.signed,
      signedDot: signedDot ?? this.signedDot,
      signedContainer: signedContainer ?? this.signedContainer,
      infoContainer: infoContainer ?? this.infoContainer,
      infoDot: infoDot ?? this.infoDot,
      infoText: infoText ?? this.infoText,
      attentionContainer: attentionContainer ?? this.attentionContainer,
      attentionDot: attentionDot ?? this.attentionDot,
      attentionText: attentionText ?? this.attentionText,
      lowConfidenceContainer:
          lowConfidenceContainer ?? this.lowConfidenceContainer,
      lowConfidenceDot: lowConfidenceDot ?? this.lowConfidenceDot,
      lowConfidenceText: lowConfidenceText ?? this.lowConfidenceText,
      closedContainer: closedContainer ?? this.closedContainer,
      closedDot: closedDot ?? this.closedDot,
      closedText: closedText ?? this.closedText,
      neutralContainer: neutralContainer ?? this.neutralContainer,
      neutralDot: neutralDot ?? this.neutralDot,
      neutralText: neutralText ?? this.neutralText,
      brandContainer: brandContainer ?? this.brandContainer,
      brandDot: brandDot ?? this.brandDot,
      brandText: brandText ?? this.brandText,
      errorContainer: errorContainer ?? this.errorContainer,
      draftSurface: draftSurface ?? this.draftSurface,
      draftBorder: draftBorder ?? this.draftBorder,
      editedSurface: editedSurface ?? this.editedSurface,
      editedBorder: editedBorder ?? this.editedBorder,
      glassTint: glassTint ?? this.glassTint,
      glassBorder: glassBorder ?? this.glassBorder,
      ink: ink ?? this.ink,
      primaryText: primaryText ?? this.primaryText,
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
      aiDraftDot: Color.lerp(aiDraftDot, other.aiDraftDot, t) ?? aiDraftDot,
      aiDraftContainer:
          Color.lerp(aiDraftContainer, other.aiDraftContainer, t) ??
          aiDraftContainer,
      signed: Color.lerp(signed, other.signed, t) ?? signed,
      signedDot: Color.lerp(signedDot, other.signedDot, t) ?? signedDot,
      signedContainer:
          Color.lerp(signedContainer, other.signedContainer, t) ??
          signedContainer,
      infoContainer:
          Color.lerp(infoContainer, other.infoContainer, t) ?? infoContainer,
      infoDot: Color.lerp(infoDot, other.infoDot, t) ?? infoDot,
      infoText: Color.lerp(infoText, other.infoText, t) ?? infoText,
      attentionContainer:
          Color.lerp(attentionContainer, other.attentionContainer, t) ??
          attentionContainer,
      attentionDot:
          Color.lerp(attentionDot, other.attentionDot, t) ?? attentionDot,
      attentionText:
          Color.lerp(attentionText, other.attentionText, t) ?? attentionText,
      lowConfidenceContainer:
          Color.lerp(lowConfidenceContainer, other.lowConfidenceContainer, t) ??
          lowConfidenceContainer,
      lowConfidenceDot:
          Color.lerp(lowConfidenceDot, other.lowConfidenceDot, t) ??
          lowConfidenceDot,
      lowConfidenceText:
          Color.lerp(lowConfidenceText, other.lowConfidenceText, t) ??
          lowConfidenceText,
      closedContainer:
          Color.lerp(closedContainer, other.closedContainer, t) ??
          closedContainer,
      closedDot: Color.lerp(closedDot, other.closedDot, t) ?? closedDot,
      closedText: Color.lerp(closedText, other.closedText, t) ?? closedText,
      neutralContainer:
          Color.lerp(neutralContainer, other.neutralContainer, t) ??
          neutralContainer,
      neutralDot: Color.lerp(neutralDot, other.neutralDot, t) ?? neutralDot,
      neutralText: Color.lerp(neutralText, other.neutralText, t) ?? neutralText,
      brandContainer:
          Color.lerp(brandContainer, other.brandContainer, t) ?? brandContainer,
      brandDot: Color.lerp(brandDot, other.brandDot, t) ?? brandDot,
      brandText: Color.lerp(brandText, other.brandText, t) ?? brandText,
      errorContainer:
          Color.lerp(errorContainer, other.errorContainer, t) ?? errorContainer,
      draftSurface:
          Color.lerp(draftSurface, other.draftSurface, t) ?? draftSurface,
      draftBorder: Color.lerp(draftBorder, other.draftBorder, t) ?? draftBorder,
      editedSurface:
          Color.lerp(editedSurface, other.editedSurface, t) ?? editedSurface,
      editedBorder:
          Color.lerp(editedBorder, other.editedBorder, t) ?? editedBorder,
      glassTint: Color.lerp(glassTint, other.glassTint, t) ?? glassTint,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t) ?? glassBorder,
      ink: Color.lerp(ink, other.ink, t) ?? ink,
      primaryText: Color.lerp(primaryText, other.primaryText, t) ?? primaryText,
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
