// cspell:ignore linecap linejoin
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/models/report_pdf_input.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Builds the signed-report PDF (05-plan §8 step 1j) from [ReportPdfInput].
/// Layout follows the approved mock-up; all sizes below are CSS px from it,
/// converted at 1 px = 0.75 pt. Returns bytes only: nothing is logged or
/// written to disk.
@lazySingleton
class ReportPdfBuilder {
  ReportPdfBuilder({
    @ignoreParam Future<ByteData> Function(String assetKey)? assetLoader,
    @ignoreParam this.compress = true,
  }) : _assetLoader = assetLoader ?? rootBundle.load;

  final Future<ByteData> Function(String assetKey) _assetLoader;

  /// False leaves content streams uncompressed so tests can read the text.
  final bool compress;

  static const _regularAsset = 'fonts/Manrope-Regular.ttf';
  static const _semiBoldAsset = 'fonts/Manrope-SemiBold.ttf';
  static const _boldAsset = 'fonts/Manrope-Bold.ttf';
  static const _extraBoldAsset = 'fonts/Manrope-ExtraBold.ttf';

  // AppColors light tokens only; no new hex values.
  static final _ink = PdfColor.fromInt(AppColors.inkLight.toARGB32());
  static final _primary = PdfColor.fromInt(AppColors.primaryLight.toARGB32());
  static final _primaryText = PdfColor.fromInt(
    AppColors.primaryTextLight.toARGB32(),
  );
  static final _mint = PdfColor.fromInt(AppColors.mintLight.toARGB32());
  static final _outlineVariant = PdfColor.fromInt(
    AppColors.outlineVariantLight.toARGB32(),
  );
  static final _onSurfaceVariant = PdfColor.fromInt(
    AppColors.onSurfaceVariantLight.toARGB32(),
  );
  static final _surfaceLow = PdfColor.fromInt(
    AppColors.surfaceLowLight.toARGB32(),
  );
  static final _error = PdfColor.fromInt(AppColors.errorLight.toARGB32());
  static final _errorContainer = PdfColor.fromInt(
    AppColors.errorContainerLight.toARGB32(),
  );
  static final _white = PdfColor.fromInt(
    AppColors.surfaceLowestLight.toARGB32(),
  );

  // The mock's warning mark. #B3261E is errorLight; SVG markup cannot
  // reference tokens.
  static const _warningSvg =
      '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" '
      'stroke="#B3261E" stroke-width="2.2" stroke-linecap="round" '
      'stroke-linejoin="round"><path d="M12 9v4M12 17h.01"/> '
      '<path d="M10.3 3.9 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 '
      '3.9a2 2 0 0 0-3.4 0z"/></svg>';

  static const _dot = ' · ';

  pw.Font? _regular;
  pw.Font? _semiBold;
  pw.Font? _bold;
  pw.Font? _extraBold;
  String? _logoSvg;

  Future<Uint8List> build(ReportPdfInput input, AppLocalizations l10n) async {
    final fonts = await _fonts();
    final logo = await _logo();
    final doc = pw.Document(compress: compress);
    final page = _Page(input: input, l10n: l10n, fonts: fonts, logoSvg: logo);
    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(54, 30, 54, 27),
          theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
          // Full-bleed, so the bar sits at the paper's edge above the header.
          buildBackground: (_) =>
              pw.FullPage(ignoreMargins: true, child: page.background()),
        ),
        header: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 15),
          child: context.pageNumber == 1
              ? page.fullHeader()
              : page.compactHeader(),
        ),
        footer: page.footer,
        build: (_) => page.body(),
      ),
    );
    return await doc.save();
  }

  Future<_Fonts> _fonts() async {
    final regular = _regular ??= await _loadFont(_regularAsset);
    final semiBold = _semiBold ??= await _loadFont(_semiBoldAsset);
    final bold = _bold ??= await _loadFont(_boldAsset);
    final extraBold = _extraBold ??= await _loadFont(_extraBoldAsset);
    return _Fonts(
      regular: regular,
      semiBold: semiBold,
      bold: bold,
      extraBold: extraBold,
    );
  }

  Future<pw.Font> _loadFont(String asset) async {
    final data = await _assetLoader(asset);
    // Font.ttf reads the whole buffer, so copy the view into an exact one.
    final bytes = Uint8List.fromList(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    return pw.Font.ttf(bytes.buffer.asByteData());
  }

  Future<String> _logo() async {
    final cached = _logoSvg;
    if (cached != null) return cached;
    final data = await _assetLoader(Assets.icons.logoTransparentPrimary.path);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    return _logoSvg = utf8.decode(bytes);
  }
}

