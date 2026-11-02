/// The client Remote Config defaults: what the app shows before a fetch, or
/// when one fails. The server keeps its own template for jobs and delivery
/// (functions/src/config.ts); a kill switch is flipped in both, server first.
abstract final class RemoteConfigDefaults {
  /// The eight AI and alert kill switches. On means the surface shows; the
  /// server still decides whether the job runs.
  static const killSwitches = <String, Object>{
    'preread_enabled': true,
    'risk_check_enabled': true,
    'patient_explanations_enabled': true,
    'alerts_delivery_enabled': true,
    'symptom_intake_enabled': true,
    'report_translation_enabled': true,
    'voice_input_enabled': true,
    'alert_drafting_enabled': true,
  };

  /// The force-update parameters (CRQ-0011).
  static const appUpdate = <String, Object>{
    'force_update': false,
    'min_required_version': '',
    'store_url_android': '',
    'store_url_ios': '',
    'update_title': '',
    'update_message': '',
  };

  static const values = <String, Object>{...appUpdate, ...killSwitches};
}
