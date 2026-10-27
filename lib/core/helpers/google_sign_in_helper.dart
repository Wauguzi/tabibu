// Client ids cannot be wrapped.
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// OAuth client ids are public identifiers, like the rest of the FlutterFire
/// config.
abstract final class GoogleSignInHelper {
  /// iOS client: `CLIENT_ID` in `GoogleService-Info.plist`. Android ignores
  /// it and reads `google-services.json`.
  static const _iosClientId =
      '270369739916-pg1tm5jc8vqbc15dh42gja1h107foaip.apps.googleusercontent.com';

  /// Web client (`client_type: 3` in `google-services.json`): the audience
  /// of the idToken that Firebase Auth verifies.
  static const _serverClientId =
      '270369739916-6fgpjjijrsorll82tgiast3kpmme33eb.apps.googleusercontent.com';

  static GoogleSignIn get instance => GoogleSignIn.instance;

  /// Web signs in through Firebase Auth's popup instead, so the plugin is
  /// not initialised there.
  static Future<void> initialize() async {
    if (kIsWeb) return;
    await GoogleSignIn.instance.initialize(
      clientId: _iosClientId,
      serverClientId: _serverClientId,
    );
  }
}
