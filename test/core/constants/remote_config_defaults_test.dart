import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/remote_config_defaults.dart';

void main() {
  test('all eight kill switches have a client default', () {
    expect(RemoteConfigDefaults.killSwitches.keys.toSet(), {
      'preread_enabled',
      'risk_check_enabled',
      'patient_explanations_enabled',
      'alerts_delivery_enabled',
      'symptom_intake_enabled',
      'report_translation_enabled',
      'voice_input_enabled',
      'alert_drafting_enabled',
    });
    expect(RemoteConfigDefaults.killSwitches.values, everyElement(isTrue));
  });

  test('the defaults keep the force-update parameters', () {
    expect(
      RemoteConfigDefaults.values.keys,
      containsAll(['force_update', 'min_required_version', 'update_message']),
    );
    expect(RemoteConfigDefaults.values['force_update'], isFalse);
  });
}
