import 'package:hive_ce/hive.dart';

part 'onboarding_hive.g.dart';

/// Device preferences that are not health data and outlive a sign-out:
/// whether onboarding was seen, and the chosen language. Kept in an
/// unencrypted box, because sign-out deletes the encrypted ones (§6).
@HiveType(typeId: 3)
class OnboardingHive {
  OnboardingHive({required this.isOnboarded, required this.languageString});

  @HiveField(0)
  final bool isOnboarded;

  /// `en` or `sw`; `''` until chosen, so the device locale decides.
  @HiveField(1)
  final String languageString;
}
