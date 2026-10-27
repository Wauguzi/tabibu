import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/services/app_update_service.dart';

class _MockRemoteConfig extends Mock implements FirebaseRemoteConfig {}

void main() {
  late _MockRemoteConfig config;

  AppUpdateService service(String running) => AppUpdateService(
    currentVersion: () async => running,
    remoteConfig: config,
  );

  void remote({required bool force, String minimum = '', String url = ''}) {
    when(() => config.getBool('force_update')).thenReturn(force);
    when(() => config.getString('min_required_version')).thenReturn(minimum);
    when(() => config.getString(any())).thenAnswer(
      (i) => switch (i.positionalArguments.first) {
        'min_required_version' => minimum,
        _ => url,
      },
    );
  }

  setUp(() => config = _MockRemoteConfig());

  test('the defaults let every build through', () async {
    remote(force: false);
    expect(await service('0.0.1').isUpdateRequired(), isFalse);
  });

  test('a minimum alone does not lock anyone out', () async {
    remote(force: false, minimum: '9.9.9');
    expect(await service('1.0.02').isUpdateRequired(), isFalse);
  });

  test('with the gate on, only older builds are stopped', () async {
    remote(force: true, minimum: '1.0.03');
    expect(await service('1.0.02').isUpdateRequired(), isTrue);
    expect(await service('1.0.03').isUpdateRequired(), isFalse);
    expect(await service('1.1.0').isUpdateRequired(), isFalse);
  });

  test('the gate on with no minimum stops nobody', () async {
    remote(force: true);
    expect(await service('0.0.1').isUpdateRequired(), isFalse);
  });

  test('a store link must be absolute', () {
    remote(force: false, url: '"https://play.google.com/store/apps"');
    expect(
      service('1.0.0').storeUrl(isIos: false),
      Uri.parse('https://play.google.com/store/apps'),
    );
    remote(force: false, url: 'not a url');
    expect(service('1.0.0').storeUrl(isIos: true), isNull);
  });
}
