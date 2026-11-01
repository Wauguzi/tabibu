/**
 * Bounds and cleans free text before it is stored or sent to a model (R-6).
 * Over-long text that will be signed is refused, never silently cut.
 */
import { refuse } from './common';

/** C0 (except tab/newline), C1, bidi overrides, zero-width, line/paragraph separators. */
const INVISIBLE =
  /[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F-\u009F\u200B-\u200D\u202A-\u202E\u2066-\u2069\uFEFF\u2028\u2029]/gu;

/**
 * Strip invisible / bidi controls, normalise newlines, NFC.
 * Refuses when the result exceeds [maxLen] (`invalidText`).
 */
export function sanitize(raw: string, maxLen: number): string {
  const normalised = raw.normalize('NFC').replace(/\r\n/g, '\n').replace(/\r/g, '\n');
  const cleaned = normalised.replace(INVISIBLE, '');
  const lines = cleaned.split('\n').map((line) => line.replace(/ {2,}/g, ' ').trimEnd());
  const text = lines.join('\n').trim();
  if ([...text].length > maxLen) throw refuse('invalid-argument', 'invalidText');
  return text;
}
