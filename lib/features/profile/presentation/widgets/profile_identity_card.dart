import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

ImageProvider? _photo(String url) => url.isEmpty ? null : NetworkImage(url);

/// The patient's card: photo, first name and last initial, the phone with
/// its last six digits hidden, and the edit button.
class PatientIdentityCard extends StatelessWidget {
  const PatientIdentityCard({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.editLabel,
    this.photoUrl = '',
    super.key,
  });

  final String firstName;
  final String lastName;

  /// E.164, as stored: `+254712345678`.
  final String phoneNumber;
  final String editLabel;
  final String photoUrl;

  /// "+254 712 *** ***": enough to recognise the number on a shared screen.
  static String maskPhone(String phone) {
    if (!phone.startsWith('+254') || phone.length != 13) return phone;
    return '+254 ${phone.substring(4, 7)} *** ***';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final shortName = lastName.isEmpty
        ? firstName
        : '$firstName ${lastName.characters.first}.';
    final isDark = scheme.brightness == .dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        // Raised in dark by a lighter tone, not a light shadow.
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.hero),
        boxShadow: AppShadows.card(),
      ),
      child: Padding(
        padding: AppStyles.cardPadding,
        child: Row(
          children: [
            Avatar.tile(
              name: '$firstName $lastName',
              image: _photo(photoUrl),
              radius: 28,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(shortName, style: textTheme.titleLarge),
                  Text(maskPhone(phoneNumber), style: textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Edit profile is a later screen; the button is in place for it.
            CircleIconButton(
              icon: Assets.icons.editIcon,
              onTap: null,
              semanticLabel: editLabel,
              onCard: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// A doctor's or pathologist's card: the teal hero with photo, name, role
/// and facility, and the KMPDC badge.
class PractitionerIdentityCard extends StatelessWidget {
  const PractitionerIdentityCard({
    required this.name,
    required this.subtitle,
    required this.verifiedLabel,
    this.photoUrl = '',
    super.key,
  });

  final String name;
  final String subtitle;
  final String verifiedLabel;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    return PatternCard(
      child: Row(
        children: [
          Avatar.tile(name: name, image: _photo(photoUrl), radius: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  name,
                  style: textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: .ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: status.brandContainer,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    child: Row(
                      mainAxisSize: .min,
                      children: [
                        AssetIcon(
                          Assets.icons.signedIcon,
                          size: 18,
                          color: status.brandText,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Flexible(
                          child: Text(
                            verifiedLabel,
                            style: textTheme.labelLarge?.copyWith(
                              color: status.brandText,
                            ),
                          ),
                        ),
                      ],
                    ),
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
