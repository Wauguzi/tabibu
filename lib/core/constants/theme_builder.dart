import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/gen/fonts.gen.dart';

/// Material 3 theme for [brightness], seeded from that theme's primary and
/// then overridden role by role.
ThemeData buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
        brightness: brightness,
      ).copyWith(
        primary: isDark ? AppColors.primaryDark : AppColors.primaryLight,
        secondary: isDark ? AppColors.secondaryDark : AppColors.secondaryLight,
        error: isDark ? AppColors.errorDark : AppColors.errorLight,
      );

  return ThemeData(
    brightness: brightness,
    colorScheme: colorScheme,
    extensions: <ThemeExtension<dynamic>>[
      AppStatusColors(
        success: isDark ? AppColors.successDark : AppColors.successLight,
        warning: isDark ? AppColors.warningDark : AppColors.warningLight,
        aiDraft: isDark ? AppColors.aiDraftDark : AppColors.aiDraftLight,
        aiDraftContainer: isDark
            ? AppColors.aiDraftContainerDark
            : AppColors.aiDraftContainerLight,
        signed: isDark ? AppColors.signedDark : AppColors.signedLight,
        signedContainer: isDark
            ? AppColors.signedContainerDark
            : AppColors.signedContainerLight,
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
    textTheme: _textTheme(brightness),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
        TargetPlatform.values,
        value: (_) => const CupertinoPageTransitionsBuilder(),
      ),
    ),
  );
}

/// Material's default type scale with the two families applied: AR One Sans
/// for display, headline and titleLarge; Manrope for the rest (§2.2).
TextTheme _textTheme(Brightness brightness) {
  final base = brightness == Brightness.dark
      ? ThemeData.dark().textTheme
      : ThemeData.light().textTheme;
  return base.copyWith(
    displayLarge: base.displayLarge?.copyWith(fontFamily: FontFamily.aROneSans),
    displayMedium: base.displayMedium?.copyWith(
      fontFamily: FontFamily.aROneSans,
    ),
    displaySmall: base.displaySmall?.copyWith(fontFamily: FontFamily.aROneSans),
    headlineLarge: base.headlineLarge?.copyWith(
      fontFamily: FontFamily.aROneSans,
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      fontFamily: FontFamily.aROneSans,
    ),
    headlineSmall: base.headlineSmall?.copyWith(
      fontFamily: FontFamily.aROneSans,
    ),
    titleLarge: base.titleLarge?.copyWith(fontFamily: FontFamily.aROneSans),
    titleMedium: base.titleMedium?.copyWith(fontFamily: FontFamily.manrope),
    titleSmall: base.titleSmall?.copyWith(fontFamily: FontFamily.manrope),
    bodyLarge: base.bodyLarge?.copyWith(fontFamily: FontFamily.manrope),
    bodyMedium: base.bodyMedium?.copyWith(fontFamily: FontFamily.manrope),
    bodySmall: base.bodySmall?.copyWith(fontFamily: FontFamily.manrope),
    labelLarge: base.labelLarge?.copyWith(fontFamily: FontFamily.manrope),
    labelMedium: base.labelMedium?.copyWith(fontFamily: FontFamily.manrope),
    labelSmall: base.labelSmall?.copyWith(fontFamily: FontFamily.manrope),
  );
}
