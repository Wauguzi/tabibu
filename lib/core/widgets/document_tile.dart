import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/icon_tile.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// An uploaded document: file icon, name, size-and-kind line and a delete
/// button.
class DocumentTile extends StatelessWidget {
  const DocumentTile({
    required this.fileName,
    required this.meta,
    required this.deleteLabel,
    required this.onDelete,
    super.key,
  });

  final String fileName;
  final String meta;
  final String deleteLabel;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isDark = scheme.brightness == .dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        // Raised in dark by a lighter tone, not a light shadow.
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Row(
        children: [
          IconTile(icon: Assets.icons.documentIcon, tone: IconTone.mint),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fileName,
                  style: textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(meta, style: textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Semantics(
            label: deleteLabel,
            button: true,
            enabled: onDelete != null,
            onTap: onDelete,
            excludeSemantics: true,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Material(
                color: scheme.surfaceContainerHigh,
                shape: const CircleBorder(),
                child: GestureDetector(
                  onTap: onDelete,
                  behavior: .opaque,
                  child: Center(
                    child: AssetIcon(
                      Assets.icons.deleteIcon,
                      size: 22,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
