import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A decorative text-field icon, hidden from screen readers: the label
/// carries the meaning, and a merged image node trips the merge assert.
class FieldIcon extends StatelessWidget {
  const FieldIcon(this.icon, {super.key});

  final SvgGenImage icon;

  @override
  Widget build(BuildContext context) =>
      ExcludeSemantics(child: AssetIcon(icon, size: 22, scaleUp: false));
}
