import assert from 'node:assert/strict';

import * as fns from './index';

interface ManifestEndpoint {
  timeoutSeconds?: number;
  secretEnvironmentVariables?: { key: string }[];
}

function endpointOf(fn: unknown): ManifestEndpoint {
  return (fn as { __endpoint?: ManifestEndpoint }).__endpoint ?? {};
}

function secretsOf(fn: unknown): string[] {
  return (endpointOf(fn).secretEnvironmentVariables ?? []).map((s) => s.key).sort();
}

describe('index secret bindings (bundle 86)', () => {
  it('binds META_API_KEY on the two speech paths', () => {
    assert.deepEqual(secretsOf(fns.transcribeSymptoms), ['META_API_KEY']);
    assert.deepEqual(secretsOf(fns.onMessageCreated), ['META_API_KEY']);
  });

  it('binds META_API_KEY on exactly the functions that call the model', () => {
    const bound: string[] = [];
    for (const [name, fn] of Object.entries(fns)) {
      if (secretsOf(fn).includes('META_API_KEY')) bound.push(name);
    }
    assert.deepEqual(bound.sort(), [
      'onAlertWritten',
      'onAppointmentWritten',
      'onCaseWritten',
      'onMessageCreated',
      'onPrereadWritten',
      'onReportTextWritten',
      'transcribeSymptoms',
    ]);
  });

  it('keeps the longer timeout on the two speech paths', () => {
    assert.equal(endpointOf(fns.transcribeSymptoms).timeoutSeconds, 120);
    assert.equal(endpointOf(fns.onMessageCreated).timeoutSeconds, 120);
  });
});
