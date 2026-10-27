import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoPageTransitionsBuilder;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/constants/theme_builder.dart';
import 'package:tabibu/gen/fonts.gen.dart';

void main() {
  group('buildTheme', () {
    test('builds a light and a dark theme from the semantic roles', () {
      final light = buildTheme(Brightness.light);
      final dark = buildTheme(Brightness.dark);

      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
      expect(light.colorScheme.primary, AppColors.primaryLight);
      expect(dark.colorScheme.primary, AppColors.primaryDark);
      expect(light.colorScheme.secondary, AppColors.secondaryLight);
      expect(dark.colorScheme.secondary, AppColors.secondaryDark);
      expect(light.colorScheme.error, AppColors.errorLight);
      expect(dark.colorScheme.error, AppColors.errorDark);
    });

    test('text-theme slots use the right family', () {
      for (final brightness in Brightness.values) {
        final textTheme = buildTheme(brightness).textTheme;
        for (final slot in [
          textTheme.displayLarge,
          textTheme.displayMedium,
          textTheme.displaySmall,
          textTheme.headlineLarge,
          textTheme.headlineMedium,
          textTheme.headlineSmall,
          textTheme.titleLarge,
        ]) {
          expect(slot?.fontFamily, FontFamily.aROneSans);
        }
        for (final slot in [
          textTheme.titleMedium,
          textTheme.titleSmall,
          textTheme.bodyLarge,
          textTheme.bodyMedium,
          textTheme.bodySmall,
          textTheme.labelLarge,
          textTheme.labelMedium,
          textTheme.labelSmall,
        ]) {
          expect(slot?.fontFamily, FontFamily.manrope);
        }
      }
    });

    test('AppStatusColors is present in both themes', () {
      expect(
        buildTheme(Brightness.light).extension<AppStatusColors>(),
        isNotNull,
      );
      expect(
        buildTheme(Brightness.dark).extension<AppStatusColors>(),
        isNotNull,
      );
    });

    test('uses Cupertino page transitions on every platform', () {
      for (final brightness in Brightness.values) {
        final builders = buildTheme(brightness).pageTransitionsTheme.builders;
        for (final platform in TargetPlatform.values) {
          expect(builders[platform], isA<CupertinoPageTransitionsBuilder>());
        }
      }
    });

    test('aiDraft and signed differ in luminance by at least 0.15', () {
      for (final brightness in Brightness.values) {
        final status = buildTheme(brightness).extension<AppStatusColors>()!;
        final difference =
            (status.aiDraft.computeLuminance() -
                    status.signed.computeLuminance())
                .abs();
        expect(difference, greaterThanOrEqualTo(0.15));
      }
    });
  });
}
