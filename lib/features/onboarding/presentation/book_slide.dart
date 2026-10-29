import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/onboarding/presentation/intro_stamp.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// A3. Verified clinicians, with a mock booking card.
class BookSlide extends StatelessWidget {
  const BookSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return IntroSlideLayout(
      header: Column(
        crossAxisAlignment: .start,
        children: [
          Text(l10n.introBookTitleA, style: textTheme.displaySmall),
          // Clears the title's descenders above the pill.
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const _CliniciansPill(),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  l10n.introBookTitleB,
                  style: textTheme.displaySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.introBookBody, style: textTheme.bodyLarge),
        ],
      ),
      illustration: const _BookingCard(),
    );
  }
}

/// A3's dark pill: the clinicians behind the claim, plus their check.
class _CliniciansPill extends StatelessWidget {
  const _CliniciansPill();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final portraits = [
      Assets.images.portraits.portrait1.provider(),
      Assets.images.portraits.portrait2.provider(),
      Assets.images.portraits.portrait3.provider(),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: scheme.brightness == .dark
            ? scheme.surfaceContainerHighest
            : AppColors.inkLight,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: .min,
        children: [
          SizedBox(
            width: 40 + 29.0 * (portraits.length - 1),
            height: 40,
            child: Stack(
              children: [
                for (var i = 0; i < portraits.length; i++)
                  Positioned(
                    left: i * 29.0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: portraits[i],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            width: 44,
            height: 44,
            alignment: .center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: .circle,
            ),
            child: AssetIcon(
              Assets.icons.verificationBadge,
              size: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return IntroStampedCard(
      overlap: 6,
      card: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Avatar.tile(
                  name: l10n.introBookDoctorName,
                  image: Assets.images.portraits.portrait1.provider(),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              l10n.introBookDoctorName,
                              style: textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          AssetIcon(
                            Assets.icons.verificationBadge,
                            size: 16,
                            color: scheme.primary,
                          ),
                        ],
                      ),
                      Text(
                        l10n.introBookDoctorDetail,
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _Slot(label: l10n.introBookSlot1, selected: false),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _Slot(label: l10n.introBookSlot2, selected: true),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _Slot(label: l10n.introBookSlot3, selected: false),
                ),
              ],
            ),
          ],
        ),
      ),
      stamp: IntroStamp(
        title: l10n.introBookBooked,
        detail: l10n.introBookBookedDetail,
        background: scheme.primary,
        foreground: scheme.onPrimary,
        iconColor: scheme.onPrimary,
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: selected ? scheme.inverseSurface : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      alignment: .center,
      child: FittedBox(
        fit: .scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: textTheme.titleSmall?.copyWith(
            color: selected ? scheme.onInverseSurface : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
