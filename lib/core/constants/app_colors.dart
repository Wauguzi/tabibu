import 'package:material_ui/material_ui.dart';

/// Semantic color roles from the design system (§2.1), light and dark.
///
/// Light values are provisional and under review. Dark values are lighter
/// tints that keep the text roles at WCAG AA against a dark surface.
abstract final class AppColors {
  // Primary.
  static const Color primaryLight = Color(0xFF0B6E69);
  static const Color primaryDark = Color(0xFF5BD9CB);
  static const Color secondaryLight = Color(0xFF2F5FB3);
  static const Color secondaryDark = Color(0xFFA8C7FA);

  // Unsigned AI output vs signed reports. The two frames must read as
  // different layouts at a glance, including in grayscale (§2.1, §4.1). The
  // draft is a pale working surface; the signed report is a deep green
  // panel, so the two are unmistakable even without hue. On-white green
  // text uses success, not signed.
  static const Color aiDraftLight = Color(0xFF8A5300);
  static const Color aiDraftDark = Color(0xFFD89B3C);
  static const Color aiDraftContainerLight = Color(0xFFFFF1D6);
  static const Color aiDraftContainerDark = Color(0xFF3A2C07);
  static const Color signedLight = Color(0xFFA9DFBC);
  static const Color signedDark = Color(0xFFB7E4C7);
  static const Color signedContainerLight = Color(0xFF14532D);
  static const Color signedContainerDark = Color(0xFF0B2E1F);

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

  // System feedback. Success and warning live in AppStatusColors; Material
  // has no slots for them.
  static const Color errorLight = Color(0xFFB3261E);
  static const Color errorDark = Color(0xFFFFB4AB);
  static const Color successLight = Color(0xFF1B6E45);
  static const Color successDark = Color(0xFF82D99B);
  static const Color warningLight = Color(0xFF8C6A00);
  static const Color warningDark = Color(0xFFEFC93C);

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
