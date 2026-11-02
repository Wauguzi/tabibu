import assert from 'node:assert/strict';

import { sanitize } from './sanitize';

describe('sanitize', () => {
  it('strips control, bidi and zero-width characters', () => {
    const raw = `hello\u0000\u200B\u202Eworld\u0081`;
    const out = sanitize(raw, 100);
    assert.equal(out.includes('\u0000'), false);
    assert.equal(out.includes('\u200B'), false);
    assert.equal(out.includes('\u202E'), false);
    assert.equal(out.includes('\u0081'), false);
    assert.ok(out.includes('helloworld') || out.includes('hello'));
  });

  it('keeps newlines and tabs', () => {
    assert.equal(sanitize('a\tb\nc', 100), 'a\tb\nc');
  });

  it('refuses over-long text', () => {
    assert.throws(() => sanitize('x'.repeat(20), 10), (e: Error) => e.message === 'invalidText');
  });
});
