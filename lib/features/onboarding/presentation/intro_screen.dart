import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// A3–A5. Three swipeable slides with dots; the last slide's action moves to
/// A6. Each slide scrolls, so large text never clips.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLast = _index == 2;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (index) => setState(() => _index = index),
                  children: const [_BookSlide(), _CaseSlide(), _ResultsSlide()],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              PageDots(count: 3, index: _index),
              const SizedBox(height: AppSpacing.md),
              TabibuButton.primary(
                label: isLast ? l10n.introGetStarted : l10n.commonNext,
                onTap: () {
                  if (isLast) {
                    const GetStartedRoute().go(context);
                  } else {
                    _goTo(_index + 1);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              TabibuButton.ghost(
                label: isLast ? l10n.commonBack : l10n.commonSkip,
                onTap: () {
                  if (isLast) {
                    _goTo(_index - 1);
                  } else {
                    const GetStartedRoute().go(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A3. Verified clinicians, with a mock booking card.
class _BookSlide extends StatelessWidget {
  const _BookSlide();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(
                name: l10n.introBookDoctorName,
                image: Assets.images.portraits.portrait1.provider(),
                radius: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Avatar(
                name: l10n.introBookDoctorName,
                image: Assets.images.portraits.portrait2.provider(),
                radius: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Avatar(
                name: l10n.introBookDoctorName,
                image: Assets.images.portraits.portrait3.provider(),
                radius: 20,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.introBookTitle, style: textTheme.displaySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.introBookBody, style: textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.lg),
          Container(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.introBookDoctorName,
                            style: textTheme.titleMedium,
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Slot(label: l10n.introBookSlot1, selected: false),
                    _Slot(label: l10n.introBookSlot2, selected: true),
                    _Slot(label: l10n.introBookSlot3, selected: false),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.introBookBooked,
                              style: textTheme.titleSmall?.copyWith(
                                color: scheme.onPrimary,
                              ),
                            ),
                            Text(
                              l10n.introBookBookedDetail,
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: selected ? scheme.inverseSurface : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: textTheme.titleSmall?.copyWith(
          color: selected ? scheme.onInverseSurface : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// A4. One case across patient, doctor and pathologist.
class _CaseSlide extends StatelessWidget {
  const _CaseSlide();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          _CaseRow(
            icon: Assets.icons.heartIcon,
            tone: IconTone.sky,
            title: l10n.rolePatient,
            body: l10n.introCasePatientBody,
          ),
          const SizedBox(height: AppSpacing.sm),
          _CaseRow(
            icon: Assets.icons.stethoscopeIcon,
            tone: IconTone.mint,
            title: l10n.roleDoctor,
            body: l10n.introCaseDoctorBody,
          ),
          const SizedBox(height: AppSpacing.sm),
          _CaseRow(
            icon: Assets.icons.testTubeIcon,
            tone: IconTone.lavender,
            title: l10n.rolePathologist,
            body: l10n.introCasePathologistBody,
          ),
          const SizedBox(height: AppSpacing.sm),
          _CaseRow(
            icon: Assets.icons.verificationBadge,
            tone: IconTone.mint,
            title: l10n.introCaseBackTitle,
            body: l10n.introCaseBackBody,
          ),
        ],
      ),
    );
  }
}

class _CaseRow extends StatelessWidget {
  const _CaseRow({
    required this.icon,
    required this.tone,
    required this.title,
    required this.body,
  });

  final SvgGenImage icon;
  final IconTone tone;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        children: [
          IconTile(icon: icon, tone: tone),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleMedium),
                Text(body, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A5. Results checked and explained, with a mock results card.
class _ResultsSlide extends StatelessWidget {
  const _ResultsSlide();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      tone: StatusTone.signed,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                const _ResultBar(fraction: 1, tone: IconTone.lavender),
                const SizedBox(height: AppSpacing.xs),
                const _ResultBar(fraction: 0.8, tone: IconTone.lavender),
                const SizedBox(height: AppSpacing.xs),
                const _ResultBar(fraction: 0.65, tone: IconTone.mint),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.introResultsChecked,
                  style: textTheme.bodyMedium?.copyWith(color: scheme.primary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: scheme.inverseSurface,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.introResultsSigned,
                              style: textTheme.titleSmall?.copyWith(
                                color: scheme.onInverseSurface,
                              ),
                            ),
                            Text(
                              l10n.introResultsSignedDetail,
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onInverseSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBar extends StatelessWidget {
  const _ResultBar({required this.fraction, required this.tone});

  final double fraction;
  final IconTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (tone) {
      IconTone.lavender => scheme.tertiaryContainer,
      _ => scheme.secondaryContainer,
    };
    return FractionallySizedBox(
      widthFactor: fraction,
      alignment: Alignment.centerLeft,
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
