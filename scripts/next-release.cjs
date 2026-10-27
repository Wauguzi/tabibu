// The tag a merge to main releases, and the draft this automation owns (CRQ-0025).
//
// The version is `pubspec.yaml`'s, bumped on every branch, so the tag is never typed: `1.0.02+1002`
// is released as `v1.0.02+1002`. The convention is `{major}.{minor}.{patch}+{build}` with the patch
// padded to two digits and the build derived from the version (`1` `0` `02` -> `1002`); a pubspec
// that breaks it, or that was not bumped past the latest release, stops the workflow rather than
// drafting a release that misnames its build.

/** A version tag, with or without its `v`. */
const TAG = /^[vV]?(\d+)\.(\d+)\.(\d+)(?:\+\d+)?$/;

/** What `pubspec.yaml` must hold: the convention exactly. */
const PUBSPEC_VERSION = /^(\d+)\.(\d+)\.(\d{2})\+(\d+)$/;

function parse(tag) {
  const match = TAG.exec(String(tag).trim());
  return match === null ? null : { major: +match[1], minor: +match[2], patch: +match[3] };
}

function compare(a, b) {
  return a.major - b.major || a.minor - b.minor || a.patch - b.patch;
}

/** The highest version among `tags`, compared numerically (not `sort -V`, which mis-orders padding). */
function latest(tags) {
  let best = null;
  for (const raw of tags) {
    const found = parse(raw);
    if (found === null) continue;
    if (best === null || compare(found, best) > 0) best = { ...found, tag: String(raw).trim() };
  }
  return best;
}

/** The `version:` line of a pubspec, checked against the convention. */
function pubspecVersion(pubspec) {
  const line = /^version:\s*(\S+)\s*$/m.exec(pubspec);
  if (line === null) throw new Error('pubspec.yaml has no `version:` line.');
  const match = PUBSPEC_VERSION.exec(line[1]);
  if (match === null) {
    throw new Error(`pubspec version ${line[1]} is not \`a.b.cd+build\` (patch padded to two digits).`);
  }
  const [, major, minor, patch, build] = match;
  if (build !== `${+major}${+minor}${patch}`) {
    throw new Error(
      `pubspec version ${line[1]}: the build must be the version without its dots, ` +
        `${+major}${+minor}${patch}.`,
    );
  }
  return { major: +major, minor: +minor, patch: +patch, version: line[1] };
}

/** The tag to release, and the published tag the notes start from. */
function nextRelease({ pubspec, tags }) {
  const current = pubspecVersion(pubspec);
  const previous = latest(tags);
  if (previous !== null && compare(current, previous) <= 0) {
    throw new Error(
      `pubspec version ${current.version} is not past the latest release ${previous.tag}. ` +
        'Bump it on the branch before merging.',
    );
  }
  return { tag: `v${current.version}`, previous: previous === null ? null : previous.tag };
}

/**
 * The open draft this automation owns. Ownership is the tag matching the convention, so a draft
 * opened by hand for anything else is never adopted, overwritten, or published as Latest. Two
 * managed drafts cannot be resolved here, so it refuses rather than choosing.
 */
function managedDraft(releases) {
  const mine = releases.filter((r) => r.isDraft && TAG.test(String(r.tagName).trim()));
  if (mine.length > 1) {
    throw new Error(
      `${mine.length} drafts match the release convention (${mine.map((r) => r.tagName).join(', ')}). ` +
        'Publish or delete all but one.',
    );
  }
  return mine.length === 1 ? mine[0].tagName : null;
}

module.exports = { TAG, latest, managedDraft, nextRelease, pubspecVersion };

//   node scripts/next-release.cjs                  the tag this commit releases
//   node scripts/next-release.cjs --managed-draft  the open draft we own, from
//                                                  `gh release list --json tagName,isDraft` on stdin
if (require.main === module) {
  const fs = require('node:fs');
  const path = require('node:path');
  const append = (line) => {
    if (process.env.GITHUB_OUTPUT) fs.appendFileSync(process.env.GITHUB_OUTPUT, line);
  };

  if (process.argv.includes('--managed-draft')) {
    const tag = managedDraft(JSON.parse(fs.readFileSync(0, 'utf8') || '[]')) ?? '';
    append(`tag=${tag}\n`);
    console.log(tag === '' ? '(no managed draft open)' : tag);
  } else {
    const { execFileSync } = require('node:child_process');
    const pubspec = fs.readFileSync(path.join(__dirname, '..', 'pubspec.yaml'), 'utf8');
    // Published tags only: a draft's tag does not exist until it is published.
    const tags = execFileSync('git', ['tag', '--list'], { encoding: 'utf8' }).split('\n');
    const next = nextRelease({ pubspec, tags });
    append(`tag=${next.tag}\nprevious=${next.previous ?? ''}\n`);
    console.log(`${next.previous ?? '(no releases)'} -> ${next.tag}`);
  }
}
