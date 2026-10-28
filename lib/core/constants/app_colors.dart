import 'package:material_ui/material_ui.dart';

/// Semantic color roles from the design system (§2), light and dark.
///
/// Light values are the sheet's tokens. Dark values are lighter tints that
/// keep the text roles at WCAG AA against a dark surface; containers are
/// dark tints that sit slightly above it.
abstract final class AppColors {
  // Brand and actions. Ink drives actions; teal is the brand.
  static const Color inkLight = Color(0xFF0F1A1C);
  static const Color inkDark = Color(0xFFE8EDED);
  static const Color primaryLight = Color(0xFF1F6F78);
  static const Color primaryDark = Color(0xFF5BD9CB);
  static const Color secondaryLight = Color(0xFF1A626A);
  static const Color secondaryDark = Color(0xFF8FD6CE);
  static const Color primaryTextLight = Color(0xFF1A626A);
  static const Color primaryTextDark = Color(0xFF8FD6CE);

  // Washes and tile pastels.
  static const Color skyLight = Color(0xFFD7E8F5);
  static const Color skyDark = Color(0xFF1A2636);
  static const Color lavenderLight = Color(0xFFE7E1FB);
  static const Color lavenderDark = Color(0xFF262046);
  static const Color mintLight = Color(0xFFE4F1EF);
  static const Color mintDark = Color(0xFF12302A);
  static const Color butterLight = Color(0xFFFFF1C2);
  static const Color butterDark = Color(0xFF38300C);
  static const Color peachLight = Color(0xFFFFE6D6);
  static const Color peachDark = Color(0xFF3A2317);

  // Surfaces and text.
  static const Color surfaceLight = Color(0xFFF5FAFA);
  static const Color surfaceDark = Color(0xFF101415);
  static const Color surfaceLowestLight = Color(0xFFFFFFFF);
  static const Color surfaceLowestDark = Color(0xFF0B0F10);
  static const Color surfaceLowLight = Color(0xFFEFF5F5);
  static const Color surfaceLowDark = Color(0xFF161C1D);
  static const Color surfaceHighLight = Color(0xFFE3E9EA);
  static const Color surfaceHighDark = Color(0xFF232A2B);
  static const Color outlineLight = Color(0xFF5F696B);
  static const Color outlineDark = Color(0xFF8B9496);
  static const Color outlineVariantLight = Color(0xFFDFE5E5);
  static const Color outlineVariantDark = Color(0xFF2C3334);
  static const Color onSurfaceLight = Color(0xFF171D1E);
  static const Color onSurfaceDark = Color(0xFFE7EDED);
  static const Color onSurfaceVariantLight = Color(0xFF3F484A);
  static const Color onSurfaceVariantDark = Color(0xFFB9C4C6);

  // Status triples: container, dot, text.
  static const Color infoContainerLight = Color(0xFFDDE7F8);
  static const Color infoContainerDark = Color(0xFF1A2740);
  static const Color infoDotLight = Color(0xFF2F5FA7);
  static const Color infoDotDark = Color(0xFF8FB0F0);
  static const Color infoTextLight = Color(0xFF0E2C5C);
  static const Color infoTextDark = Color(0xFFA9C6F5);
  static const Color signedContainerLight = Color(0xFFD3EEE2);
  static const Color signedContainerDark = Color(0xFF0B2E1F);
  static const Color signedDotLight = Color(0xFF1E6B52);
  static const Color signedDotDark = Color(0xFF7FD6A0);
  static const Color signedLight = Color(0xFF06301F);
  static const Color signedDark = Color(0xFFB7E4C7);
  static const Color attentionContainerLight = Color(0xFFFFE6C4);
  static const Color attentionContainerDark = Color(0xFF3A2C07);
  static const Color attentionDotLight = Color(0xFF8A5300);
  static const Color attentionDotDark = Color(0xFFE8A83D);
  static const Color attentionTextLight = Color(0xFF3D2400);
  static const Color attentionTextDark = Color(0xFFF5C66B);
  static const Color lowConfidenceContainerLight = Color(0xFFECE3FB);
  static const Color lowConfidenceContainerDark = Color(0xFF2A2342);
  static const Color lowConfidenceDotLight = Color(0xFF6A4FA3);
  static const Color lowConfidenceDotDark = Color(0xFFB3A1EC);
  static const Color lowConfidenceTextLight = Color(0xFF2A1458);
  static const Color lowConfidenceTextDark = Color(0xFFCFC2F5);
  static const Color closedContainerLight = Color(0xFFE4E8E9);
  static const Color closedContainerDark = Color(0xFF2A2E2F);
  static const Color closedDotLight = Color(0xFF5C6466);
  static const Color closedDotDark = Color(0xFF9AA3A5);
  static const Color closedTextLight = Color(0xFF2B3133);
  static const Color closedTextDark = Color(0xFFC9CFD0);
  static const Color neutralContainerLight = Color(0xFFE3E9EA);
  static const Color neutralContainerDark = Color(0xFF222728);
  static const Color neutralDotLight = Color(0xFF5F696B);
  static const Color neutralDotDark = Color(0xFF8A9395);
  static const Color neutralTextLight = Color(0xFF3F484A);
  static const Color neutralTextDark = Color(0xFFAEB8BA);
  static const Color aiDraftContainerLight = Color(0xFFF4F0FB);
  static const Color aiDraftContainerDark = Color(0xFF2C2545);
  static const Color aiDraftDotLight = Color(0xFF5B4A86);
  static const Color aiDraftDotDark = Color(0xFFCFC0F0);
  static const Color aiDraftLight = Color(0xFF5B4A86);
  static const Color aiDraftDark = Color(0xFFCFC0F0);
  static const Color brandContainerLight = Color(0xFFBDEBEF);
  static const Color brandContainerDark = Color(0xFF0F3A40);
  static const Color brandDotLight = Color(0xFF1A626A);
  static const Color brandDotDark = Color(0xFF6FC3CC);
  static const Color brandTextLight = Color(0xFF00363C);
  static const Color brandTextDark = Color(0xFFA9E6ED);

