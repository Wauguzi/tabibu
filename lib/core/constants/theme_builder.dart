import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/gen/fonts.gen.dart';

/// Material 3 theme for [brightness], seeded from that theme's primary and
/// then overridden role by role from the sheet.
ThemeData buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
        brightness: brightness,
      ).copyWith(
        primary: isDark ? AppColors.primaryDark : AppColors.primaryLight,
        onPrimary: isDark ? AppColors.inkLight : Colors.white,
        secondary: isDark ? AppColors.secondaryDark : AppColors.secondaryLight,
        onSecondary: isDark ? AppColors.inkLight : Colors.white,
        error: isDark ? AppColors.errorDark : AppColors.errorLight,
        onError: isDark ? AppColors.inkLight : Colors.white,
        surface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        onSurface: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
        surfaceContainerLowest: isDark
            ? AppColors.surfaceLowestDark
            : AppColors.surfaceLowestLight,
        surfaceContainerLow: isDark
            ? AppColors.surfaceLowDark
            : AppColors.surfaceLowLight,
        surfaceContainerHigh: isDark
            ? AppColors.surfaceHighDark
            : AppColors.surfaceHighLight,
        primaryContainer: isDark
            ? AppColors.brandContainerDark
            : AppColors.brandContainerLight,
        onPrimaryContainer: isDark
            ? AppColors.brandTextDark
            : AppColors.brandTextLight,
        outline: isDark ? AppColors.outlineDark : AppColors.outlineLight,
        outlineVariant: isDark
            ? AppColors.outlineVariantDark
            : AppColors.outlineVariantLight,
        onSurfaceVariant: isDark
            ? AppColors.onSurfaceVariantDark
            : AppColors.onSurfaceVariantLight,
      );

  return ThemeData(
    brightness: brightness,
    colorScheme: colorScheme,
    // Taps give no ripple or highlight anywhere.
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    extensions: <ThemeExtension<dynamic>>[
      AppStatusColors(
        success: isDark ? AppColors.successDark : AppColors.successLight,
        warning: isDark ? AppColors.warningDark : AppColors.warningLight,
        aiDraft: isDark ? AppColors.aiDraftDark : AppColors.aiDraftLight,
        aiDraftDot: isDark
            ? AppColors.aiDraftDotDark
            : AppColors.aiDraftDotLight,
        aiDraftContainer: isDark
            ? AppColors.aiDraftContainerDark
            : AppColors.aiDraftContainerLight,
        signed: isDark ? AppColors.signedDark : AppColors.signedLight,
        signedDot: isDark ? AppColors.signedDotDark : AppColors.signedDotLight,
        signedContainer: isDark
            ? AppColors.signedContainerDark
            : AppColors.signedContainerLight,
        infoContainer: isDark
            ? AppColors.infoContainerDark
            : AppColors.infoContainerLight,
        infoDot: isDark ? AppColors.infoDotDark : AppColors.infoDotLight,
        infoText: isDark ? AppColors.infoTextDark : AppColors.infoTextLight,
        attentionContainer: isDark
            ? AppColors.attentionContainerDark
            : AppColors.attentionContainerLight,
        attentionDot: isDark
            ? AppColors.attentionDotDark
            : AppColors.attentionDotLight,
        attentionText: isDark
            ? AppColors.attentionTextDark
            : AppColors.attentionTextLight,
        lowConfidenceContainer: isDark
            ? AppColors.lowConfidenceContainerDark
            : AppColors.lowConfidenceContainerLight,
        lowConfidenceDot: isDark
            ? AppColors.lowConfidenceDotDark
            : AppColors.lowConfidenceDotLight,
        lowConfidenceText: isDark
            ? AppColors.lowConfidenceTextDark
            : AppColors.lowConfidenceTextLight,
        closedContainer: isDark
            ? AppColors.closedContainerDark
            : AppColors.closedContainerLight,
        closedDot: isDark ? AppColors.closedDotDark : AppColors.closedDotLight,
        closedText: isDark
            ? AppColors.closedTextDark
            : AppColors.closedTextLight,
        neutralContainer: isDark
            ? AppColors.neutralContainerDark
            : AppColors.neutralContainerLight,
        neutralDot: isDark
            ? AppColors.neutralDotDark
            : AppColors.neutralDotLight,
        neutralText: isDark
            ? AppColors.neutralTextDark
            : AppColors.neutralTextLight,
        brandContainer: isDark
            ? AppColors.brandContainerDark
            : AppColors.brandContainerLight,
        brandDot: isDark ? AppColors.brandDotDark : AppColors.brandDotLight,
        brandText: isDark ? AppColors.brandTextDark : AppColors.brandTextLight,
        errorContainer: isDark
            ? AppColors.errorContainerDark
            : AppColors.errorContainerLight,
        draftSurface: isDark
            ? AppColors.draftSurfaceDark
            : AppColors.draftSurfaceLight,
        draftBorder: isDark
            ? AppColors.draftBorderDark
            : AppColors.draftBorderLight,
        glassTint: isDark ? AppColors.glassTintDark : AppColors.glassTintLight,
        glassBorder: isDark
            ? AppColors.glassBorderDark
            : AppColors.glassBorderLight,
        editedSurface: isDark
            ? AppColors.editedSurfaceDark
            : AppColors.editedSurfaceLight,
        editedBorder: isDark
            ? AppColors.editedBorderDark
            : AppColors.editedBorderLight,
        ink: isDark ? AppColors.inkDark : AppColors.inkLight,
        primaryText: isDark
            ? AppColors.primaryTextDark
            : AppColors.primaryTextLight,
        urgencyUrgent: isDark
            ? AppColors.urgencyUrgentDark
            : AppColors.urgencyUrgentLight,
        urgencyPriority: isDark
            ? AppColors.urgencyPriorityDark
            : AppColors.urgencyPriorityLight,
        urgencyRoutine: isDark
            ? AppColors.urgencyRoutineDark
            : AppColors.urgencyRoutineLight,
        confidenceLow: isDark
            ? AppColors.confidenceLowDark
            : AppColors.confidenceLowLight,
        alertNotice: isDark
            ? AppColors.alertNoticeDark
            : AppColors.alertNoticeLight,
        overlayMaskParasitized: isDark
            ? AppColors.overlayMaskParasitizedDark
            : AppColors.overlayMaskParasitizedLight,
        overlayMaskUninfected: isDark
            ? AppColors.overlayMaskUninfectedDark
            : AppColors.overlayMaskUninfectedLight,
      ),
    ],
    textTheme: _textTheme(colorScheme),
    switchTheme: _switchTheme(colorScheme),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
        TargetPlatform.values,
        value: (_) => const CupertinoPageTransitionsBuilder(),
      ),
    ),
  );
}

