// The release automation's wiring (make release-check). The workflow only runs on a real merge, so
// its first run would be its first test; these read the workflow and the Makefile as text and hold
// the rules that make a release correct.

const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const ROOT = path.join(__dirname, '..');
const WORKFLOW = path.join(ROOT, '.github', 'workflows', 'release-draft.yaml');
const MAKEFILE = path.join(ROOT, 'Makefile');

/** The commands a file runs: comments dropped, continuations joined, split on `;` and `&&`. */
function commands(file) {
  return fs
    .readFileSync(file, 'utf8')
    .split('\n')
    .filter((line) => !/^\s*#/.test(line))
    .join('\n')
    .replace(/\\\n\s*/g, ' ')
    .split(/[\n;]|&&/)
    .map((line) => line.trim())
    .filter((line) => line !== '');
}

const writes = (file) => commands(file).filter((c) => /\bgh release (create|edit)\b/.test(c));
const lists = (file) => commands(file).filter((c) => /\bgh release list\b/.test(c));

test('every release the workflow writes is aimed at the merge being drafted', () => {
  // A draft has no tag until it is published, when the tag is cut from its target. A draft whose
  // notes are refreshed but whose target is not would be tagged on the first merge while
  // describing every merge since.
  const written = writes(WORKFLOW);
  assert.ok(written.length > 0, 'found no `gh release` write in the workflow');
  for (const command of written) {
    assert.match(command, /--target "\$GITHUB_SHA"/, `does not move the target:\n  ${command}`);
  }
});

test('the notes are generated for that same commit', () => {
  assert.match(fs.readFileSync(WORKFLOW, 'utf8'), /target_commitish=\$GITHUB_SHA/);
});

test('no release is edited with a flag that only exists on create', () => {
  for (const command of writes(WORKFLOW)) {
    if (!/\bgh release edit\b/.test(command)) continue;
    assert.doesNotMatch(command, /--generate-notes/, `edit cannot take this flag:\n  ${command}`);
  }
});

test('a refreshed draft takes the tag of the newest merge', () => {
  // Each branch bumps pubspec.yaml, so a second merge before publishing carries a newer version.
  for (const command of writes(WORKFLOW)) {
    if (!/\bgh release edit\b/.test(command)) continue;
    assert.match(command, /--tag "\$TAG"/, `keeps a stale tag:\n  ${command}`);
  }
});

test('the workflow only drafts; publishing and Latest are a person\'s call', () => {
  for (const command of writes(WORKFLOW)) {
    assert.doesNotMatch(command, /--latest|--draft=false/, `publishes from CI:\n  ${command}`);
  }
});

test('neither the workflow nor the Makefile picks a draft without asking which is ours', () => {
  for (const file of [WORKFLOW, MAKEFILE]) {
    const listed = lists(file);
    assert.ok(listed.length > 0, `${path.basename(file)} lists no releases`);
    for (const command of listed) {
      assert.match(command, /next-release\.cjs --managed-draft/, `chooses blindly:\n  ${command}`);
    }
  }
});

test('publishing marks the release Latest and does not re-aim it', () => {
  const publishing = writes(MAKEFILE).filter((c) => /--draft=false/.test(c));
  assert.equal(publishing.length, 1, 'expected exactly one command that publishes the draft');
  assert.match(publishing[0], /--latest/);
  assert.doesNotMatch(publishing[0], /--target/);
});

test('every action is pinned to a commit, not a tag', () => {
  const uses = fs.readFileSync(WORKFLOW, 'utf8').match(/uses:\s*\S+/g) ?? [];
  assert.ok(uses.length > 0);
  for (const line of uses) assert.match(line, /@[0-9a-f]{40}$/, `not pinned: ${line}`);
});