class _Fonts {
  const _Fonts({
    required this.regular,
    required this.semiBold,
    required this.bold,
    required this.extraBold,
  });

  final pw.Font regular;
  final pw.Font semiBold;
  final pw.Font bold;
  final pw.Font extraBold;
}

/// One report render: the input, its strings, and the loaded assets.
class _Page {
  _Page({
    required this.input,
    required this.l10n,
    required this.fonts,
    required this.logoSvg,
  });

  final ReportPdfInput input;
  final AppLocalizations l10n;
  final _Fonts fonts;
  final String logoSvg;

  String get _missing => l10n.reportPdfMissingValue;

  String _orMissing(String value) => value.isEmpty ? _missing : value;

  // -- Localisation of the input's wire keys. Unknown keys fall back to
  // the key itself, never to an empty label. (The enums' fromValue
  // fallbacks guess a variant, so the lookup below is explicit.)

  String _sectionLabel(String key) {
    for (final section in ReportSection.values) {
      if (section.value == key) return section.description(l10n);
    }
    return key;
  }

  String _questionLabel(String key) => switch (key) {
    'specimenDescription' => l10n.reportQuestionSpecimenDescription,
    'specimenSize' => l10n.reportQuestionSpecimenSize,
    'representativeSections' => l10n.reportQuestionRepresentativeSections,
    'microscopicDescription' => l10n.reportQuestionMicroscopicDescription,
    'tumourGrade' => l10n.reportQuestionTumourGrade,
    'margins' => l10n.reportQuestionMargins,
    'lymphNodes' => l10n.reportQuestionLymphNodes,
    'immunohistochemistry' => l10n.reportQuestionImmunohistochemistry,
    'parasiteSpecies' => l10n.reportQuestionParasiteSpecies,
    'parasiteDensity' => l10n.reportQuestionParasiteDensity,
    'parasiteStages' => l10n.reportQuestionParasiteStages,
    'rapidTestResult' => l10n.reportQuestionRapidTestResult,
    'findings' => l10n.reportQuestionFindings,
    'methodNotes' => l10n.reportQuestionMethodNotes,
    _ => key,
  };

  // Cases mirror DiagnosisType wire values.
  String _diagnosisTypeLabel(String key) => switch (key) {
    'Final' => l10n.reportPdfDiagnosisTypeFinal,
    'Provisional' => l10n.reportPdfDiagnosisTypeProvisional,
    'Inconclusive' => l10n.reportPdfDiagnosisTypeInconclusive,
    _ => key,
  };

  // Cases mirror ReportTemplate wire values.
  String _templateLabel(String key) => switch (key) {
    'Cancer' => l10n.reportPdfTemplateCancer,
    'Malaria' => l10n.reportPdfTemplateMalaria,
    'General' => l10n.reportPdfTemplateGeneral,
    _ => key,
  };

  String _segmentLabel(String key) {
    for (final section in ReportSection.values) {
      if (section.value == key) return section.description(l10n);
    }
    return _questionLabel(key);
  }

  String _languageName(String key) {
    if (key == ReportLanguage.sw.value) return l10n.languageSw;
    if (key == ReportLanguage.en.value) return l10n.languageEn;
    return key;
  }

