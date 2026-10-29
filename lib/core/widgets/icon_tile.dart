import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// Icon tile tones. Each resolves to a pastel container with a deep icon,
/// matched to the card family it labels. White suits tinted cards; glass
/// suits teal and ink surfaces. Neutral labels settings rows; danger labels
/// sign-out and deletion.
enum IconTone {
  sky,
  mint,
  lavender,
  butter,
  peach,
  white,
  glass,
  neutral,
  danger,
}

/// Icon tile sizes: S for dense rows, M by default, L for onboarding and
/// big options.
enum IconTileSize { s, m, l }

/// A rounded-square icon tile that labels content: list rows, cards,
/// options, files, notices. Never tappable on its own.
class IconTile extends StatelessWidget {
  const IconTile({
    required this.icon,
    required this.tone,
    this.size = IconTileSize.m,
    super.key,
  });

  final SvgGenImage icon;
  final IconTone tone;
  final IconTileSize size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final isDark = scheme.brightness == .dark;

    final (box, radius, glyph) = switch (size) {
      .s => (36.0, 12.0, 18.0),
      .m => (44.0, 14.0, 22.0),
      .l => (56.0, 18.0, 28.0),
    };
    final (background, foreground) = switch ((tone, isDark)) {
      (.sky, false) => (AppColors.skyLight, status.infoDot),
      (.sky, true) => (AppColors.skyDark, status.infoDot),
      (.mint, false) => (AppColors.mintLight, status.signedDot),
      (.mint, true) => (AppColors.mintDark, status.signedDot),
      (.lavender, false) => (AppColors.lavenderLight, status.aiDraftDot),
      (.lavender, true) => (AppColors.lavenderDark, status.aiDraftDot),
      (.butter, false) => (AppColors.butterLight, status.attentionDot),
      (.butter, true) => (AppColors.butterDark, status.warning),
      (.peach, false) => (AppColors.peachLight, status.attentionText),
      (.peach, true) => (AppColors.peachDark, status.attentionText),
      (.white, false) => (scheme.surfaceContainerLowest, status.primaryText),
      (.white, true) => (scheme.surfaceContainerHigh, status.primaryText),
      (.glass, _) => (Colors.white.withValues(alpha: 0.16), Colors.white),
      (.neutral, _) => (scheme.surfaceContainerLow, scheme.onSurface),
      (.danger, _) => (status.errorContainer, scheme.error),
    };

    return Container(
      width: box,
      height: box,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: AssetIcon(icon, size: glyph, color: foreground),
    );
  }
}
