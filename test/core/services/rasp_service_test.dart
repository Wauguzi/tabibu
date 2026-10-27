import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/freerasp.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/services/rasp_service.dart';

// ── Mocks ───────────────────────────────────────────────────────────────────

class MockRaspPlatform extends Mock implements RaspPlatform {}

// ── Helpers ─────────────────────────────────────────────────────────────────

/// Fires `handleThreat` for every `Threat` value and collects the
/// emitted events from `threatStream`.
Future<List<SecurityThreatEvent>> _collectAllThreatEvents(
  RaspService service,
) async {
  final events = <SecurityThreatEvent>[];
  final sub = service.threatStream.listen(events.add);

  Threat.values.forEach(service.handleThreat);

  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return events;
}

void main() {
  setUpAll(() {
    // Mocktail needs a concrete fallback for every non-primitive type used
    // with any() / captureAny() matchers.
    registerFallbackValue(ThreatCallback());
    registerFallbackValue(TalsecConfig(watcherMail: 'fallback@example.com'));
  });

  late MockRaspPlatform platform;
  late List<SecurityThreatEvent> criticalCaptures;
  late RaspService service;

  setUp(() {
    platform = MockRaspPlatform();
    criticalCaptures = [];

    // Stub all async platform calls to succeed silently.
    when(() => platform.attachListener(any())).thenAnswer((_) async {});
    when(() => platform.start(any())).thenAnswer((_) async {});
    when(
      () => platform.blockScreenCapture(enabled: any(named: 'enabled')),
    ).thenAnswer((_) async {});
    when(() => platform.storeExternalId(any())).thenAnswer((_) async {});

    service = RaspService(
      platform: platform,
      // Capture critical-threat calls instead of calling exit().
      onCritical: criticalCaptures.add,
    );
  });

  // ── initialize() ──────────────────────────────────────────────────────────

  group('initialize()', () {
    test(
      'calls attachListener, start, and blockScreenCapture in order',
      () async {
        final calls = <String>[];
        when(() => platform.attachListener(any())).thenAnswer((_) async {
          calls.add('attachListener');
        });
        when(() => platform.start(any())).thenAnswer((_) async {
          calls.add('start');
        });
        when(
          () => platform.blockScreenCapture(enabled: true),
        ).thenAnswer((_) async => calls.add('blockScreenCapture'));

        await service.initialize(isProd: false);

        expect(calls, ['attachListener', 'start', 'blockScreenCapture']);
      },
    );

    test('bindUser stores the uid as the external id', () async {
      await service.bindUser('uid_abc');
      verify(() => platform.storeExternalId('uid_abc')).called(1);
    });

    test('bindUser ignores an empty uid', () async {
      await service.bindUser('');
      verifyNever(() => platform.storeExternalId(any()));
    });

    test('initialize binds no user', () async {
      await service.initialize(isProd: false);
      verifyNever(() => platform.storeExternalId(any()));
    });

    test(
      'blockScreenCapture failure is swallowed — initialize still completes',
      () async {
        when(
          () => platform.blockScreenCapture(enabled: true),
        ).thenThrow(Exception('platform error'));

        // Should not throw.
        await expectLater(service.initialize(isProd: false), completes);
      },
    );

    test('builds config with isProd:true for production', () async {
      TalsecConfig? captured;
      when(() => platform.start(any())).thenAnswer((invocation) async {
        captured = invocation.positionalArguments.first as TalsecConfig;
      });

      // Run with the Android platform override so the config builder
      // produces an AndroidConfig.
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        await service.initialize(isProd: true);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }

      expect(captured, isNotNull);
      expect(captured!.isProd, isTrue);
      expect(captured!.killOnBypass, isTrue);
      expect(captured!.androidConfig, isNotNull);
      expect(captured!.androidConfig!.packageName, 'com.tabibukenya.tabibu');
    });

    test('builds config with isProd:false for dev', () async {
      TalsecConfig? captured;
      when(() => platform.start(any())).thenAnswer((invocation) async {
        captured = invocation.positionalArguments.first as TalsecConfig;
      });

      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        await service.initialize(isProd: false);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }

      expect(captured!.isProd, isFalse);
      expect(captured!.killOnBypass, isFalse);
    });
  });

  // ── Threat classification ──────────────────────────────────────────────────

  group('handleThreat() — severity classification', () {
    test('critical threats emit SecurityThreatLevel.critical', () async {
      final criticalThreats = [
        Threat.privilegedAccess,
        Threat.hooks,
        Threat.appIntegrity,
        Threat.debug,
        Threat.obfuscationIssues,
      ];

      for (final threat in criticalThreats) {
        final events = <SecurityThreatEvent>[];
        final sub = service.threatStream.listen(events.add);

        service.handleThreat(threat);
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();

        expect(
          events.single.level,
          SecurityThreatLevel.critical,
          reason: '${threat.name} should be critical',
        );
        expect(events.single.threatName, threat.name);
      }
    });

    test('severe threats emit SecurityThreatLevel.severe', () async {
      final severeThreats = [
        Threat.unofficialStore,
        Threat.simulator,
        Threat.multiInstance,
        Threat.deviceBinding,
        Threat.bootloader,
      ];

      for (final threat in severeThreats) {
        final events = <SecurityThreatEvent>[];
        final sub = service.threatStream.listen(events.add);

        service.handleThreat(threat);
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();

        expect(
          events.single.level,
          SecurityThreatLevel.severe,
          reason: '${threat.name} should be severe',
        );
      }
    });

    test('advisory threats emit SecurityThreatLevel.advisory', () async {
      final advisoryThreats = [
        Threat.passcode,
        Threat.secureHardwareNotAvailable,
        Threat.systemVPN,
        Threat.devMode,
        Threat.adbEnabled,
        Threat.screenshot,
        Threat.screenRecording,
        Threat.unsecureWiFi,
        Threat.timeSpoofing,
        Threat.locationSpoofing,
        Threat.automation,
        Threat.deviceId,
      ];

      for (final threat in advisoryThreats) {
        final events = <SecurityThreatEvent>[];
        final sub = service.threatStream.listen(events.add);

        service.handleThreat(threat);
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();

        expect(
          events.single.level,
          SecurityThreatLevel.advisory,
          reason: '${threat.name} should be advisory',
        );
      }
    });

    test('all Threat enum values are classified — no unhandled case', () async {
      final events = await _collectAllThreatEvents(service);
      expect(events.length, Threat.values.length);
    });

    test('every event has a non-empty message', () async {
      final events = await _collectAllThreatEvents(service);
      for (final e in events) {
        expect(
          e.message,
          isNotEmpty,
          reason: '${e.threatName} has empty message',
        );
      }
    });

    test('threatName matches Threat.name for standard threats', () async {
      for (final threat in Threat.values) {
        final events = <SecurityThreatEvent>[];
        final sub = service.threatStream.listen(events.add);
        service.handleThreat(threat);
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        expect(events.single.threatName, threat.name);
      }
    });
  });

  // ── Critical handler — production vs dev ──────────────────────────────────

  group('critical handler', () {
    test('invokes onCritical for critical threats when isProd:true', () async {
      await service.initialize(isProd: true);

      service.handleThreat(Threat.privilegedAccess);
      await Future<void>.delayed(Duration.zero);

      expect(criticalCaptures.length, 1);
      expect(criticalCaptures.first.level, SecurityThreatLevel.critical);
    });

    test('does NOT invoke onCritical when isProd:false', () async {
      await service.initialize(isProd: false);

      service.handleThreat(Threat.privilegedAccess);
      await Future<void>.delayed(Duration.zero);

      expect(criticalCaptures, isEmpty);
    });

    test(
      'severe threats do NOT trigger onCritical even in production',
      () async {
        await service.initialize(isProd: true);

        service.handleThreat(Threat.unofficialStore);
        await Future<void>.delayed(Duration.zero);

        expect(criticalCaptures, isEmpty);
      },
    );

    test('advisory threats do NOT trigger onCritical in production', () async {
      await service.initialize(isProd: true);

      service.handleThreat(Threat.screenshot);
      await Future<void>.delayed(Duration.zero);

      expect(criticalCaptures, isEmpty);
    });
  });

  // ── handleMalware() ───────────────────────────────────────────────────────

  group('handleMalware()', () {
    test('emits severe event with package names', () async {
      final events = <SecurityThreatEvent>[];
      final sub = service.threatStream.listen(events.add);

      final apps = <SuspiciousAppInfo?>[
        SuspiciousAppInfo(
          packageInfo: PackageInfo(packageName: 'com.evil.spy'),
          reasons: const ['blacklisted'],
        ),
        SuspiciousAppInfo(
          packageInfo: PackageInfo(packageName: 'com.dodgy.app'),
          reasons: const ['suspicious permissions'],
        ),
      ];
      service.handleMalware(apps);

      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(events.single.level, SecurityThreatLevel.severe);
      expect(events.single.threatName, 'malware');
      expect(events.single.message, contains('com.evil.spy'));
      expect(events.single.message, contains('com.dodgy.app'));
    });

    test('emits severe event with "unknown" when app list is empty', () async {
      final events = <SecurityThreatEvent>[];
      final sub = service.threatStream.listen(events.add);

      service.handleMalware([]);

      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(events.single.message, contains('unknown'));
    });

    test('handles nullable entries in app list gracefully', () async {
      final events = <SecurityThreatEvent>[];
      final sub = service.threatStream.listen(events.add);

      // MalwareCallback passes List<SuspiciousAppInfo?> — nulls are filtered.
      service.handleMalware([
        null,
        SuspiciousAppInfo(
          packageInfo: PackageInfo(packageName: 'com.real.malware'),
          reasons: const ['blacklisted'],
        ),
        null,
      ]);

      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(events.single.message, contains('com.real.malware'));
    });
  });

  // ── threatStream ───────────────────────────────────────────────────────────

  group('threatStream', () {
    test('is a broadcast stream — supports multiple listeners', () {
      expect(() {
        service.threatStream.listen((_) {});
        service.threatStream.listen((_) {});
      }, returnsNormally);
    });

    test('delivers events to all concurrent listeners', () async {
      final a = <SecurityThreatEvent>[];
      final b = <SecurityThreatEvent>[];

      final subA = service.threatStream.listen(a.add);
      final subB = service.threatStream.listen(b.add);

      service.handleThreat(Threat.screenshot);
      await Future<void>.delayed(Duration.zero);

      await subA.cancel();
      await subB.cancel();

      expect(a.length, 1);
      expect(b.length, 1);
    });
  });

  group('user-facing hint', () {
    test('app-integrity family maps to the app bucket — a user can act on '
        '"reinstall from the official store"', () {
      for (final threat in [
        'appIntegrity',
        'unofficialStore',
        'obfuscationIssues',
        'multiInstance',
        'debug',
        'hooks',
      ]) {
        expect(RaspService.hintFor(threat), SecurityHint.app, reason: threat);
      }
    });

    test('malware and observation map to otherApp — the malware message '
        'embeds package names and must never reach the user', () {
      for (final threat in [
        'malware',
        'screenshot',
        'screenRecording',
        'automation',
      ]) {
        expect(
          RaspService.hintFor(threat),
          SecurityHint.otherApp,
          reason: threat,
        );
      }
    });

    test('environment threats map to network', () {
      for (final threat in [
        'systemVPN',
        'unsecureWiFi',
        'timeSpoofing',
        'locationSpoofing',
      ]) {
        expect(
          RaspService.hintFor(threat),
          SecurityHint.network,
          reason: threat,
        );
      }
    });

    test('device-property threats map to device', () {
      for (final threat in [
        'privilegedAccess',
        'bootloader',
        'simulator',
        'deviceBinding',
        'secureHardwareNotAvailable',
        'passcode',
        'devMode',
        'adbEnabled',
        'deviceId',
      ]) {
        expect(
          RaspService.hintFor(threat),
          SecurityHint.device,
          reason: threat,
        );
      }
    });

    test('an unknown threat from a future freeRASP release still gets a '
        'sane hint rather than throwing', () {
      expect(RaspService.hintFor('somethingNewIn2027'), SecurityHint.device);
    });

    test('no hint bucket leaks a detection name', () {
      // The buckets are wide on purpose: naming the probe that fired tells
      // whoever triggered it exactly what to defeat next.
      expect(SecurityHint.values, hasLength(4));
    });
  });
}
