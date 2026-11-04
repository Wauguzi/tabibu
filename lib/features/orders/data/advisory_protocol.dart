import 'package:tabibu/l10n/l10n.dart';

/// What a risk-check advisory points to in the bundled guidance (F-13). The
/// server only ever sends keys from its fixed table, so an unknown key reads
/// as no protocol rather than a guess.
enum AdvisoryProtocol {
  vhf;

  /// The server's `advisoryKey`.
  String get key => switch (this) {
    .vhf => 'VhfProtocol',
  };

  /// The guidance row whose clinician bullets give the case definition and
  /// the reporting rule.
  String get guidanceDiseaseId => switch (this) {
    .vhf => 'ebola_virus_disease',
  };

  String title(AppLocalizations l10n) => switch (this) {
    .vhf => l10n.mohVhfTitle,
  };

  String body(AppLocalizations l10n) => switch (this) {
    .vhf => l10n.mohVhfBody,
  };

  static AdvisoryProtocol? fromKey(String key) {
    for (final protocol in values) {
      if (protocol.key == key) return protocol;
    }
    return null;
  }
}
