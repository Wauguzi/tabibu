/**
 * Expected demo-case stages for `check-demo` and the seed tests (bundle 67). Keep in sync with
 * the keys `seedCases` creates; a mismatch is a failed check, never a silent skip.
 */
export interface DemoCaseExpectation {
  key: string;
  stage: string;
  /** Minimum registered slides on the case document. */
  minSlides: number;
  /** Empty string means the accession must be blank (record-sample demo). */
  accession: 'any' | 'empty' | 'set';
  /** Ready = a stored Ready pre-read must exist; none = no preread docs; any = ignore. */
  preread: 'Ready' | 'Queued' | 'none' | 'any';
}

/** Every staged case the demo accounts should see after `make seed-cases`. */
export const DEMO_CASE_EXPECTATIONS: readonly DemoCaseExpectation[] = [
  { key: 'completed', stage: 'Completed', minSlides: 0, accession: 'any', preread: 'any' },
  { key: 'explained', stage: 'ResultReleased', minSlides: 0, accession: 'any', preread: 'any' },
  { key: 'cancelled', stage: 'Cancelled', minSlides: 0, accession: 'any', preread: 'none' },
  { key: 'signed', stage: 'ReportSigned', minSlides: 0, accession: 'set', preread: 'any' },
  { key: 'lowConfidence', stage: 'PrereadReady', minSlides: 1, accession: 'set', preread: 'Ready' },
  { key: 'blood', stage: 'ReportInProgress', minSlides: 0, accession: 'set', preread: 'none' },
  { key: 'hero', stage: 'PrereadReady', minSlides: 1, accession: 'set', preread: 'Ready' },
  { key: 'accepted', stage: 'PathologistAccepted', minSlides: 0, accession: 'empty', preread: 'none' },
  { key: 'malaria', stage: 'ReportSigned', minSlides: 1, accession: 'set', preread: 'Ready' },
  { key: 'requested', stage: 'PathologistRequested', minSlides: 0, accession: 'empty', preread: 'none' },
  { key: 'queued', stage: 'PrereadQueued', minSlides: 1, accession: 'empty', preread: 'Queued' },
  // Bundle 67 additions:
  { key: 'requestWithSlide', stage: 'PathologistRequested', minSlides: 1, accession: 'empty', preread: 'none' },
  { key: 'sampleDue', stage: 'PrereadReady', minSlides: 1, accession: 'empty', preread: 'Ready' },
  { key: 'rejected', stage: 'PathologistRejected', minSlides: 0, accession: 'empty', preread: 'none' },
];

export const DEMO_CASE_STAGES: Record<string, string> = Object.fromEntries(
  DEMO_CASE_EXPECTATIONS.map((e) => [e.key, e.stage]),
);
