import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A horizontal case stage track: done (teal tick), current (ink, or
/// attention when [paused]), later (outline). One semantics summary for the
/// whole stepper. With [scrollable] every label keeps to one line: the steps
/// widen to their labels and the track scrolls sideways, opening on the
/// current step.
class CaseStepper extends StatefulWidget {
  const CaseStepper({
    required this.labels,
    required this.current,
    required this.semanticLabel,
    this.paused = false,
    this.scrollable = false,
    super.key,
  });

  final List<String> labels;
  final int current;
  final String semanticLabel;
  final bool paused;
  final bool scrollable;

  @override
  State<CaseStepper> createState() => _CaseStepperState();
}

class _CaseStepperState extends State<CaseStepper> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Centres the current step once the track is laid out.
  void _reveal(double stepWidth, double viewport) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final target = widget.current * stepWidth - (viewport - stepWidth) / 2;
      _scroll.jumpTo(target.clamp(0, _scroll.position.maxScrollExtent));
    });
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.labels;
    final current = widget.current;
    final paused = widget.paused;
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final onInk = isDark ? AppColors.inkLight : AppColors.white;
    final count = labels.length;

    Widget track(Widget Function(Widget step) place) => Row(
      crossAxisAlignment: .start,
      children: [
        for (var i = 0; i < count; i++)
          place(
            Column(
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
                  maxLines: widget.scrollable ? 1 : 2,
                  softWrap: !widget.scrollable,
                  overflow: .ellipsis,
                ),
              ],
            ),
          ),
      ],
    );

    if (!widget.scrollable) {
      return Semantics(
        label: widget.semanticLabel,
        child: ExcludeSemantics(child: track((step) => Expanded(child: step))),
      );
    }

    final labelStyle = textTheme.bodySmall?.copyWith(fontWeight: .w600);
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    return Semantics(
      label: widget.semanticLabel,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            var widest = 0.0;
            for (final label in labels) {
              final painter = TextPainter(
                text: TextSpan(text: label, style: labelStyle),
                textDirection: direction,
                textScaler: scaler,
                maxLines: 1,
              )..layout();
              if (painter.width > widest) widest = painter.width;
              painter.dispose();
            }
            // Room for the label and a gap, never narrower than an even split.
            final stepWidth = math.max(
              constraints.maxWidth / count,
              widest + 2 * AppSpacing.sm,
            );
            _reveal(stepWidth, constraints.maxWidth);
            return SingleChildScrollView(
              controller: _scroll,
              scrollDirection: .horizontal,
              child: track((step) => SizedBox(width: stepWidth, child: step)),
            );
          },
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
