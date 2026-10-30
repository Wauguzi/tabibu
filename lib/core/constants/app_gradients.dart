import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';

/// The sheet's seven gradients, plus dark counterparts. Washes run top to
/// bottom; the teal pair runs left to right.
abstract final class AppGradients {
  static const LinearGradient skyToLavender = LinearGradient(
    begin: .topCenter,
    end: .bottomCenter,
    colors: [AppColors.skyLight, AppColors.lavenderLight],
  );
  static const LinearGradient skyToLavenderDark = LinearGradient(
    begin: .topCenter,
    end: .bottomCenter,
    colors: [AppColors.skyDark, AppColors.lavenderDark],
  );

  static const LinearGradient mintToSky = LinearGradient(
    begin: .topCenter,
    end: .bottomCenter,
    colors: [AppColors.mintLight, AppColors.skyLight],
  );
  static const LinearGradient mintToSkyDark = LinearGradient(
    begin: .topCenter,
    end: .bottomCenter,
    colors: [AppColors.mintDark, AppColors.skyDark],
  );

  static const LinearGradient lavenderToMint = LinearGradient(
    begin: .topCenter,
    end: .bottomCenter,
    colors: [AppColors.lavenderLight, AppColors.mintLight],
  );
  static const LinearGradient lavenderToMintDark = LinearGradient(
    begin: .topCenter,
    end: .bottomCenter,
    colors: [AppColors.lavenderDark, AppColors.mintDark],
  );

  static const LinearGradient butterWash = LinearGradient(
    begin: .topCenter,
    end: .bottomCenter,
    colors: [AppColors.butterLight, AppColors.surfaceLight],
  );
  static const LinearGradient butterWashDark = LinearGradient(
    begin: .topCenter,
    end: .bottomCenter,
    colors: [AppColors.butterDark, AppColors.surfaceDark],
  );

  static const LinearGradient tealHero = LinearGradient(
    colors: [AppColors.primaryLight, AppColors.tealHeroEndLight],
  );
  static const LinearGradient tealHeroDark = LinearGradient(
    colors: [AppColors.tealHeroStartDark, AppColors.tealHeroEndDark],
  );

  static const LinearGradient tealDeep = LinearGradient(
    colors: [AppColors.tealDeepStartLight, AppColors.primaryLight],
  );
  static const LinearGradient tealDeepDark = LinearGradient(
    colors: [AppColors.tealDeepStartDark, AppColors.tealDeepEndDark],
  );

  static const LinearGradient infoWash = LinearGradient(
    begin: .topCenter,
    end: .bottomCenter,
    colors: [AppColors.infoContainerLight, AppColors.surfaceLight],
  );
  static const LinearGradient infoWashDark = LinearGradient(
    begin: .topCenter,
    end: .bottomCenter,
    colors: [AppColors.infoContainerDark, AppColors.surfaceDark],
  );

  static const LinearGradient skyWash = LinearGradient(
    begin: .topCenter,
    end: .bottomCenter,
    colors: [AppColors.skyLight, AppColors.surfaceLight],
  );
  static const LinearGradient skyWashDark = LinearGradient(
    begin: .topCenter,
    end: .bottomCenter,
    colors: [AppColors.skyDark, AppColors.surfaceDark],
  );

  static const LinearGradient mintWash = LinearGradient(
    begin: .topCenter,
    end: .bottomCenter,
    colors: [AppColors.mintLight, AppColors.surfaceLight],
  );
  static const LinearGradient mintWashDark = LinearGradient(
    begin: .topCenter,
    end: .bottomCenter,
    colors: [AppColors.mintDark, AppColors.surfaceDark],
  );

  static const LinearGradient lavenderWash = LinearGradient(
    begin: .topCenter,
    end: .bottomCenter,
    colors: [AppColors.lavenderLight, AppColors.surfaceLight],
  );
  static const LinearGradient lavenderWashDark = LinearGradient(
    begin: .topCenter,
    end: .bottomCenter,
    colors: [AppColors.lavenderDark, AppColors.surfaceDark],
  );
}
