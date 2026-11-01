import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/l10n/l10n.dart';

// One parsed row of a functions copy file.
class _PushRow {
  const _PushRow({required this.body, this.title, this.bodyPlural});

  final String? title;
  final String body;
  final String? bodyPlural;
}

// Reads a functions copy file as text and extracts each key's row. Keys sit
// at two-space indent; their fields sit deeper, so the key pattern cannot
// match a field.
Map<String, _PushRow> _readCopy(String path) {
  final text = File(path).readAsStringSync();
  final rows = <String, _PushRow>{};
  final starts = RegExp(
    r'^  (\w+): \{',
    multiLine: true,
  ).allMatches(text).toList();
  for (var i = 0; i < starts.length; i++) {
    final end = i + 1 < starts.length ? starts[i + 1].start : text.length;
    final block = text.substring(starts[i].end, end);
    String? field(String name) =>
        RegExp("$name: '([^']*)'").firstMatch(block)?.group(1);
    rows[starts[i].group(1)!] = _PushRow(
      title: field('title'),
      body: field('body')!,
      bodyPlural: field('bodyPlural'),
    );
  }
  return rows;
}

Map<String, dynamic> _readArb(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

// The placeholders an ICU message uses: `{name}` and the `{name, plural, …}`
// head. A plural branch such as `=1{…}` never matches.
Set<String> _placeholdersOf(String message) => RegExp(
  r'\{(\w+)(?:,|\})',
).allMatches(message).map((m) => m.group(1)!).toSet();

void main() {
  final enCopy = _readCopy('functions/src/copy/notifications.en.ts');
  final swCopy = _readCopy('functions/src/copy/notifications.sw.ts');

  test('the functions copy files hold the 46 cloud keys in both languages', () {
    expect(enCopy, hasLength(46));
    expect(swCopy, hasLength(46));
    expect(enCopy.keys.toSet(), swCopy.keys.toSet());
  });

  group('fromValue', () {
    test('round-trips every value', () {
      for (final template in NotificationTemplate.values) {
        expect(
          NotificationTemplate.fromValue(template.value),
          template,
          reason: '$template',
        );
      }
      expect(NotificationTemplate.unknown.value, '');
    });

    test('reads an unknown key as unknown', () {
      expect(
        NotificationTemplate.fromValue('noSuchKey'),
        NotificationTemplate.unknown,
      );
      expect(
        NotificationTemplate.fromValue('OrderCreated'),
        NotificationTemplate.unknown,
      );
    });

    test(
      'every functions key has a value; every non-local value has a key',
      () {
        const local = {
          'appointmentRequestSent',
          'appointmentCompleted',
          'orderSubmitted',
          'draftSaved',
          'prereadScored',
          'reportSignedSelf',
          'shareCodeSent',
          'mdtOpened',
          'messagesQueued',
          'queuedMessagesSent',
          'notifiableRecorded',
          'alertDecisionSaved',
        };
        for (final key in enCopy.keys) {
          expect(
            NotificationTemplate.fromValue(key),
            isNot(NotificationTemplate.unknown),
            reason: key,
          );
        }
        final cloud = NotificationTemplate.values
            .where((t) => t != NotificationTemplate.unknown)
            .map((t) => t.value)
            .where((v) => !local.contains(v));
        expect(cloud.toSet(), enCopy.keys.toSet());
      },
    );
  });

  group('copy', () {
    late AppLocalizations en;
    late AppLocalizations sw;

    setUpAll(() async {
      en = await AppLocalizations.delegate.load(const Locale('en'));
      sw = await AppLocalizations.delegate.load(const Locale('sw'));
    });

    const args = {'newCount': '3', 'disease': 'Cholera', 'county': 'Kisumu'};

    String filled(String template) => template
        .replaceAll('{newCount}', args['newCount']!)
        .replaceAll('{disease}', args['disease']!)
        .replaceAll('{county}', args['county']!);

    test('every body is non-empty in en and sw', () {
      for (final template in NotificationTemplate.values) {
        expect(template.body(en, args), isNotEmpty, reason: '$template en');
        expect(template.body(sw, args), isNotEmpty, reason: '$template sw');
      }
    });

    test('titles match the functions copy: present where it has one', () {
      for (final template in NotificationTemplate.values) {
        final enTitle = enCopy[template.value]?.title;
        final swTitle = swCopy[template.value]?.title;
        if (enTitle == null) {
          expect(template.title(en, args), '', reason: '$template en');
          expect(template.title(sw, args), '', reason: '$template sw');
        } else {
          expect(template.title(en, args), enTitle, reason: '$template en');
          expect(template.title(sw, args), swTitle, reason: '$template sw');
        }
      }
    });

    test('cloud bodies equal the functions copy with sample placeholders', () {
      for (final entry in enCopy.entries) {
        final template = NotificationTemplate.fromValue(entry.key);
        if (entry.value.bodyPlural == null) {
          expect(
            template.body(en, args),
            filled(entry.value.body),
            reason: '${entry.key} en',
          );
        } else {
          expect(
            template.body(en, const {'newCount': '1'}),
            filled(entry.value.body),
            reason: '${entry.key} en singular',
          );
          expect(
            template.body(en, const {'newCount': '3'}),
            filled(entry.value.bodyPlural!),
            reason: '${entry.key} en plural',
          );
        }
      }
      for (final entry in swCopy.entries) {
        final template = NotificationTemplate.fromValue(entry.key);
        if (entry.value.bodyPlural == null) {
          expect(
            template.body(sw, args),
            filled(entry.value.body),
            reason: '${entry.key} sw',
          );
        } else {
          expect(
            template.body(sw, const {'newCount': '1'}),
            filled(entry.value.body),
            reason: '${entry.key} sw singular',
          );
          expect(
            template.body(sw, const {'newCount': '3'}),
            filled(entry.value.bodyPlural!),
            reason: '${entry.key} sw plural',
          );
        }
      }
    });

    test('a missing count reads the singular line', () {
      expect(
        NotificationTemplate.messageReceived.body(en, const {}),
        enCopy['messageReceived']!.body,
      );
      expect(
        NotificationTemplate.mdtMessageReceived.body(sw, const {
          'newCount': 'many',
        }),
        swCopy['mdtMessageReceived']!.body,
      );
    });

    test('en/sw placeholder parity in ARB for every key', () {
      final enArb = _readArb('lib/l10n/arb/app_en.arb');
      final swArb = _readArb('lib/l10n/arb/app_sw.arb');
      for (final template in NotificationTemplate.values) {
        final key = template == NotificationTemplate.unknown
            ? 'unknown'
            : template.value;
        final stem = 'notification${key[0].toUpperCase()}${key.substring(1)}';
        final enBody = enArb['${stem}Body'] as String;
        final swBody = swArb['${stem}Body'] as String;
        expect(
          _placeholdersOf(swBody),
          _placeholdersOf(enBody),
          reason: '${stem}Body',
        );
        final enTitle = enArb['${stem}Title'] as String?;
        final swTitle = swArb['${stem}Title'] as String?;
        expect(swTitle != null, enTitle != null, reason: '${stem}Title');
        if (enTitle != null) {
          expect(
            _placeholdersOf(swTitle!),
            _placeholdersOf(enTitle),
            reason: '${stem}Title',
          );
        }
      }
    });
  });
}
