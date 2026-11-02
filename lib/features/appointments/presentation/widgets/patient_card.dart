import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// One contact / records action on a [PatientCard].
class PatientCardAction {
  const PatientCardAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final SvgGenImage icon;
  final String label;
  final VoidCallback onTap;
}

/// Patient identity on an appointment or case: avatar, name, details, optional
/// chip and a scrolling row of action pills (N-4).
class PatientCard extends StatelessWidget {
  const PatientCard({
    required this.name,
    required this.details,
    this.image,
    this.chip,
    this.actions = const [],
    super.key,
  });

  final String name;
  final String details;
  final ImageProvider? image;
  final Widget? chip;
  final List<PatientCardAction> actions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final chip = this.chip;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Padding(
        padding: AppStyles.cardPadding,
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Row(
              crossAxisAlignment: .start,
              children: [
                Avatar(name: name, image: image, radius: 36),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(name, style: textTheme.titleLarge),
                      Text(
                        details,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      if (chip != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        chip,
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: .horizontal,
                  itemCount: actions.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    final action = actions[index];
                    return _ActionPill(action: action);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.action});

  final PatientCardAction action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: action.label,
      onTap: action.onTap,
      excludeSemantics: true,
      child: Tappable(
        onTap: action.onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: .min,
              children: [
                AssetIcon(
                  action.icon,
                  size: 20,
                  color: scheme.onSurface,
                  scaleUp: false,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  action.label,
                  style: textTheme.labelLarge?.copyWith(
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
