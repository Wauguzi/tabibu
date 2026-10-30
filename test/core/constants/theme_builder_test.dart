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

    test('text-theme slots use Manrope throughout', () {
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

    test('mapped slots carry the measured sizes', () {
      final textTheme = buildTheme(Brightness.light).textTheme;
      expect(textTheme.displaySmall?.fontSize, 34);
      expect(textTheme.headlineMedium?.fontSize, 28);
      expect(textTheme.titleLarge?.fontSize, 22);
      expect(textTheme.titleMedium?.fontSize, 16);
      expect(textTheme.labelLarge?.fontSize, 16);
      expect(textTheme.bodyLarge?.fontSize, 16);
      expect(textTheme.bodyMedium?.fontSize, 14);
      expect(textTheme.bodySmall?.fontSize, 13);
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
  });
}
