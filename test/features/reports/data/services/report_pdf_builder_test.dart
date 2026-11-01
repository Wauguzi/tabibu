// cspell:ignore beginbfchar endbfchar beginbfrange endbfrange endstream Annots
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/report_pdf_input.dart';
import 'package:tabibu/features/reports/data/models/report_response_model.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_model.dart';
import 'package:tabibu/features/reports/data/services/report_pdf_builder.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../models/pathology_report_model_test.dart' show reportJson;

/// Splits an uncompressed PDF into its objects, in file order.
Map<int, String> _objects(String raw) {
  final headers = RegExp(r'\n(\d+) 0 obj\b').allMatches(raw).toList();
  final objects = <int, String>{};
  for (var i = 0; i < headers.length; i++) {
    final end = i + 1 < headers.length ? headers[i + 1].start : raw.length;
    objects[int.parse(headers[i].group(1)!)] = raw.substring(
      headers[i].end,
      end,
    );
  }
  return objects;
}

/// The bytes of an ASCII stream object (content or ToUnicode).
String _streamBody(String object) {
  final start = object.indexOf('stream');
  final end = object.lastIndexOf('endstream');
  if (start < 0 || end < 0 || end <= start) return '';
  final body = object.substring(start + 'stream'.length, end);
  if (body.startsWith('\r\n')) return body.substring(2);
  if (body.startsWith('\n') || body.startsWith('\r')) {
    return body.substring(1);
  }
  return body;
}

/// A ToUnicode CMap as glyph-code-to-text runs.
Map<int, String> _toUnicodeMap(String stream) {
  final map = <int, String>{};
  String run(String hex) => String.fromCharCodes([
    for (var i = 0; i + 4 <= hex.length; i += 4)
      int.parse(hex.substring(i, i + 4), radix: 16),
  ]);
  final chars = RegExp(
    'beginbfchar(.*?)endbfchar',
    dotAll: true,
  ).allMatches(stream);
  for (final section in chars) {
    final pairs = RegExp(
      r'<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>',
    ).allMatches(section.group(1)!);
    for (final pair in pairs) {
      map[int.parse(pair.group(1)!, radix: 16)] = run(pair.group(2)!);
    }
  }
  final ranges = RegExp(
    'beginbfrange(.*?)endbfrange',
    dotAll: true,
  ).allMatches(stream);
  for (final section in ranges) {
    final lines = RegExp(
      r'<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>\s*(?:<([0-9A-Fa-f]+)>|\[(.*?)\])',
    ).allMatches(section.group(1)!);
    for (final line in lines) {
      final lo = int.parse(line.group(1)!, radix: 16);
      final first = line.group(3);
      if (first != null) {
        var code = int.parse(first, radix: 16);
        for (var src = lo; src <= int.parse(line.group(2)!, radix: 16); src++) {
          map[src] = String.fromCharCode(code++);
        }
      } else {
        var src = lo;
        final targets = RegExp('<([0-9A-Fa-f]+)>').allMatches(line.group(4)!);
        for (final target in targets) {
          map[src++] = run(target.group(1)!);
        }
      }
    }
  }
  return map;
}

String _decodeHex(String hex, Map<int, String> map) {
  final out = StringBuffer();
  for (var i = 0; i + 4 <= hex.length; i += 4) {
    out.write(map[int.parse(hex.substring(i, i + 4), radix: 16)] ?? '');
  }
  return out.toString();
}

/// A literal string's bytes as Identity-H code pairs.
String _decodeLiteral(String body, Map<int, String> map) {
  final bytes = <int>[];
  for (var i = 0; i < body.length; i++) {
    if (body[i] != r'\') {
      bytes.add(body.codeUnitAt(i));
      continue;
    }
    if (++i >= body.length) break;
    final e = body[i];
    if (e == 'n') {
      bytes.add(10);
    } else if (e == 'r') {
      bytes.add(13);
    } else if (e == 't') {
      bytes.add(9);
    } else if (e == 'b') {
      bytes.add(8);
    } else if (e == 'f') {
      bytes.add(12);
    } else if (e == '(' || e == ')' || e == r'\') {
      bytes.add(body.codeUnitAt(i));
    } else if (RegExp('[0-7]').hasMatch(e)) {
      final octal = StringBuffer(e);
      while (octal.length < 3 &&
          i + 1 < body.length &&
          RegExp('[0-7]').hasMatch(body[i + 1])) {
        octal.write(body[++i]);
      }
      bytes.add(int.parse(octal.toString(), radix: 8));
    }
    // A backslash before a newline is a continuation: dropped.
  }
  final out = StringBuffer();
  for (var i = 0; i + 2 <= bytes.length; i += 2) {
    out.write(map[(bytes[i] << 8) + bytes[i + 1]] ?? '');
  }
  return out.toString();
}

