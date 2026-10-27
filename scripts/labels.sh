#!/usr/bin/env bash
#
# The pull-request label taxonomy, as code. Provisions a fresh repository or restores drift.
#
#   ./scripts/labels.sh        (requires `gh auth login` with repo scope)

set -euo pipefail

REPO="${REPO:-Wauguzi/tabibu}"
GH="${GH:-gh}"

# name|colour|description
LABELS=(
  "type/feature|1D76DB|New feature"
  "type/fix|D73A4A|Bug fix"
  "type/breaking|B60205|Breaking change to existing behaviour"
  "type/refactor|0E8A16|Code refactor, no behaviour change"
  "type/build|5319E7|Build, tooling or CI configuration"
  "type/docs|0075CA|Documentation only"
  "type/chore|BFDADC|Housekeeping"

  "area/auth|1F883D|Sign-in, roles, profile"
  "area/cases|2DA44E|Cases, intake, ordering"
  "area/pathology|116329|Worklist, pre-read, results"
  "area/alerts|BF8700|Outbreak alerts"
  "area/notifications|8250DF|Inbox and push"
  "area/ai-service|6639BA|The Tabibu AI service"
  "area/core-ui|DDD6FE|Shared widgets, theme, assets, fonts"
  "area/l10n|0E7490|ARB files and localisation"
  "area/infra|334155|Firebase config, CI, build, platform runners"
  "area/docs|1F6FEB|docs/ tree and README"

  "clinical-safety|B60205|Touches a path covered by clinical-safety rules S-1 to S-7"
  "security-boundary|E11D48|Touches rules, indexes or Cloud Functions"
  "needs-deploy|F59E0B|Merging does not ship it; a deploy step follows"

  "needs/clinical-review|FEF08A|Pending Clinical Reviewer sign-off (CRQ section 8)"
  "needs/security-review|FEF08A|Pending Security Analyst sign-off (CRQ section 8)"
  "needs/compliance-review|FEF08A|Pending Compliance Officer sign-off (CRQ section 8)"
  "needs/design-review|FEF08A|Pending Lead Designer sign-off (CRQ section 8)"

  "P1|B60205|Critical"
  "P2|D93F0B|High"
  "P3|FBCA04|Medium"
  "P4|C2E0C6|Low"

  "dependencies|0366D6|Dependency update (applied by Dependabot)"
  "dart|00B4AB|pub ecosystem update (applied by Dependabot)"
  "github_actions|2088FF|GitHub Actions ecosystem update (applied by Dependabot)"
)

RETIRE=("good first issue" "help wanted" "duplicate" "invalid" "question" "wontfix")

# Renamed rather than recreated, so existing issues and PRs keep their label.
MIGRATIONS=("bug|type/fix" "enhancement|type/feature" "documentation|type/docs")

current=""
refresh() { current="$($GH label list --repo "$REPO" --limit 200 --json name -q '.[].name')"; }
exists() { grep -Fxq -- "$1" <<<"$current"; }

problems=()
refresh

echo "── Migrating GitHub's defaults ──"
for entry in "${MIGRATIONS[@]}"; do
  old="${entry%%|*}"
  new="${entry##*|}"
  exists "$old" || continue
  if exists "$new"; then
    problems+=("both '$old' and '$new' exist; move '$old' onto '$new', then delete '$old'")
    continue
  fi
  echo "  renaming '$old' -> '$new'"
  $GH label edit "$old" --repo "$REPO" --name "$new"
done
refresh

echo "── Creating and updating ──"
for entry in "${LABELS[@]}"; do
  IFS='|' read -r name colour description <<<"$entry"
  $GH label create "$name" --repo "$REPO" --color "$colour" --description "$description" --force >/dev/null
done
refresh

echo "── Retiring unused defaults ──"
for name in "${RETIRE[@]}"; do
  if exists "$name"; then
    echo "  deleting '$name'"
    $GH label delete "$name" --repo "$REPO" --yes
  fi
done
refresh

echo "── Verifying ──"
for entry in "${LABELS[@]}"; do
  name="${entry%%|*}"
  exists "$name" || problems+=("expected label missing: '$name'")
done
for name in "${RETIRE[@]}" bug enhancement documentation; do
  ! exists "$name" || problems+=("should no longer exist: '$name'")
done
expected="${#LABELS[@]}"
actual="$(grep -c . <<<"$current")"
[[ "$actual" -eq "$expected" ]] || problems+=("expected $expected labels, found $actual")

if ((${#problems[@]})); then
  echo
  echo "FAILED:"
  printf '  - %s\n' "${problems[@]}"
  exit 1
fi

echo
echo "OK — $actual labels."
