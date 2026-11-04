import 'package:tabibu/core/constants/enums.dart';

/// Deterministic id for `cases/{case}/reportTexts/{id}`. Mirrors the
/// server's `textId` in `functions/src/reports.ts`.
String reportTextId(String reportUid, ReportTextKind kind, String language) =>
    '${reportUid}_${kind.value}_$language';
