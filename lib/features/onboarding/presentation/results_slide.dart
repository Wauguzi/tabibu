import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/onboarding/presentation/intro_stamp.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// A5. Results checked and explained, with a mock results card.
class ResultsSlide extends StatelessWidget {
  const ResultsSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return IntroSlideLayout(
      header: Column(
        crossAxisAlignment: .start,
        children: [
          Text.rich(
            TextSpan(
              style: textTheme.displaySmall,
              children: [
                TextSpan(text: '${l10n.introResultsTitleA}\n'),
                TextSpan(
                  text: l10n.introResultsTitleB,
                  style: TextStyle(color: scheme.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.introResultsBody, style: textTheme.bodyLarge),
        ],
      ),
      illustration: const _ResultsCard(),
    );
  }
}

class _ResultsCard extends StatelessWidget {
  const _ResultsCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return IntroStampedCard(
      card: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xxlg,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.introResultsCardTitle,
                    style: textTheme.titleMedium,
                  ),
                ),
                StatusChip(
                  label: l10n.verificationStatusVerified,
                  tone: .signed,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const _ResultBar(fraction: 1),
            const SizedBox(height: AppSpacing.xs),
            const _ResultBar(fraction: 0.85),
            const SizedBox(height: AppSpacing.xs),
            const _ResultBar(fraction: 0.92, teal: true),
            const SizedBox(height: AppSpacing.xs),
            const _ResultBar(fraction: 0.6),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisSize: .min,
              children: [
                AssetIcon(
                  Assets.icons.verificationBadge,
                  size: 16,
                  color: scheme.primary,
                ),
                const SizedBox(width: AppSpacing.xxs),
                Flexible(
                  child: Text(
                    l10n.introResultsChecked,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      stamp: IntroStamp(
        title: l10n.introResultsReviewed,
        detail: l10n.introResultsReviewedDetail,
        background: scheme.inverseSurface,
        foreground: scheme.onInverseSurface,
        iconColor: scheme.inversePrimary,
      ),
    );
  }
}

class _ResultBar extends StatelessWidget {
  const _ResultBar({required this.fraction, this.teal = false});

  final double fraction;
  final bool teal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FractionallySizedBox(
      widthFactor: fraction,
      alignment: .centerLeft,
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          color: teal ? scheme.primaryContainer : scheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