  // -- Dates, age, content reference.

  /// An ISO timestamp in Nairobi time (EAT is UTC+3 with no daylight
  /// saving). Naive timestamps read as UTC; empty or invalid reads
  /// as the missing value.
  String _nairobiDate(String iso) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return _missing;
    final utc = parsed.isUtc
        ? parsed
        : DateTime.utc(
            parsed.year,
            parsed.month,
            parsed.day,
            parsed.hour,
            parsed.minute,
            parsed.second,
            parsed.millisecond,
            parsed.microsecond,
          );
    final eat = utc.add(const Duration(hours: 3));
    return DateFormat('d MMMM y, HH:mm', l10n.localeName).format(eat);
  }

  String _age() {
    final years = input.subject.ageYears;
    if (years < 0) return _missing;
    return l10n.reportPdfAge(years, input.subject.ageMonths);
  }

  /// The first 12 hex digits in groups of 4, upper case.
  String _contentRef() {
    final hash = input.signature.contentRef;
    if (hash.isEmpty) return _missing;
    final head = hash.toUpperCase().substring(0, min(12, hash.length));
    final groups = [
      for (var i = 0; i < head.length; i += 4)
        head.substring(i, min(i + 4, head.length)),
    ];
    return groups.join(' ');
  }

  // -- Shared pieces.

  pw.Widget _rule([PdfColor? color]) => pw.Container(
    height: 0.75,
    color: color ?? ReportPdfBuilder._outlineVariant,
  );

  pw.TextStyle _eyebrow(PdfColor color) => pw.TextStyle(
    font: fonts.extraBold,
    fontSize: 9,
    color: color,
    letterSpacing: 0.54,
  );

  /// Label/value rows; the table breaks between rows, never through one.
  pw.Widget _rows(
    List<(String, String)> rows, {
    required double labelWidth,
    double size = 10.5,
    pw.Font? labelFont,
    pw.Font? valueFont,
    double rowGap = 7.5,
  }) {
    return pw.Table(
      columnWidths: {
        0: pw.FixedColumnWidth(labelWidth),
        1: const pw.FlexColumnWidth(),
      },
      children: [
        for (final row in rows)
          pw.TableRow(
            children: [
              pw.Padding(
                padding: pw.EdgeInsets.only(right: 12, bottom: rowGap),
                child: pw.Text(
                  row.$1,
                  style: pw.TextStyle(
                    font: labelFont ?? fonts.semiBold,
                    fontSize: size,
                    height: 1.5,
                    color: ReportPdfBuilder._onSurfaceVariant,
                  ),
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.only(bottom: rowGap),
                child: pw.Text(
                  row.$2,
                  style: pw.TextStyle(
                    font: valueFont ?? fonts.regular,
                    fontSize: size,
                    height: 1.5,
                    color: ReportPdfBuilder._ink,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // -- Page chrome: background, headers, footer.

  pw.Widget background() {
    return pw.Container(
      width: double.infinity,
      height: double.infinity,
      child: pw.Stack(
        children: [
          pw.Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: pw.Container(height: 6, color: ReportPdfBuilder._primary),
          ),
          if (input.watermark.isNotEmpty)
            pw.Center(
              child: pw.Transform.rotate(
                angle: -0.55,
                child: pw.Text(
                  input.watermark,
                  style: pw.TextStyle(
                    font: fonts.extraBold,
                    fontSize: 64,
                    color: ReportPdfBuilder._outlineVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget fullHeader() {
    final header = input.header;
    return pw.Row(
      mainAxisAlignment: .spaceBetween,
      crossAxisAlignment: .start,
      children: [
        pw.Row(
          children: [
            pw.SvgImage(svg: logoSvg, width: 27, height: 27),
            pw.SizedBox(width: 9),
            pw.Column(
              crossAxisAlignment: .start,
              children: [
                pw.Text(
                  'Tabibu',
                  style: pw.TextStyle(
                    font: fonts.extraBold,
                    fontSize: 16.5,
                    height: 1,
                    color: ReportPdfBuilder._ink,
                  ),
                ),
                pw.SizedBox(height: 1.5),
                pw.Text(
                  l10n.reportPdfTitle.toUpperCase(),
                  style: _eyebrow(ReportPdfBuilder._onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: .end,
          children: [
            pw.Text(
              l10n.reportPdfOrderNumber.toUpperCase(),
              style: pw.TextStyle(
                font: fonts.semiBold,
                fontSize: 9,
                color: ReportPdfBuilder._onSurfaceVariant,
                letterSpacing: 0.54,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              _orMissing(header.orderNumber),
              style: pw.TextStyle(
                font: fonts.bold,
                fontSize: 12,
                color: ReportPdfBuilder._ink,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              l10n.reportPdfVersionReleased(
                header.version,
                _nairobiDate(header.releasedAtLabel),
              ),
              style: pw.TextStyle(
                font: fonts.regular,
                fontSize: 9,
                color: ReportPdfBuilder._onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget compactHeader() {
    final header = input.header;
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            pw.Row(
              children: [
                pw.SvgImage(svg: logoSvg, width: 18, height: 18),
                pw.SizedBox(width: 7.5),
                pw.Text(
                  'Tabibu',
                  style: pw.TextStyle(
                    font: fonts.extraBold,
                    fontSize: 11.25,
                    color: ReportPdfBuilder._ink,
                  ),
                ),
                pw.SizedBox(width: 7.5),
                pw.Text(
                  l10n.reportPdfTitle,
                  style: pw.TextStyle(
                    font: fonts.regular,
                    fontSize: 9,
                    color: ReportPdfBuilder._onSurfaceVariant,
                  ),
                ),
              ],
            ),
            pw.Text(
              l10n.reportPdfCompactTitle(
                _orMissing(header.orderNumber),
                header.version,
              ),
              style: pw.TextStyle(
                font: fonts.bold,
                fontSize: 9.75,
                color: ReportPdfBuilder._ink,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 9),
        _rule(),
      ],
    );
  }

  pw.Widget footer(pw.Context context) {
    final footer = input.footer;
    final labNo = _orMissing(footer.labAccessionNo);
    final accession =
        '${ReportPdfBuilder._dot}${l10n.reportPdfAccession(labNo)}';
    return pw.Column(
      crossAxisAlignment: .start,
      children: [
        _rule(),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            pw.Expanded(
              child: pw.RichText(
                text: pw.TextSpan(
                  style: pw.TextStyle(
                    font: fonts.regular,
                    fontSize: 9,
                    color: ReportPdfBuilder._onSurfaceVariant,
                  ),
                  children: [
                    pw.TextSpan(
                      text: _orMissing(footer.patientName),
                      style: pw.TextStyle(
                        font: fonts.bold,
                        color: ReportPdfBuilder._ink,
                      ),
                    ),
                    pw.TextSpan(text: accession),
                  ],
                ),
              ),
            ),
            pw.Text(
              l10n.reportPdfPage(context.pageNumber, context.pagesCount),
              style: pw.TextStyle(
                font: fonts.bold,
                fontSize: 9,
                color: ReportPdfBuilder._ink,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          l10n.reportPdfDisclaimer(_orMissing(footer.supportContact)),
          style: pw.TextStyle(
            font: fonts.regular,
            fontSize: 9,
            height: 1.45,
            color: ReportPdfBuilder._onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // -- Body blocks, in mock order.

  pw.Widget _gap() => pw.SizedBox(height: 15);

  List<pw.Widget> body() {
    final blocks = <pw.Widget>[];
    void add(pw.Widget child) {
      if (blocks.isNotEmpty) blocks.add(_gap());
      blocks.add(child);
    }

    final stage = _stageBanner();
    if (stage != null) add(stage);
    if (input.isCritical) add(_criticalBanner());
    add(_titleBlock());
    add(_cards());
    // The input builds Diagnosis, Comments, Clinical notes first, then the
    // template sections in template order.
    if (input.blocks.isNotEmpty) add(_diagnosisPanel(input.blocks[0]));
    if (input.blocks.length > 1) add(_proseBlock(input.blocks[1]));
    if (input.blocks.length > 2) add(_proseBlock(input.blocks[2]));
    var number = 0;
    for (final block in input.blocks.skip(3)) {
      add(_templateSection(++number, block));
    }
    if (input.measurements.isNotEmpty) add(_measurementsBlock());
    for (final addendum in input.addenda) {
      add(_addendumCard(addendum));
    }
    if (input.translation.isNotEmpty) add(_translationBlock());
    add(_signedBlock());
    add(_endOfReport());
    return blocks;
  }

  pw.Widget? _stageBanner() {
    final stage = input.header.stage;
    final label = stage == ReportStage.amended.value
        ? l10n.reportPdfStageAmended
        : stage == ReportStage.addended.value
        ? l10n.reportPdfStageAddended
        : null;
    if (label == null) return null;
    final reason = input.amendmentReason;
    final body = reason.isEmpty
        ? l10n.reportPdfSupersedes(input.header.version - 1)
        : l10n.reportPdfSupersedesReason(input.header.version - 1, reason);
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        color: ReportPdfBuilder._surfaceLow,
        border: pw.Border.all(
          color: ReportPdfBuilder._onSurfaceVariant,
          width: 0.75,
        ),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      padding: const pw.EdgeInsets.fromLTRB(10.5, 7.5, 10.5, 7.5),
      child: pw.Row(
        crossAxisAlignment: .start,
        children: [
          pw.Text(label.toUpperCase(), style: _eyebrow(ReportPdfBuilder._ink)),
          pw.SizedBox(width: 9),
          pw.Expanded(
            child: pw.Text(
              body,
              style: pw.TextStyle(
                font: fonts.regular,
                fontSize: 9.75,
                color: ReportPdfBuilder._onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _criticalBanner() {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        color: ReportPdfBuilder._errorContainer,
        border: pw.Border.all(color: ReportPdfBuilder._error, width: 0.75),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      padding: const pw.EdgeInsets.fromLTRB(10.5, 7.5, 10.5, 7.5),
      child: pw.Row(
        children: [
          pw.SvgImage(
            svg: ReportPdfBuilder._warningSvg,
            width: 13.5,
            height: 13.5,
          ),
          pw.SizedBox(width: 9),
          pw.Expanded(
            child: pw.Text(
              l10n.reportPdfCritical,
              style: pw.TextStyle(
                font: fonts.bold,
                fontSize: 9.75,
                color: ReportPdfBuilder._error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _titleBlock() {
    final header = input.header;
    final template = _templateLabel(header.templateLabel);
    final reportedBy = l10n.reportPdfReportedBy(
      _orMissing(header.signedByFacilityName),
    );
    return pw.Column(
      crossAxisAlignment: .start,
      children: [
        pw.Text(
          _orMissing(header.testName),
          style: pw.TextStyle(
            font: fonts.extraBold,
            fontSize: 19.5,
            height: 1.2,
            color: ReportPdfBuilder._ink,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          template.isEmpty
              ? reportedBy
              : '$template${ReportPdfBuilder._dot}$reportedBy',
          style: pw.TextStyle(
            font: fonts.regular,
            fontSize: 9.75,
            color: ReportPdfBuilder._onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _sex() {
    final sex = Sex.fromValue(input.subject.sex);
    if (sex != null) return sex.description(l10n);
    return _orMissing(input.subject.sex);
  }

  pw.Widget _cards() {
    final subject = input.subject;
    final header = input.header;
    return pw.Row(
      crossAxisAlignment: .start,
      children: [
        pw.Expanded(
          child: _card(l10n.reportPdfPatient, [
            (l10n.reportPdfName, _orMissing(subject.displayName)),
            (l10n.reportPdfAgeLabel, _age()),
            (l10n.reportPdfSex, _sex()),
            (l10n.reportPdfResidence, _orMissing(subject.residence)),
          ], 72),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: _card(l10n.reportPdfRequest, [
            (l10n.reportPdfRequestedBy, _orMissing(header.doctorName)),
            (l10n.reportPdfFacility, _orMissing(header.doctorFacilityName)),
            (l10n.reportPdfCollected, _nairobiDate(header.sampleCollectedAt)),
            (l10n.reportPdfReceived, _nairobiDate(header.sampleReceivedAt)),
            (l10n.reportPdfAccessionNo, _orMissing(header.labAccessionNo)),
          ], 84),
        ),
      ],
    );
  }

  pw.Widget _card(
    String title,
    List<(String, String)> rows,
    double labelWidth,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: ReportPdfBuilder._outlineVariant,
          width: 0.75,
        ),
        borderRadius: pw.BorderRadius.circular(9),
      ),
      padding: const pw.EdgeInsets.fromLTRB(12, 10.5, 12, 10.5),
      child: pw.Column(
        crossAxisAlignment: .start,
        children: [
          pw.Text(
            title.toUpperCase(),
            style: _eyebrow(ReportPdfBuilder._primaryText),
          ),
          pw.SizedBox(height: 4.5),
          _rows(
            rows,
            labelWidth: labelWidth,
            size: 9.75,
            labelFont: fonts.regular,
            valueFont: fonts.semiBold,
            rowGap: 4.5,
          ),
        ],
      ),
    );
  }

  pw.Widget _diagnosisPanel(PdfBlock block) {
    final title = _sectionLabel(block.sectionKey);
    final type = block.lines.isEmpty
        ? ''
        : _diagnosisTypeLabel(block.lines.first.label);
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        color: ReportPdfBuilder._mint,
        borderRadius: pw.BorderRadius.circular(9),
      ),
      padding: const pw.EdgeInsets.fromLTRB(13.5, 12, 13.5, 12),
      child: pw.Column(
        crossAxisAlignment: .start,
        children: [
          pw.Text(
            (type.isEmpty ? title : '$title${ReportPdfBuilder._dot}$type')
                .toUpperCase(),
            style: _eyebrow(ReportPdfBuilder._primaryText),
          ),
          pw.SizedBox(height: 4.5),
          pw.Text(
            [for (final line in block.lines) line.value].join('\n'),
            style: pw.TextStyle(
              font: fonts.bold,
              fontSize: 12.75,
              height: 1.45,
              color: ReportPdfBuilder._ink,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _proseBlock(PdfBlock block) {
    return pw.Column(
      crossAxisAlignment: .start,
      children: [
        pw.Text(
          _sectionLabel(block.sectionKey),
          style: pw.TextStyle(
            font: fonts.extraBold,
            fontSize: 11.25,
            color: ReportPdfBuilder._ink,
          ),
        ),
        pw.SizedBox(height: 4.5),
        pw.Text(
          [for (final line in block.lines) line.value].join('\n'),
          style: pw.TextStyle(
            font: fonts.regular,
            fontSize: 10.5,
            height: 1.55,
            color: ReportPdfBuilder._ink,
          ),
        ),
      ],
    );
  }

  pw.Widget _templateSection(int number, PdfBlock block) {
    return pw.Column(
      crossAxisAlignment: .start,
      children: [
        pw.Row(
          children: [
            pw.Container(
              decoration: pw.BoxDecoration(
                color: ReportPdfBuilder._primary,
                borderRadius: pw.BorderRadius.circular(4.5),
              ),
              padding: const pw.EdgeInsets.fromLTRB(6, 1.5, 6, 1.5),
              child: pw.Text(
                '$number',
                style: pw.TextStyle(
                  font: fonts.extraBold,
                  fontSize: 9,
                  color: ReportPdfBuilder._white,
                ),
              ),
            ),
            pw.SizedBox(width: 7.5),
            pw.Expanded(
              child: pw.Text(
                _sectionLabel(block.sectionKey),
                style: pw.TextStyle(
                  font: fonts.extraBold,
                  fontSize: 11.25,
                  color: ReportPdfBuilder._ink,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        _rule(),
        pw.SizedBox(height: 7.5),
        _rows([
          for (final line in block.lines)
            (_questionLabel(line.label), _orMissing(line.value)),
        ], labelWidth: 150),
      ],
    );
  }

  pw.Widget _measureCell(
    String text, {
    required pw.Font font,
    required pw.TextAlign align,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.fromLTRB(9, 6, 9, 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: font,
          fontSize: 9.75,
          color: ReportPdfBuilder._ink,
        ),
      ),
    );
  }

  pw.Widget _measurementsBlock() {
    return pw.Column(
      crossAxisAlignment: .start,
      children: [
        pw.Text(
          l10n.reportPdfMeasurements,
          style: pw.TextStyle(
            font: fonts.extraBold,
            fontSize: 11.25,
            color: ReportPdfBuilder._ink,
          ),
        ),
        pw.SizedBox(height: 7.5),
        pw.Table(
          border: pw.TableBorder.all(
            color: ReportPdfBuilder._outlineVariant,
            width: 0.75,
          ),
          columnWidths: const {
            0: pw.FlexColumnWidth(),
            1: pw.FlexColumnWidth(),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: ReportPdfBuilder._surfaceLow),
              repeat: true,
              children: [
                _measureCell(
                  l10n.reportPdfMeasure,
                  font: fonts.bold,
                  align: .left,
                ),
                _measureCell(
                  l10n.reportPdfValue,
                  font: fonts.bold,
                  align: .right,
                ),
              ],
            ),
            for (final measurement in input.measurements)
              pw.TableRow(
                children: [
                  _measureCell(
                    _orMissing(measurement.key),
                    font: fonts.regular,
                    align: .left,
                  ),
                  _measureCell(
                    _orMissing(measurement.value),
                    font: fonts.regular,
                    align: .right,
                  ),
                ],
              ),
          ],
        ),
        pw.SizedBox(height: 7.5),
        pw.Text(
          l10n.reportPdfMeasurementsCaption,
          style: pw.TextStyle(
            font: fonts.regular,
            fontSize: 9,
            color: ReportPdfBuilder._onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  pw.Widget _addendumCard(PdfAddendum addendum) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: ReportPdfBuilder._outlineVariant,
          width: 0.75,
        ),
        borderRadius: pw.BorderRadius.circular(9),
      ),
      padding: const pw.EdgeInsets.fromLTRB(12, 10.5, 12, 10.5),
      child: pw.Column(
        crossAxisAlignment: .start,
        children: [
          pw.Text(
            l10n.reportPdfAddendum(_nairobiDate(addendum.signedAt)),
            style: pw.TextStyle(
              font: fonts.extraBold,
              fontSize: 11.25,
              color: ReportPdfBuilder._ink,
            ),
          ),
          pw.SizedBox(height: 4.5),
          pw.Text(
            addendum.text,
            style: pw.TextStyle(
              font: fonts.regular,
              fontSize: 10.5,
              height: 1.55,
              color: ReportPdfBuilder._ink,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _translationBlock() {
    return pw.Column(
      crossAxisAlignment: .start,
      children: [
        pw.Text(
          '${l10n.reportPdfTranslation}${ReportPdfBuilder._dot}'
                  '${_languageName(input.translationLanguage)}'
              .toUpperCase(),
          style: _eyebrow(ReportPdfBuilder._primaryText),
        ),
        pw.SizedBox(height: 4.5),
        pw.Text(
          l10n.reportPdfTranslationBy(
            _orMissing(input.translationApproverName),
          ),
          style: pw.TextStyle(
            font: fonts.extraBold,
            fontSize: 11.25,
            color: ReportPdfBuilder._ink,
          ),
        ),
        pw.SizedBox(height: 7.5),
        _rows([
          for (final segment in input.translation.entries)
            (_segmentLabel(segment.key), _orMissing(segment.value)),
        ], labelWidth: 150),
      ],
    );
  }

  pw.Widget _signedBlock() {
    final signature = input.signature;
    final name = [
      signature.title,
      signature.name,
    ].where((part) => part.isNotEmpty).join(' ');
    return pw.Inseparable(
      child: pw.Container(
        width: double.infinity,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: ReportPdfBuilder._primary, width: 0.75),
          borderRadius: pw.BorderRadius.circular(10.5),
        ),
        padding: const pw.EdgeInsets.fromLTRB(15, 13.5, 15, 13.5),
        child: pw.Row(
          crossAxisAlignment: .end,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: .start,
                children: [
                  pw.Text(
                    l10n.reportPdfSignedReport.toUpperCase(),
                    style: _eyebrow(ReportPdfBuilder._primaryText),
                  ),
                  pw.SizedBox(height: 4.5),
                  pw.Text(
                    _orMissing(name),
                    style: pw.TextStyle(
                      font: fonts.extraBold,
                      fontSize: 12.75,
                      color: ReportPdfBuilder._ink,
                    ),
                  ),
                  pw.SizedBox(height: 4.5),
                  pw.Text(
                    l10n.reportPdfConsultantLine(
                      _orMissing(signature.kmpdcNumber),
                    ),
                    style: pw.TextStyle(
                      font: fonts.regular,
                      fontSize: 9.75,
                      color: ReportPdfBuilder._onSurfaceVariant,
                    ),
                  ),
                  pw.SizedBox(height: 4.5),
                  pw.Text(
                    l10n.reportPdfSignedAt(
                      _nairobiDate(signature.signedAtLabel),
                    ),
                    style: pw.TextStyle(
                      font: fonts.regular,
                      fontSize: 9.75,
                      color: ReportPdfBuilder._onSurfaceVariant,
                    ),
                  ),
                  pw.SizedBox(height: 4.5),
                  pw.Text(
                    l10n.reportPdfContentRef(_contentRef()),
                    style: pw.TextStyle(
                      font: fonts.regular,
                      fontSize: 9,
                      color: ReportPdfBuilder._onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 15),
            pw.SizedBox(
              width: 165,
              child: pw.Column(
                children: [
                  _signatureBox(),
                  pw.SizedBox(height: 4.5),
                  _rule(ReportPdfBuilder._ink),
                  pw.SizedBox(height: 4.5),
                  pw.Text(
                    l10n.reportPdfSignature,
                    style: pw.TextStyle(
                      font: fonts.regular,
                      fontSize: 9,
                      color: ReportPdfBuilder._onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _signatureBox() {
    if (input.signature.png.isEmpty) {
      return pw.Container(
        height: 54,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(
            color: ReportPdfBuilder._outlineVariant,
            width: 0.75,
            style: .dashed,
          ),
          borderRadius: pw.BorderRadius.circular(6),
        ),
      );
    }
    return pw.SizedBox(
      height: 54,
      child: pw.Image(pw.MemoryImage(Uint8List.fromList(input.signature.png))),
    );
  }

  pw.Widget _endOfReport() {
    return pw.Center(
      child: pw.Text(
        l10n.reportPdfEndOfReport.toUpperCase(),
        style: pw.TextStyle(
          font: fonts.bold,
          fontSize: 9,
          color: ReportPdfBuilder._onSurfaceVariant,
          letterSpacing: 0.54,
        ),
      ),
    );
  }
}
