import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/icon_tile.dart';
import 'package:tabibu/core/widgets/tabibu_bottom_sheet.dart';
import 'package:tabibu/core/widgets/tappable.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// One row of an options sheet or menu: the value it pops with, its icon
/// and label, an optional supporting line, and the destructive flag.
class OptionsAction<T> {
  const OptionsAction({
    required this.value,
    required this.icon,
    required this.label,
    this.supporting,
    this.destructive = false,
  });

  final T value;
  final SvgGenImage icon;
  final String label;
  final String? supporting;
  final bool destructive;
}

/// An options sheet over [TabibuBottomSheet]: filled rows that pop with the
/// tapped action's value. A destructive row's icon and label run red.
Future<T?> showOptionsSheet<T>(
  BuildContext context, {
  required String title,
  required List<OptionsAction<T>> actions,
  String? subtitle,
}) {
  return TabibuBottomSheet.show<T>(
    context,
    title: title,
    subtitle: subtitle,
    builder: (sheetContext) {
      final rows = <Widget>[];
      for (final action in actions) {
        if (rows.isNotEmpty) {
          rows.add(const SizedBox(height: AppSpacing.sm));
        }
        rows.add(
          _OptionsRow(
            action: action,
            onTap: () => Navigator.of(sheetContext).pop(action.value),
          ),
        );
      }
      return Column(mainAxisSize: .min, children: rows);
    },
  );
}

class _OptionsRow<T> extends StatelessWidget {
  const _OptionsRow({required this.action, required this.onTap});

  final OptionsAction<T> action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final destructive = action.destructive;
    final supporting = action.supporting;
    final onTap = this.onTap;
    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: true,
        onTap: onTap,
        child: Tappable(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadii.field),
            ),
            child: Row(
              children: [
                IconTile(
                  icon: action.icon,
                  tone: destructive ? .danger : .lavender,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    mainAxisSize: .min,
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        action.label,
                        style: textTheme.titleMedium?.copyWith(
                          color: destructive ? scheme.error : scheme.onSurface,
                        ),
                      ),
                      if (supporting != null)
                        Text(supporting, style: textTheme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ExcludeSemantics(
                  child: AssetIcon(
                    Assets.icons.forwardIcon,
                    size: 22,
                    scaleUp: false,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
