import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A horizontal case stage track: done (teal tick), current (ink, or
/// attention when [paused]), later (outline). One semantics summary for the
/// whole stepper.
class CaseStepper extends StatelessWidget {
  const CaseStepper({
    required this.labels,
    required this.current,
    required this.semanticLabel,
    this.paused = false,
    super.key,
  });

  final List<String> labels;
  final int current;
  final String semanticLabel;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final onInk = isDark ? AppColors.inkLight : Colors.white;
    final count = labels.length;

    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: .start,
          children: [
            for (var i = 0; i < count; i++)
              Expanded(
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    SizedBox(
                      height: 32,
                      child: Stack(
                        alignment: .center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: i == 0
                                    ? const SizedBox.shrink()
                                    : ColoredBox(
                                        color: i <= current
                                            ? status.signedDot
                                            : scheme.outlineVariant,
                                        child: const SizedBox(height: 2),
                                      ),
                              ),
                              const SizedBox(width: 32),
                              Expanded(
                                child: i == count - 1
                                    ? const SizedBox.shrink()
                                    : ColoredBox(
                                        color: i < current
                                            ? status.signedDot
                                            : scheme.outlineVariant,
                                        child: const SizedBox(height: 2),
                                      ),
                              ),
                            ],
                          ),
                          _Mark(
                            done: i < current,
                            current: i == current,
                            paused: paused && i == current,
                            onInk: onInk,
                            signed: status.signedDot,
                            ink: status.ink,
                            attention: status.attentionDot,
                            outline: scheme.outlineVariant,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      labels[i],
                      style: textTheme.bodySmall?.copyWith(
                        color: i <= current
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                        fontWeight: i == current ? .w600 : .w400,
                      ),
                      textAlign: .center,
                      maxLines: 2,
                      overflow: .ellipsis,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark({
    required this.done,
    required this.current,
    required this.paused,
    required this.onInk,
    required this.signed,
    required this.ink,
    required this.attention,
    required this.outline,
  });

  final bool done;
  final bool current;
  final bool paused;
  final Color onInk;
  final Color signed;
  final Color ink;
  final Color attention;
  final Color outline;

  @override
  Widget build(BuildContext context) {
    if (done) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: signed, shape: .circle),
        alignment: .center,
        child: AssetIcon(Assets.icons.tickIcon, size: 16, color: onInk),
      );
    }
    if (current) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: paused ? attention : ink,
          shape: .circle,
        ),
        alignment: .center,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: onInk, shape: .circle),
        ),
      );
    }
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: .circle,
        border: Border.all(color: outline, width: 2),
      ),
    );
  }
}
