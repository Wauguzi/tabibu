import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/icon_tile.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A setting with a switch: icon tile, title, supporting text and a toggle.
/// The whole row toggles; the switch mirrors the value.
class SettingToggleCard extends StatelessWidget {
  const SettingToggleCard({
    required this.icon,
    required this.tone,
    required this.title,
    required this.value,
    required this.onChanged,
    this.supporting,
    super.key,
  });

  final SvgGenImage icon;
  final IconTone tone;
  final String title;
  final String? supporting;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final supporting = this.supporting;

    final onChanged = this.onChanged;
    void toggle() => onChanged?.call(!value);
    return MergeSemantics(
      child: Semantics(
        toggled: value,
        enabled: onChanged != null,
        onTap: onChanged == null ? null : toggle,
        // The focus merges into the row's node.
        child: Focus(
          canRequestFocus: onChanged != null,
          child: Material(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.card),
            elevation: 2,
            shadowColor: AppShadows.cardColor,
            child: GestureDetector(
              onTap: onChanged == null ? null : toggle,
              behavior: .opaque,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 88),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      IconTile(icon: icon, tone: tone),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          mainAxisSize: .min,
                          children: [
                            Text(title, style: textTheme.titleMedium),
                            if (supporting != null)
                              Text(supporting, style: textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ExcludeSemantics(
                        child: Switch(value: value, onChanged: onChanged),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
