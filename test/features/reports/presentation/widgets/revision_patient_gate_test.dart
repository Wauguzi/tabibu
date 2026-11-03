import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Bundle 68 risk map: the patient still only sees a report after
/// `releasedToPatient`. This bundle does not change those screens; assert
/// the gate is still present where the patient reads results.
void main() {
  test('patient report reads still gate on releasedToPatient', () {
    const paths = [
      'lib/features/reports/data/datasources/report_firebase.dart',
      'lib/features/reports/blocs/report_reader_bloc/report_reader_bloc.dart',
      'lib/features/reports/data/models/report_pdf_input.dart',
      'lib/features/reports/presentation/widgets/report_footer_notices.dart',
      'lib/features/reports/presentation/widgets/explanation_review_section.dart',
    ];
    for (final path in paths) {
      expect(
        File(path).readAsStringSync(),
        contains('releasedToPatient'),
        reason: '$path must still read releasedToPatient',
      );
    }
  });
}