  // AI vs human editing surfaces.
  static const Color draftSurfaceLight = Color(0xFFF4F0FB);
  static const Color draftSurfaceDark = Color(0xFF2C2545);
  static const Color draftBorderLight = Color(0xFFD4C8EE);
  static const Color draftBorderDark = Color(0xFF8E7FC4);
  static const Color editedSurfaceLight = Color(0xFFE2F4F5);
  static const Color editedSurfaceDark = Color(0xFF123B40);
  static const Color editedBorderLight = Color(0xFF8FCBD1);
  static const Color editedBorderDark = Color(0xFF5EA3AA);

  // Frosted-glass tints. Opaque enough that ink (light) and white (dark)
  // text stay AA over a blurred page.
  static const Color glassTintLight = Color(0xB8FFFFFF);
  static const Color glassTintDark = Color(0x99000000);
  static const Color glassBorderLight = Color(0xA6FFFFFF);
  static const Color glassBorderDark = Color(0x1AFFFFFF);

  // Teal gradient stops beyond primary.
  static const Color tealHeroEndLight = Color(0xFF3E9AA4);
  static const Color tealHeroStartDark = Color(0xFF1E4E55);
  static const Color tealHeroEndDark = Color(0xFF2A6B73);
  static const Color tealDeepStartLight = Color(0xFF154F56);
  static const Color tealDeepStartDark = Color(0xFF0C2B30);
  static const Color tealDeepEndDark = Color(0xFF123B40);

  // System feedback. Success and warning follow the signed and attention
  // dots; Material has no slots for them, so they live in AppStatusColors.
  static const Color errorLight = Color(0xFFB3261E);
  static const Color errorDark = Color(0xFFFFB4AB);
  static const Color errorContainerLight = Color(0xFFF9DEDC);
  static const Color errorContainerDark = Color(0xFF5D2320);
  static const Color successLight = Color(0xFF1E6B52);
  static const Color successDark = Color(0xFF82D99B);
  static const Color warningLight = Color(0xFF8A5300);
  static const Color warningDark = Color(0xFFEFC93C);

  // Info notification background. White text stays AA on both (12.81 light,
  // 9.64 dark); the dark slate lifts 1.92 off the dark page.
  static const Color notificationInfoLight = Color(0xFF2A3434);
  static const Color notificationInfoDark = Color(0xFF3B4747);

  // Worklist urgency. Always paired with a text label and an icon.
  static const Color urgencyUrgentLight = Color(0xFFB3261E);
  static const Color urgencyUrgentDark = Color(0xFFFFB4AB);
  static const Color urgencyPriorityLight = Color(0xFFB85C00);
  static const Color urgencyPriorityDark = Color(0xFFFFB787);
  static const Color urgencyRoutineLight = Color(0xFF3F6E9E);
  static const Color urgencyRoutineDark = Color(0xFFA3C9F1);

  // Confidence and outbreak notices. Low confidence is never error red.
  static const Color confidenceLowLight = Color(0xFF6B4FD8);
  static const Color confidenceLowDark = Color(0xFFCDBDFF);
  static const Color alertNoticeLight = Color(0xFF2E6A8E);
  static const Color alertNoticeDark = Color(0xFF8FC3E8);

  // Viewer overlays. Outline styles differ too (solid vs dashed), so the
  // masks do not rely on color alone.
  static const Color overlayMaskParasitizedLight = Color(0xFFE69F00);
  static const Color overlayMaskParasitizedDark = Color(0xFFF2BE45);
  static const Color overlayMaskUninfectedLight = Color(0xFF56B4E9);
  static const Color overlayMaskUninfectedDark = Color(0xFF7ED0F7);

  /// Tumor-probability ramp (viridis stops). Identical in both themes: it is
  /// drawn over diagnostic images, not theme surfaces.
  static const List<Color> overlayHeatmap = <Color>[
    Color(0xFF440154),
    Color(0xFF3B528B),
    Color(0xFF21918C),
    Color(0xFF5EC962),
    Color(0xFFFDE725),
  ];
}
