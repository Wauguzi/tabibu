import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// A4. One case across patient, doctor, pathologist, and back to the patient,
/// joined by a timeline.
class CaseSlide extends StatelessWidget {
  const CaseSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text.rich(
            TextSpan(
              style: textTheme.displaySmall,
              children: [
                TextSpan(text: '${l10n.introCaseTitleA}\n'),
                TextSpan(
                  text: '${l10n.introCaseTitleB}\n',
                  style: TextStyle(color: scheme.primary),
                ),
                TextSpan(text: l10n.introCaseTitleC),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _TimelineRow(
            tile: IconTile(icon: Assets.icons.heartIcon, tone: .sky),
            title: l10n.rolePatient,
            body: l10n.introCasePatientBody,
            line: _Line.down,
          ),
          const _GapLine(),
          _TimelineRow(
            tile: IconTile(icon: Assets.icons.stethoscopeIcon, tone: .mint),
            title: l10n.roleDoctor,
            body: l10n.introCaseDoctorBody,
            line: _Line.through,
          ),
          const _GapLine(),
          _TimelineRow(
            tile: IconTile(icon: Assets.icons.testTubeIcon, tone: .lavender),
            title: l10n.rolePathologist,
            body: l10n.introCasePathologistBody,
            line: _Line.through,
          ),
          const _GapLine(),
          _TimelineRow(
            tile: IconTile(icon: Assets.icons.checkSelectedIcon, tone: .white),
            title: l10n.introCaseBackTitle,
            body: l10n.introCaseBackBody,
            line: _Line.up,
          ),
        ],
      ),
    );
  }
}

enum _Line { down, through, up }

const double _ring = 4;
const double _lineLeft = _ring + 44 / 2 - 1;

/// A4's timeline row: the tile centered against its card, with the joining
/// line drawn from the tile's middle so rows of any height stay joined.
class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.tile,
    required this.title,
    required this.body,
    required this.line,
  });

  final Widget tile;
  final String title;
  final String body;
  final _Line line;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned(
          left: _lineLeft,
          top: 0,
          bottom: 0,
          child: Align(
            alignment: switch (line) {
              _Line.down => Alignment.bottomCenter,
              _Line.up => Alignment.topCenter,
              _Line.through => .center,
            },
            child: FractionallySizedBox(
              heightFactor: line == _Line.through ? 1 : 0.5,
              child: Container(width: 2, color: scheme.outlineVariant),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              _Ring(child: tile),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                  child: Column(
                    crossAxisAlignment: .start,
                    mainAxisSize: .min,
                    children: [
                      Text(title, style: textTheme.titleMedium),
                      Text(body, style: textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A4's joining line across an inter-row gap, under the tile centers.
class _GapLine extends StatelessWidget {
  const _GapLine();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.sm,
      child: Stack(
        children: [
          Positioned(
            left: _lineLeft,
            top: 0,
            bottom: 0,
            child: Container(
              width: 2,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// A4's tiles sit in a soft ring, as designed.
class _Ring extends StatelessWidget {
  const _Ring({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(_ring),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14 + _ring),
      ),
      child: child,
    );
  }
}