/// The words of one content stream. The pdf package paints word by word
/// and never encodes spaces, tracking the current font for its CMap.
List<String> _words(
  String stream,
  Map<String, int> fontRefs,
  Map<int, Map<int, String>> fonts,
) {
  final words = <String>[];
  var map = const <int, String>{};
  final tokens = RegExp(
    r'/F(\d+)\s+[\d.]+\s+Tf|<([0-9A-Fa-f]+)>|\(((?:[^()\\]|\\.)*)\)',
  ).allMatches(stream);
  for (final token in tokens) {
    if (token.group(1) != null) {
      map = fonts[fontRefs[token.group(1)!]] ?? const {};
    } else if (token.group(2) != null) {
      final word = _decodeHex(token.group(2)!, map);
      if (word.isNotEmpty) words.add(word);
    } else {
      final word = _decodeLiteral(token.group(3)!, map);
      if (word.isNotEmpty) words.add(word);
    }
  }
  return words;
}

/// The text of each page, in order; words joined with single spaces.
List<String> _pageTexts(Uint8List bytes) {
  final raw = latin1.decode(bytes);
  final objects = _objects(raw);
  final fonts = <int, Map<int, String>>{};
  for (final entry in objects.entries) {
    final toUnicode = RegExp(
      r'/ToUnicode\s*(\d+)\s+0\s+R',
    ).firstMatch(entry.value);
    if (toUnicode != null) {
      fonts[entry.key] = _toUnicodeMap(
        _streamBody(objects[int.parse(toUnicode.group(1)!)] ?? ''),
      );
    }
  }
  final pages = <String>[];
  for (final entry in objects.entries) {
    if (!RegExp(r'/Type\s*/Page(?!s)').hasMatch(entry.value)) continue;
    final fontRefs = <String, int>{};
    final resources = RegExp(
      r'/Font\s*<<(.*?)>>',
      dotAll: true,
    ).firstMatch(entry.value);
    if (resources != null) {
      final refs = RegExp(
        r'/F(\d+)\s+(\d+)\s+0\s+R',
      ).allMatches(resources.group(1)!);
      for (final ref in refs) {
        fontRefs[ref.group(1)!] = int.parse(ref.group(2)!);
      }
    }
    final contents = <int>[];
    final single = RegExp(r'/Contents\s*(\d+)\s+0\s+R').firstMatch(entry.value);
    if (single != null) {
      contents.add(int.parse(single.group(1)!));
    } else {
      final array = RegExp(r'/Contents\s*\[(.*?)\]').firstMatch(entry.value);
      if (array != null) {
        contents.addAll(
          RegExp(
            r'(\d+)\s+0\s+R',
          ).allMatches(array.group(1)!).map((m) => int.parse(m.group(1)!)),
        );
      }
    }
    final words = <String>[];
    for (final number in contents) {
      words.addAll(_words(_streamBody(objects[number] ?? ''), fontRefs, fonts));
    }
    pages.add(words.join(' '));
  }
  return pages;
}

