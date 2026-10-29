import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A titled group of profile settings on one card, rows split by hairlines.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({required this.title, required this.children, super.key});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.card),
            boxShadow: AppShadows.card(),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
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

/// A row that opens a setting: icon tile, title, the current value under
/// it, and a chevron. A [destructive] row (sign out, delete) is red.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.icon,
    required this.title,
    this.supporting,
    this.onTap,
    this.destructive = false,
    super.key,
  });

  final SvgGenImage icon;
  final String title;
  final String? supporting;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      enabled: onTap != null,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        behavior: .opaque,
        child: _RowLayout(
          icon: icon,
          tone: destructive ? .danger : .neutral,
          title: title,
          titleColor: destructive ? scheme.error : null,
          supporting: supporting,
          trailing: AssetIcon(
            Assets.icons.forwardIcon,
            size: 18,
            scaleUp: false,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// A row with a switch. The whole row toggles; the switch mirrors the value.
class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final SvgGenImage icon;
  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    void toggle() => onChanged?.call(!value);
    return MergeSemantics(
      child: Semantics(
        toggled: value,
        enabled: onChanged != null,
        onTap: onChanged == null ? null : toggle,
        child: GestureDetector(
          onTap: onChanged == null ? null : toggle,
          behavior: .opaque,
          child: _RowLayout(
            icon: icon,
            tone: .neutral,
            title: title,
            trailing: ExcludeSemantics(
              // The row is the target, so the switch keeps its drawn size.
              child: Switch(
                value: value,
                onChanged: onChanged,
                materialTapTargetSize: .shrinkWrap,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RowLayout extends StatelessWidget {
  const _RowLayout({
    required this.icon,
    required this.tone,
    required this.title,
    required this.trailing,
    this.titleColor,
    this.supporting,
  });

  final SvgGenImage icon;
  final IconTone tone;
  final String title;
  final Color? titleColor;
  final String? supporting;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final supporting = this.supporting;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 72),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            IconTile(icon: icon, tone: tone),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                mainAxisSize: .min,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: .w500,
                      color: titleColor,
                    ),
                  ),
                  if (supporting != null)
                    Text(supporting, style: textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            trailing,
          ],
        ),
      ),
    );
  }
}
