/// freeRASP (Talsec) configuration (CRQ-0024).
///
/// None of these values is secret: certificate fingerprints, bundle ids and
/// team ids ship inside the app. freeRASP compares them with what the
/// running binary presents, to detect a repackaged copy.
///
/// Before the first Play release, add the **Play App Signing** certificate
/// to [prodSigningCertHashes] (Play Console > App integrity > App signing
/// key certificate). Play re-signs every upload, so a Play install presents
/// Google's certificate, not ours; without it, every Play install terminates.
///
/// A fingerprint converts with:
/// `echo -n <hex-without-colons> | xxd -r -p | base64`
abstract final class RaspConfig {
  static const String androidPackageName = 'com.tabibukenya.tabibu';

  /// SHA-256 (Base64) of the certificates a production build may present.
  static const List<String> prodSigningCertHashes = [
    // The Tabibu release key (CRQ-0008): what CI and local release builds
    // sign with, and the upload key once the app is on Play.
    'C+tcPKGXUJHAwBhv0vGJ89nji1jw7W+ptTk/Qh2H8Lo=',
  ];

  /// Only read when `isProd` is false, where freeRASP does not enforce it.
  static const List<String> devSigningCertHashes = [
    // The debug key that local development builds sign with.
    'iXPo+Hk5XbFyVqcn6G/gQyRkWMIlbOEICbGsLtTjiMs=',
  ];

  static const List<String> supportedStores = ['com.android.vending'];

  static const List<String> iosBundleIds = ['com.tabibukenya.tabibu'];

  /// The Apple Developer team the iOS app is signed with (the project's
  /// DEVELOPMENT_TEAM), which App Check's App Attest provider uses too. A
  /// release signed by any other team is treated as repackaged.
  static const String iosTeamId = 'Z5GNM65VQN';

  /// Talsec's security reports and portal access (my.talsec.app).
  static const String watcherMail = 'lilmuyansi@gmail.com';
}