void main() {
  late AppLocalizations en;
  late AppLocalizations sw;
  late ReportPdfBuilder builder;
  late Uint8List signaturePng;

  setUpAll(() async {
    await initializeDateFormatting('sw');
    en = await AppLocalizations.delegate.load(const Locale('en'));
    sw = await AppLocalizations.delegate.load(const Locale('sw'));
    builder = ReportPdfBuilder(
      assetLoader: (key) async =>
          (await File(key).readAsBytes()).buffer.asByteData(),
      compress: false,
    );
    signaturePng = await File('assets/icons/tabibu_logo.png').readAsBytes();
  });

  final now = DateTime.utc(2026, 11, 1, 12);
  final report = PathologyReportModel.fromJson(reportJson());

  ReportPdfInput pdfInput({
    PathologyReportModel? reportOverride,
    ReportTextApprovedModel? translation,
    Uint8List? signature,
  }) {
    return ReportPdfInput.fromSignedReport(
      report: reportOverride ?? report,
      locale: 'en',
      viewerRole: 'Doctor',
      viewerUid: 'doc-1',
      patientUid: 'patient-1',
      patientDisplayName: 'Patient One',
      dateOfBirth: '1990-01-15T00:00:00.000Z',
      sex: 'Female',
      county: 'Nairobi',
      subCounty: 'Kibra',
      doctorName: 'Dr Doc',
      doctorFacilityName: 'Clinic One',
      clinicalNotes: 'Notes',
      disclaimer: 'Disclaimer',
      generatedAtLabel: '2026-11-01 15:00',
      now: now,
      translation: translation,
      signaturePng: signature?.toList() ?? const [],
      supportContact: 'help@example.com',
    );
  }

  List<ReportResponseModel> longResponses() => [
    for (var section = 0; section < 8; section++)
      for (var question = 0; question < 12; question++)
        ReportResponseModel(
          section: 'Section$section',
          question: 'question$question',
          answer:
              'Answer $section $question with enough words to fill '
              'several lines of the page body.',
          order: section * 12 + question,
        ),
  ];

  test('builds a non-empty PDF in en and sw', () async {
    final enBytes = await builder.build(pdfInput(), en);
    expect(enBytes, isNotEmpty);
    expect(latin1.decode(enBytes.sublist(0, 5)), '%PDF-');
    final swBytes = await builder.build(pdfInput(), sw);
    expect(swBytes, isNotEmpty);
    expect(latin1.decode(swBytes.sublist(0, 5)), '%PDF-');
  });

  test('long names and values wrap instead of throwing', () async {
    final long = 'Long ' * 40;
    final input = pdfInput(
      reportOverride: report.copyWith(
        testName: long,
        diagnosis: long,
        comments: long,
        responses: [
          ReportResponseModel(
            section: 'Macroscopic',
            question: 'margins',
            answer: long,
          ),
        ],
      ),
    );
    final bytes = await builder.build(
      input.copyWith(
        footer: input.footer.copyWith(patientName: long),
        subject: input.subject.copyWith(displayName: long),
      ),
      en,
    );
    expect(bytes, isNotEmpty);
  });

  test('a long report spans pages and every page has its footer', () async {
    final bytes = await builder.build(
      pdfInput(reportOverride: report.copyWith(responses: longResponses())),
      en,
    );
    final pages = _pageTexts(bytes);
    expect(pages.length, greaterThan(2));
    for (var i = 0; i < pages.length; i++) {
      expect(pages[i], contains(en.reportPdfPage(i + 1, pages.length)));
    }
  });

  test(
    'the stage banner shows only for amended and addended reports',
    () async {
      Future<String> textFor(String stage) async {
        final bytes = await builder.build(
          pdfInput(
            reportOverride: report.copyWith(
              stage: stage,
              version: 2,
              amendmentReason: 'Fixed.',
            ),
          ),
          en,
        );
        return _pageTexts(bytes).join('\n');
      }

      expect(await textFor('Initial'), isNot(contains('AMENDED')));
      expect(await textFor('Initial'), isNot(contains('ADDENDED')));
      expect(
        await textFor('Amended'),
        contains(en.reportPdfStageAmended.toUpperCase()),
      );
      expect(
        await textFor('Amended'),
        contains(en.reportPdfSupersedesReason(1, 'Fixed.')),
      );
      expect(
        await textFor('Addended'),
        contains(en.reportPdfStageAddended.toUpperCase()),
      );
    },
  );

  test('the critical banner shows only when isCritical', () async {
    Future<String> textFor({required bool critical}) async {
      final bytes = await builder.build(
        pdfInput(reportOverride: report.copyWith(isCritical: critical)),
        en,
      );
      return _pageTexts(bytes).join('\n');
    }

    expect(
      await textFor(critical: false),
      isNot(contains(en.reportPdfCritical)),
    );
    expect(await textFor(critical: true), contains(en.reportPdfCritical));
  });

  test('measurements show only when there are some', () async {
    Future<String> textFor({required bool some}) async {
      final bytes = await builder.build(
        pdfInput(
          reportOverride: report.copyWith(
            measurements: some ? report.measurements : const [],
          ),
        ),
        en,
      );
      return _pageTexts(bytes).join('\n');
    }

    final withSome = await textFor(some: true);
    expect(withSome, contains(en.reportPdfMeasurementsCaption));
    expect(withSome, contains('3 mm'));
    expect(
      await textFor(some: false),
      isNot(contains(en.reportPdfMeasurementsCaption)),
    );
  });

  test(
    'the translation follows the signed original with its attribution',
    () async {
      final bytes = await builder.build(
        pdfInput(
          translation: const ReportTextApprovedModel(
            sourceSha256: 'contenthash',
            approvedText: {
              'diagnosis': 'Translated diagnosis.',
              'comments': 'Translated comments.',
            },
            approverName: 'Path One',
            language: 'sw',
          ),
        ),
        en,
      );
      final text = _pageTexts(bytes).join('\n');
      final original = text.indexOf('Benign');
      final attribution = text.indexOf(en.reportPdfTranslationBy('Path One'));
      final translated = text.indexOf('Translated diagnosis.');
      expect(original, isNonNegative);
      expect(attribution, greaterThan(original));
      expect(translated, greaterThan(attribution));
    },
  );

  test('the pages carry no QR code or verify link', () async {
    final bytes = await builder.build(pdfInput(), en);
    final raw = latin1.decode(bytes);
    expect(raw, isNot(contains('/URI')));
    expect(raw, isNot(contains('/Annots')));
    expect(raw, isNot(contains('QRCode')));
  });

  test('section titles and question labels are localised', () async {
    final bytes = await builder.build(
      pdfInput(
        reportOverride: report.copyWith(
          responses: const [
            ReportResponseModel(
              section: 'Macroscopic',
              question: 'margins',
              answer: 'Clear.',
            ),
          ],
        ),
      ),
      en,
    );
    final text = _pageTexts(bytes).join('\n');
    expect(text, contains(en.reportSectionMacroscopic));
    expect(text, contains(en.reportQuestionMargins));
  });

  test('unknown keys fall back to the key itself', () async {
    final bytes = await builder.build(
      pdfInput(
        reportOverride: report.copyWith(
          responses: const [
            ReportResponseModel(
              section: 'Unknown',
              question: 'mystery',
              answer: 'Something.',
            ),
          ],
        ),
      ),
      en,
    );
    final text = _pageTexts(bytes).join('\n');
    expect(text, contains('Unknown'));
    expect(text, contains('mystery'));
  });

  test('a sw build localises the chrome', () async {
    final pages = _pageTexts(await builder.build(pdfInput(), sw));
    final text = pages.join('\n');
    expect(text, contains(sw.reportPdfTitle.toUpperCase()));
    expect(pages.first, contains(sw.reportPdfPage(1, pages.length)));
  });

  test('the signed block stays whole on one page', () async {
    final bytes = await builder.build(
      pdfInput(
        reportOverride: report.copyWith(responses: longResponses()),
        signature: signaturePng,
      ),
      en,
    );
    final pages = _pageTexts(bytes);
    final eyebrow = en.reportPdfSignedReport.toUpperCase();
    final signed = [for (final page in pages) page.contains(eyebrow)];
    expect(signed.where((hit) => hit), hasLength(1));
    final page = pages[signed.indexOf(true)];
    expect(page, contains(en.reportPdfConsultantLine('K-1')));
    expect(page, contains(en.reportPdfSignature));
  });

  test('a watermark prints on every page', () async {
    final bytes = await builder.build(
      pdfInput(
        reportOverride: report.copyWith(responses: longResponses()),
      ).copyWith(watermark: 'DRAFT'),
      en,
    );
    final pages = _pageTexts(bytes);
    expect(pages.length, greaterThan(2));
    for (final page in pages) {
      expect(page, contains('DRAFT'));
    }
  });

  test('dates render in Nairobi time with the age and reference', () async {
    final text = _pageTexts(
      await builder.build(
        pdfInput(
          reportOverride: report.copyWith(
            contentSha256: '12345678901234567890',
          ),
        ),
        en,
      ),
    ).join('\n');
    expect(text, contains('3 October 2026, 13:00'));
    expect(text, contains('1 October 2026, 11:00'));
    expect(text, contains(en.reportPdfAge(36, 9)));
    expect(text, contains(en.reportPdfContentRef('1234 5678 9012')));
  });
}
