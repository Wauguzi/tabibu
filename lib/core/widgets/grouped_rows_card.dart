import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/icon_tile.dart';
import 'package:tabibu/core/widgets/tappable.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// One white card holding several rows split by hairline dividers, with an
/// optional section title above it.
class GroupedRowsCard extends StatelessWidget {
  const GroupedRowsCard({required this.children, this.title, super.key});

  final List<Widget> children;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final title = this.title;
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        if (title != null) ...[
          Semantics(
            header: true,
            child: Text(
              title,
              style: textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: isDark
                ? scheme.surfaceContainerHigh
                : scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.card),
            boxShadow: AppShadows.card(),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    color: scheme.outlineVariant,
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// One row of a [GroupedRowsCard]: a toned icon tile and a title, padded
/// like any card. A tap makes it a button with a chevron.
class GroupedRow extends StatelessWidget {
  const GroupedRow({
    required this.icon,
    required this.tone,
    required this.title,
    this.onTap,
    super.key,
  });

  final SvgGenImage icon;
  final IconTone tone;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onTap = this.onTap;
    final row = Padding(
      padding: AppStyles.cardPadding,
      child: Row(
        children: [
          IconTile(icon: icon, tone: tone),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleSmall),
          ),
          if (onTap != null) ...[
            const SizedBox(width: AppSpacing.sm),
            AssetIcon(
              Assets.icons.forwardIcon,
              size: 22,
              scaleUp: false,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return row;
    return MergeSemantics(
      child: Semantics(
        button: true,
        label: title,
        onTap: onTap,
        child: Tappable(
          onTap: onTap,
          child: ExcludeSemantics(child: row),
        ),
      ),
    );
  }
}
