import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';

/// The home headline in two tones: the fact in ink, the hook in teal, or
/// ink too where the role keeps one colour.
class TwoToneHeadline extends StatelessWidget {
  const TwoToneHeadline({
    required this.first,
    this.second,
    this.tealSecond = true,
    super.key,
  });

  final String first;
  final String? second;
  final bool tealSecond;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final style = Theme.of(context).textTheme.headlineLarge;
    final second = this.second;
    return Semantics(
      header: true,
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(first, style: style?.copyWith(color: scheme.onSurface)),
          if (second != null)
            Text(
              second,
              style: style?.copyWith(
                color: tealSecond ? scheme.primary : status.ink,
              ),
            ),
        ],
      ),
    );
  }
}