/// Manrope throughout; the mapped slots carry the sheet's measured sizes.
TextTheme _textTheme(ColorScheme scheme) {
  TextStyle base(
    double size,
    FontWeight weight, {
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: FontFamily.manrope,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  final onSurface = scheme.onSurface;
  final onVariant = scheme.onSurfaceVariant;
  return TextTheme(
    displayLarge: base(57, FontWeight.w400, color: onSurface),
    displayMedium: base(45, FontWeight.w400, color: onSurface),
    displaySmall: base(
      34,
      FontWeight.w700,
      height: 1.1,
      letterSpacing: -0.5,
      color: onSurface,
    ),
    headlineLarge: base(32, FontWeight.w400, color: onSurface),
    headlineMedium: base(28, FontWeight.w700, color: onSurface),
    headlineSmall: base(24, FontWeight.w400, color: onSurface),
    titleLarge: base(22, FontWeight.w600, color: onSurface),
    titleMedium: base(16, FontWeight.w600, color: onSurface),
    titleSmall: base(14, FontWeight.w600, color: onSurface),
    labelLarge: base(16, FontWeight.w600, color: onSurface),
    labelMedium: base(14, FontWeight.w500, color: onSurface),
    labelSmall: base(12, FontWeight.w500, color: onSurface),
    bodyLarge: base(16, FontWeight.w400, color: onSurface),
    bodyMedium: base(14, FontWeight.w400, color: onVariant),
    bodySmall: base(13, FontWeight.w400, color: onVariant),
  );
}

SwitchThemeData _switchTheme(ColorScheme scheme) {
  final selectedThumb = scheme.brightness == Brightness.dark
      ? AppColors.inkLight
      : Colors.white;
  return SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? selectedThumb
          : scheme.outline,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? scheme.primary
          : scheme.surfaceContainerHigh,
    ),
    trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
  );
}
