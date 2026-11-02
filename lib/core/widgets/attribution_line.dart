import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A shield with its muted provenance note, under content that came from
/// someone: who shared it and who reviewed it.
class AttributionLine extends StatelessWidget {
  const AttributionLine({required this.text, this.icon, super.key});

  final String text;
  final SvgGenImage? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: .start,
      children: [
        AssetIcon(
          icon ?? Assets.icons.shieldIcon,
          size: 18,
          color: scheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(child: Text(text, style: textTheme.bodySmall)),
      ],
    );
  }
}
