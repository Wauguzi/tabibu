import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/icon_tile.dart';
import 'package:tabibu/core/widgets/tappable.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A centred no-results state for inside the caller's scroll view: visual,
/// title, body, action wrap and tips.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    this.icon,
    this.tone = IconTone.sky,
    this.illustration,
    this.body,
    this.actions = const [],
    this.tips,
    super.key,
  });

  final String title;
  final SvgGenImage? icon;
  final IconTone tone;
  final Widget? illustration;
  final String? body;
  final List<Widget> actions;
  final Widget? tips;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final icon = this.icon;
    final illustration = this.illustration;
    final body = this.body;
    final tips = this.tips;
    final visual =
        illustration ??
        (icon == null ? null : IconTile(icon: icon, tone: tone, size: .l));
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        if (visual != null) ...[
          ExcludeSemantics(child: Center(child: visual)),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text(title, style: textTheme.titleLarge, textAlign: .center),
        if (body != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(body, style: textTheme.bodyMedium, textAlign: .center),
        ],
        if (actions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            alignment: .center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: actions,
          ),
        ],
        if (tips != null) ...[const SizedBox(height: AppSpacing.md), tips],
      ],
    );
  }
}

/// An outlined suggestion pill with its arrow: a fuzzy match to run.
class SuggestionPill extends StatelessWidget {
  const SuggestionPill({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onTap = this.onTap;
    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: true,
        onTap: onTap,
        child: Tappable(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outline),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Row(
              mainAxisSize: .min,
              children: [
                Flexible(child: Text(label, style: textTheme.labelLarge)),
                const SizedBox(width: AppSpacing.sm),
                ExcludeSemantics(
                  child: AssetIcon(
                    Assets.icons.forwardIcon,
                    size: 18,
                    color: scheme.onSurface,
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

/// A muted box of ticked tips under an empty state.
class TipsCard extends StatelessWidget {
  const TipsCard({required this.title, required this.tips, super.key});

  final String title;
  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: AppStyles.cardPadding,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.notice),
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(title, style: textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < tips.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: .start,
              children: [
                ExcludeSemantics(
                  child: AssetIcon(
                    Assets.icons.tickIcon,
                    size: 12,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Text(tips[i], style: textTheme.bodyMedium)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
