// The arithmetic of the release automation (make release-check).

const test = require('node:test');
const assert = require('node:assert/strict');

const { TAG, latest, managedDraft, nextRelease, pubspecVersion } = require('./next-release.cjs');

const pubspec = (version) => `name: tabibu\nversion: ${version}\npublish_to: none\n`;

test('releases the pubspec version as a v-prefixed tag', () => {
  const next = nextRelease({ pubspec: pubspec('1.0.02+1002'), tags: [] });
  assert.deepEqual(next, { tag: 'v1.0.02+1002', previous: null });
});

test('notes start from the latest published tag', () => {
  const next = nextRelease({
    pubspec: pubspec('1.0.03+1003'),
    tags: ['v1.0.01+1001', 'v1.0.02+1002', ''],
  });
  assert.deepEqual(next, { tag: 'v1.0.03+1003', previous: 'v1.0.02+1002' });
});

test('refuses a pubspec that was not bumped past the latest release', () => {
  assert.throws(
    () => nextRelease({ pubspec: pubspec('1.0.02+1002'), tags: ['v1.0.02+1002'] }),
    /Bump it on the branch/,
  );
  assert.throws(
    () => nextRelease({ pubspec: pubspec('1.0.01+1001'), tags: ['v1.0.02+1002'] }),
    /not past the latest release/,
  );
});

test('refuses a two-digit minor, which would let the build number fall', () => {
  assert.throws(() => pubspecVersion(pubspec('1.10.00+11000')), /minor must be 0 to 9/);
});

test('refuses a build that is not the version without its dots', () => {
  assert.throws(() => pubspecVersion(pubspec('1.0.02+1003')), /build must be/);
});

test('refuses an unpadded patch', () => {
  assert.throws(() => pubspecVersion(pubspec('1.0.2+102')), /not `a.b.cd\+build`/);
});

test('refuses a pubspec without a version', () => {
  assert.throws(() => pubspecVersion('name: tabibu\n'), /no `version:` line/);
});

test('orders numerically, not lexically', () => {
  assert.equal(latest(['v1.0.09+1009', 'v1.0.10+1010', 'v1.0.02+1002']).tag, 'v1.0.10+1010');
  assert.equal(latest(['v1.9.99+1999', 'v2.0.01+2001']).tag, 'v2.0.01+2001');
});

test('ignores anything that is not a version tag', () => {
  assert.equal(latest(['nightly', 'release-candidate', 'v1.0.02+1002']).tag, 'v1.0.02+1002');
  assert.equal(latest(['nightly']), null);
});

test('every tag it produces is one it can read back', () => {
  for (const version of ['1.0.02+1002', '1.0.10+1010', '2.3.99+2399']) {
    assert.ok(TAG.test(nextRelease({ pubspec: pubspec(version), tags: [] }).tag));
  }
});

test('finds the draft whose tag follows the convention', () => {
  assert.equal(
    managedDraft([
      { tagName: 'v1.0.02+1002', isDraft: false },
      { tagName: 'v1.0.03+1003', isDraft: true },
    ]),
    'v1.0.03+1003',
  );
});

test('ignores a draft somebody opened for something else', () => {
  assert.equal(managedDraft([{ tagName: 'demo-build', isDraft: true }]), null);
});

test('never adopts a published release', () => {
  assert.equal(managedDraft([{ tagName: 'v1.0.02+1002', isDraft: false }]), null);
});

test('refuses to choose between two drafts it could equally own', () => {
  assert.throws(
    () =>
      managedDraft([
        { tagName: 'v1.0.03+1003', isDraft: true },
        { tagName: 'v1.0.04+1004', isDraft: true },
      ]),
    /Publish or delete all but one/,
  );
});

test('an empty repository has no managed draft', () => {
  assert.equal(managedDraft([]), null);
});

test('the real pubspec follows the convention', () => {
  const fs = require('node:fs');
  const path = require('node:path');
  pubspecVersion(fs.readFileSync(path.join(__dirname, '..', 'pubspec.yaml'), 'utf8'));
});
